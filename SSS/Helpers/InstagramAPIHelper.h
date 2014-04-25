//
//  InstagramAPIHelper.h
//  SSS
//
//  Created by DimasSup on 23.04.14.
//  Copyright (c) 2014 DimasSup. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol InstagramApiDelegate <NSObject>
@optional
-(void)findedUsers:(NSArray*)users;
-(void)failedFindUsers:(NSError*)reason;

-(void)mediaGetted:(NSArray*)media nextUrl:(NSString*)nextUrl;
-(void)failedMediaGet:(NSError*)reason;
@end
@class ConnectonRequestObject;
@protocol ConnectonRequestObjectDelegate <NSObject>

-(void)requestFinished:(ConnectonRequestObject*)object;
@optional
-(void)requestFailed:(ConnectonRequestObject*)object withError:(NSError*)error;

@end
@interface ConnectonRequestObject : NSObject<NSURLConnectionDataDelegate>
{
	NSMutableData* _resultData;
	NSString* _requestUrl;
	NSURLConnection* _connection;
}
@property(nonatomic,readonly)NSData* resultData;
@property(nonatomic,readonly)NSString* requestUrl;
@property(nonatomic,readonly)NSURLConnection* connection;
@property(nonatomic,assign)id<ConnectonRequestObjectDelegate> delegate;
@property(nonatomic,retain)NSString* tag;
@property(nonatomic,retain)NSString* params;
-(id)initWithUrl:(NSString*)url andDelegate:(id<ConnectonRequestObjectDelegate>)delegate;

-(void)start;
-(void)stop;

@end


@interface InstagramAPIHelper : NSObject<ConnectonRequestObjectDelegate>
{
	NSMutableDictionary* _activeConnections;
}
+(InstagramAPIHelper*)sharedInstance;
+(NSString*)getImageLink:(NSDictionary*)imageData;
+(NSString *)getStandartImageLink:(NSDictionary *)imageData;
@property(nonatomic,assign)id<InstagramApiDelegate> delegate;


-(BOOL)searchUserByString:(NSString *)queryString force:(BOOL)force;
-(BOOL)stopSearchUsers;

-(BOOL)getMediaRecentByUserId:(NSString*)userId count:(int)count;
-(BOOL)getNextMedia:(NSString*)nextUrl;

@end
