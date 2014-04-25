//
//  GenerateCollageController.h
//  SSS
//
//  Created by DimasSup on 24.04.14.
//  Copyright (c) 2014 DimasSup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CacheDataDownloader.h"
#import "InstagramAPIHelper.h"
@interface GenerateCollageController : UIViewController<CacheDataDownloaderDelegate>
{
	IBOutlet UIView* _processingView;
	IBOutlet UILabel* _generatingCollageLabel;
	IBOutlet UILabel* _downloadingImagesLabel;
	IBOutlet UIImageView* _resultImageView;
	NSArray* _imagesData;
	NSMutableDictionary* _downloadedImages;
	
	BOOL _isDownloadingBegun;

}
@property(nonatomic,retain)UIColor* collageBackColor;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withImages:(NSArray*)images;
-(IBAction)btnPrintClicked:(id)sender;
@end
