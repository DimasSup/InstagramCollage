//
//  CacheDataDownloader.h
//
//  Created by DimasSup on 15.04.14.
//  Copyright (c) 2014 DimasSup. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CacheDataDownloaderDelegate<NSObject>
-(BOOL)onDataDownloadComplete:(NSData*)data forUrl:(NSString*)url;
-(BOOL)onDataDownloadFailedForUrl:(NSString*)url;

@end

@interface CacheDataDownloadItem : NSObject
@property(nonatomic,assign)id<CacheDataDownloaderDelegate> delegate;
@property(nonatomic)BOOL shouldSaveToStorage;
@end


@class CacheDataDownloadWorker;

@protocol CacheDataDownloadWorkerDelegate

- (void)finishDownload:(CacheDataDownloadWorker *)sender;
- (void)failedDownload:(CacheDataDownloadWorker *)sender reasonError:(NSError*)error;
@end

@interface CacheDataDownloadWorker : NSObject<NSURLConnectionDelegate>
{
	

	NSMutableData *_activeDownload;

}


@property (nonatomic, assign) id <CacheDataDownloadWorkerDelegate> delegate;
@property (nonatomic, retain) NSData *activeDownload;
@property (nonatomic, retain) NSURLConnection *activeConnection;
@property (nonatomic, retain) NSString *url;


- (void)startDownload:(NSString*)url;

- (void)cancelDownload;


@end

@interface CacheDataDownloader : NSObject<CacheDataDownloadWorkerDelegate>
{
	NSMutableDictionary* _downloaders;
	NSMutableDictionary* _delegates;
}
+(CacheDataDownloader*)sharedInstance;
-(void)startDownload:(NSString *)url forDelegate:(id<CacheDataDownloaderDelegate>)delegate shouldSave:(BOOL)shouldSave;
-(void)removeDelegate:(id<CacheDataDownloaderDelegate>)delegate forUrl:(NSString*)url;
@end
