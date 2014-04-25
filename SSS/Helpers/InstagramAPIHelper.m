//
//  InstagramAPIHelper.m
//  SSS
//
//  Created by DimasSup on 23.04.14.
//  Copyright (c) 2014 DimasSup. All rights reserved.
//

#import "InstagramAPIHelper.h"
#define kSearchUserConnectonTag @"search_users"
#define kMediaForUserConnectonTag @"get_media"
static InstagramAPIHelper* _sharedInstagramApi = nil;

@implementation ConnectonRequestObject
@synthesize delegate;
@synthesize connection = _connection;
@synthesize requestUrl = _requestUrl;
@synthesize resultData = _resultData;
@synthesize tag;
-(id)initWithUrl:(NSString *)url andDelegate:(id<ConnectonRequestObjectDelegate>)delgt
{
	self = [super init];
	if(self)
	{
		_requestUrl = [url retain];
		self.delegate = delgt;
	}
	return self;
}
-(void)dealloc
{
	[_connection cancel];
	[_connection release];
	[_requestUrl release];
	[_resultData release];
	[tag release];

	[super dealloc];
}
-(void)start
{
	if(_connection || ![_requestUrl length])
	{
		return;
	}
	[_resultData release];
	_resultData = [NSMutableData  new];
	NSURLRequest* request= [NSURLRequest requestWithURL:[NSURL URLWithString:_requestUrl]];
	
	_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	[_connection start];

	
	
}
-(void)stop
{
	[_connection cancel];
	[_connection release];
	_connection = nil;
	[_resultData release];
	_resultData = nil;
}


#pragma mark - Connection delegate
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_resultData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[_resultData release];
	_resultData = nil;
	[_connection release];
	_connection = nil;
	if(self.delegate && [self.delegate respondsToSelector:@selector(requestFailed:withError:)])
	{
		[self.delegate requestFailed:self withError:error];
	}
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[_connection release];
	_connection = nil;
	if(self.delegate)
	{
		[self.delegate requestFinished:self];
	}
}

@end


@implementation InstagramAPIHelper

+(NSString *)getImageLink:(NSDictionary *)imageData
{
	if (!imageData )
	{
		return nil;
	}
	NSDictionary* images = [imageData valueForKey:@"images"];
	if(!images)
	{
		return nil;
	}
	NSDictionary* standartImage = [images valueForKey:@"low_resolution"];
	if(!standartImage)
	{
		return nil;
	}
	return [standartImage valueForKey:@"url"];
}
+(NSString *)getStandartImageLink:(NSDictionary *)imageData
{
	if (!imageData )
	{
		return nil;
	}
	NSDictionary* images = [imageData valueForKey:@"images"];
	if(!images)
	{
		return nil;
	}
	NSDictionary* standartImage = [images valueForKey:@"standard_resolution"];
	if(!standartImage)
	{
		return nil;
	}
	return [standartImage valueForKey:@"url"];
}

+(InstagramAPIHelper *)sharedInstance
{
	if (!_sharedInstagramApi)
	{
		_sharedInstagramApi = [InstagramAPIHelper new];
	}
	return _sharedInstagramApi;
}
-(id)init
{
	self = [super init];
	if(self)
	{
		_activeConnections = [NSMutableDictionary new];
	}
	return self;
}

-(BOOL)searchUserByString:(NSString *)queryString force:(BOOL)force
{
	ConnectonRequestObject* exist = [_activeConnections valueForKeyPath:kSearchUserConnectonTag];
	if(exist)
	{
		if(!force)
		{
			return FALSE;
		}
		[exist stop];
	}
	ConnectonRequestObject* request = [[ConnectonRequestObject alloc] initWithUrl:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/search?q=%@&client_id=%@",queryString,kInstagramApplicationId] andDelegate:self];
	request.tag = kSearchUserConnectonTag;
	request.params = queryString;
	[_activeConnections setValue:request forKeyPath:kSearchUserConnectonTag];
	[request start];
	
	[request release];
	return TRUE;
}
-(BOOL)stopSearchUsers
{
	ConnectonRequestObject* exist = [_activeConnections valueForKeyPath:kSearchUserConnectonTag];
	if(exist)
	{
		[exist stop];
		[_activeConnections removeObjectForKey:kSearchUserConnectonTag];
		return YES;
	}
	
	return NO;
}

-(BOOL)getMediaRecentByUserId:(NSString *)userId count:(int)count
{
	ConnectonRequestObject* exist = [_activeConnections valueForKeyPath:kMediaForUserConnectonTag];
	if(exist)
	{
		[exist stop];
	}
	ConnectonRequestObject* request = [[ConnectonRequestObject alloc] initWithUrl:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/media/recent?count=%i&client_id=%@",userId,count,kInstagramApplicationId] andDelegate:self];
	request.tag = kMediaForUserConnectonTag;
	[_activeConnections setValue:request forKey:kMediaForUserConnectonTag];
	[request start];
	return YES;
}
-(BOOL)getNextMedia:(NSString *)nextUrl
{
	
	
	ConnectonRequestObject* exist = [_activeConnections valueForKeyPath:kMediaForUserConnectonTag];
	if(exist)
	{
		[exist stop];
	}
	ConnectonRequestObject* request = [[ConnectonRequestObject alloc] initWithUrl:nextUrl andDelegate:self];
	request.tag = kMediaForUserConnectonTag;
	[_activeConnections setValue:request forKey:kMediaForUserConnectonTag];
	[request start];
	return YES;
	return YES;
}

#pragma mark - request object delegate
-(void)requestFinished:(ConnectonRequestObject *)object
{
	if([object.tag isEqualToString:kSearchUserConnectonTag])
	{
		NSMutableArray* result = [[NSMutableArray alloc] init];
		if(object.resultData)
		{
			NSAutoreleasePool* pool = [NSAutoreleasePool new];
			NSDictionary* data = [NSJSONSerialization JSONObjectWithData:object.resultData options:0 error:nil];
			if(data)
			{
				NSArray* users = [data valueForKey:@"data"];
				if(users)
				{
					for (NSDictionary* user in users)
					{
						if([[user valueForKey:@"username"] isEqualToString:object.params])
						{
							[result addObject:user];
							break;
						}
					}
					if(result.count==0 && users.count!=0)
					{
						[result addObjectsFromArray:users];
					}
				}
			}
			[pool drain];

		}
		if(self.delegate && [self.delegate respondsToSelector:@selector(findedUsers:)])
		{
			[self.delegate findedUsers:result];
		}
		[result release];
		[_activeConnections removeObjectForKey:kSearchUserConnectonTag];
	}
	else if([object.tag isEqualToString:kMediaForUserConnectonTag])
	{
		NSMutableArray* result = [[NSMutableArray alloc] init];
		NSString* nextUrl = @"";
		if(object.resultData)
		{
			NSAutoreleasePool* pool = [NSAutoreleasePool new];
			NSDictionary* data = [NSJSONSerialization JSONObjectWithData:object.resultData options:0 error:nil];
			if(data)
			{
				NSDictionary* pagination = [data valueForKey:@"pagination"];
				if(pagination)
				{
					if([pagination valueForKey:@"next_url"])
					{
						nextUrl = [[pagination valueForKey:@"next_url"] retain];
					}
				}
				
				NSArray* media = [data valueForKey:@"data"];
				if(media)
				{
					for (NSDictionary* item in media)
					{
						if ([[item valueForKey:@"type"] isEqualToString:@"image"])
						{
							[result addObject:item];
						}
					}
				}
				
			}
			[pool drain];
			
		}
		[_activeConnections removeObjectForKey:kMediaForUserConnectonTag];
		
		if(self.delegate && [self.delegate respondsToSelector:@selector(mediaGetted:nextUrl:)])
		{
			[self.delegate mediaGetted:result nextUrl:nextUrl];
		}
		[result release];
		[nextUrl release];
		
	}

	
}

-(void)requestFailed:(ConnectonRequestObject *)object withError:(NSError *)error
{
	if([object.tag isEqualToString:kSearchUserConnectonTag])
	{
		if(self.delegate && [self.delegate respondsToSelector:@selector(failedFindUsers:)])
		{
			[self.delegate failedFindUsers:error];
		}
	}

	
	[_activeConnections removeObjectForKey:object];
	
}



-(void)dealloc
{
	[_activeConnections release];
	[super dealloc];
}
@end
