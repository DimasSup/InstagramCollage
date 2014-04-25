//
//  CacheDataDownloader.m
//
//  Created by DimasSup on 15.04.14.
//  Copyright (c) 2014 DimasSup. All rights reserved.
//

#import "CacheDataDownloader.h"

static CacheDataDownloader* _sharedCacheDownloader = nil;

@implementation CacheDataDownloadItem
@synthesize delegate;
@synthesize shouldSaveToStorage;

@end

@implementation CacheDataDownloadWorker


@synthesize delegate;
@synthesize activeDownload = _activeDownload;
@synthesize activeConnection;
@synthesize url;
#pragma mark

- (void)dealloc
{
	
    [_activeDownload release];

    [activeConnection cancel];
    [activeConnection release];
	
    [super dealloc];
}

- (void)startDownload:(NSString *)newUrl
{
	if (self.activeDownload)
	{
		if(![url isEqualToString:newUrl])
		{
			[self cancelDownload];
		}
        else return;
    }

	self.url = newUrl;
    self.activeDownload = [NSMutableData data];
	NSURLRequest* request =[NSURLRequest requestWithURL:
							[NSURL URLWithString:self.url]];
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request
							   delegate:self startImmediately:NO];
    self.activeConnection = conn;
	[conn start];
    [conn release];
    // alloc+init and start an NSURLConnection; release on completion/failure
}

- (void)cancelDownload
{
    [self.activeConnection cancel];
    self.activeConnection = nil;
    self.activeDownload = nil;
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
	// Release the connection now that it's finished
    self.activeConnection = nil;
	[self.delegate failedDownload:self reasonError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.activeConnection = nil;

    [self.delegate finishDownload:self];
}


@end

@implementation CacheDataDownloader
+(NSString*)cacheDirectory
{
	NSArray *cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cachePathArray lastObject];
	return cachePath;
}
+(CacheDataDownloader *)sharedInstance
{
	if(!_sharedCacheDownloader)
	{
		_sharedCacheDownloader = [CacheDataDownloader new];
	}
	return _sharedCacheDownloader;
}
-(id)init
{
	self = 	[super init];
	if(self)
	{
		_delegates = [NSMutableDictionary new];
		_downloaders = [NSMutableDictionary new];
	}
	return self;
}
-(NSData*)newGetDataFromStorage:(NSString*)url
{
	@try {
		
	
	NSString* component =  [[url pathComponents] objectAtIndex:[url pathComponents].count-1];
	NSString* path = [CacheDataDownloader cacheDirectory];
	NSString* filePath = [path stringByAppendingPathComponent:component];

	if(filePath && 	[[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{
		NSData* data = [[NSData alloc] initWithContentsOfFile:filePath];
		return data;
	}
	}
	@catch (NSException *exception) {
		NSLog(@"%@",[exception debugDescription]);
	}
	
	return nil;
}

-(void)loadFromDiskOrStartDownload:(NSDictionary*)params
{
	
		NSString* url = [params objectForKey:@"url"];

		NSData* data =	[self newGetDataFromStorage:url];
		if(data)
		{
			@synchronized(_delegates)
			{
				NSArray* array = [_delegates valueForKey:url];
				for (CacheDataDownloadItem* delegate in array)
				{
					[delegate.delegate onDataDownloadComplete:data forUrl:url];
				}
				
				[_delegates removeObjectForKey:url];
			}
			[data release];
		}
		else
		{
			CacheDataDownloadWorker* worker = nil;
			@synchronized(_delegates)
			{
				worker = [_downloaders objectForKey:url];
				if(worker)
				{
					
					worker = nil;
					
				}
				else
				{
					worker = [[CacheDataDownloadWorker alloc] init];
					worker.delegate = self;
					[_downloaders setObject:worker forKey:url];
					
				}
			}
			if(worker)
			{
				[worker performSelectorOnMainThread:@selector(startDownload:) withObject:url waitUntilDone:YES];
			}
		}
		[params release];

}

-(void)startDownload:(NSString *)url forDelegate:(id<CacheDataDownloaderDelegate>)delegate shouldSave:(BOOL)shouldSave
{
	@synchronized(_delegates)
	{
		if(!url)
			return;
		url = [url lowercaseString];
		NSMutableArray* array = [_delegates objectForKey:url];
		if(!array)
		{
			array = [NSMutableArray new];
			[_delegates setObject:array forKey:url];
			[array release];
		}
		CacheDataDownloadItem* item = [[CacheDataDownloadItem alloc] init];
		item.shouldSaveToStorage = shouldSave;
		item.delegate = delegate;
		[array addObject:item];
		[item release];
		NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:url,@"url", nil];
		
		[self performSelectorInBackground:@selector(loadFromDiskOrStartDownload:) withObject:params];
	}
}
-(void)removeDelegate:(id<CacheDataDownloaderDelegate>)delegate forUrl:(NSString *)url
{
	
	if(!url)
		return;
	url = [url lowercaseString];
	NSMutableArray* delegates = [_delegates objectForKey:url];
	if(delegates)
	{
		for (int  i = 0; i<delegates.count; i++)
		{
			CacheDataDownloadItem* item = [delegates objectAtIndex:i];
			if(item.delegate == delegate)
			{
				[delegates removeObjectAtIndex:i];
				i--;
			}
		}
		if(delegates.count == 0)
		{

			@synchronized(_delegates)
			{
				[_delegates removeObjectForKey:url];
				CacheDataDownloadWorker* worker =  [_downloaders objectForKey:url];
				if(worker)
				{
					[worker cancelDownload];
					[_downloaders removeObjectForKey:url];
				}
			}
		}
	}
}

-(BOOL)saveDatToFile:(NSData*)data withUrl:(NSString*)url
{
	NSString* component =  [url lastPathComponent];
	NSString* path = [CacheDataDownloader cacheDirectory];
	NSString* filePath = [path stringByAppendingPathComponent:component];
	
	if(filePath)
	{
		if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
		{
			[[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
		}
		[data writeToFile:filePath atomically:FALSE];
		return TRUE;
	}
	return FALSE;
}


- (void)finishDownload:(CacheDataDownloadWorker *)sender
{
	@synchronized(_delegates)
	{
		BOOL isSaved = FALSE;
		NSString* url = [sender.url retain];
		NSArray* array=  [_delegates objectForKey:sender.url];
		for (CacheDataDownloadItem* item in array)
		{
			[item.delegate onDataDownloadComplete:sender.activeDownload forUrl:url];
			
			if(!isSaved)
			{
				if(item.shouldSaveToStorage)
				{
					isSaved = [self saveDatToFile:sender.activeDownload withUrl:url];
				}
			}
		}
		[_downloaders removeObjectForKey:url];
		[url release];
	}
}
- (void)failedDownload:(CacheDataDownloadWorker *)sender reasonError:(NSError*)error
{
	@synchronized(_delegates)
	{
		NSLog(@"Download failed:%@\n%@",sender.url,[error localizedDescription]);
		NSString* url = [sender.url retain];
		[_downloaders removeObjectForKey:url];
		NSArray* array = [_delegates objectForKey:url];
		for (CacheDataDownloadItem* item  in array)
		{
			[item.delegate onDataDownloadFailedForUrl:url];
		}
		[url release];
	}
	
}

@end
