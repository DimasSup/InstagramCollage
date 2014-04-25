//
//  GenerateCollageController.m
//  SSS
//
//  Created by DimasSup on 24.04.14.
//  Copyright (c) 2014 DimasSup. All rights reserved.
//

#import "GenerateCollageController.h"
#import "CollageLayoutsHelper.h"
@interface GenerateCollageController ()

@end

@implementation GenerateCollageController
@synthesize collageBackColor;
-(void)dealloc
{
	for (NSDictionary* data in _imagesData)
	{
		NSString* url =	[InstagramAPIHelper getStandartImageLink:data];
		[[CacheDataDownloader sharedInstance] removeDelegate:self forUrl:url];
	}
	[_generatingCollageLabel release];
	[_downloadingImagesLabel release];
	[_processingView release];
	[_imagesData release];
	[_downloadedImages release];
	[_resultImageView release];
	[collageBackColor release];
	[super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withImages:(NSArray*)images
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		_imagesData = [images retain];
		self.collageBackColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier
		self.navigationController.navigationBar.tintColor = self.view.backgroundColor;
		self.navigationItem.title = NSLocalizedString(@"Your collage!",@"Your collage!");
    } else {
        // Load resources for iOS 7 or later
        self.edgesForExtendedLayout = UIRectEdgeNone;
		self.navigationController.navigationBar.translucent = NO;
			
		UILabel* titleLabel = [[UILabel alloc] init];
		titleLabel.text =  NSLocalizedString(@"Your collage!", @"Your collage!");
		titleLabel.textColor = self.view.backgroundColor;
		titleLabel.textAlignment = NSTextAlignmentCenter;
		titleLabel.frame = CGRectMake(0, 0, 300, 44);
		titleLabel.font = [UIFont systemFontOfSize:20];
		self.navigationItem.titleView = titleLabel;
		[titleLabel release];
		
		
		
    }
	_isDownloadingBegun = FALSE;
//	_downloadedImages = NSMutable
    // Do any additional setup after loading the view from its nib.
}

-(void)finishedAllDownloads
{
	[UIView animateWithDuration:0.3 animations:^{
		[_downloadingImagesLabel setAlpha:0];
		[_generatingCollageLabel setAlpha:1];
	}];
	[self generateImage];
	
	
}
-(void)btnPrintClicked:(UIButton*)sender
{
	UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
    printController.printingItem = _resultImageView.image;
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputPhoto;
    printController.printInfo = printInfo;
    printController.showsPageRange = YES;
	
	

	[printController presentFromRect:sender.frame inView:self.view animated:YES completionHandler:^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError *error) {
		if (!completed && error) {
			NSLog(@"FAILED! due to error in domain %@ with error code %u", error.domain, error.code);
		}
	}];

}
-(void)generateImage
{
	NSAutoreleasePool* pool = [NSAutoreleasePool new];
	float border = 2;
	CGSize resultSize = CGSizeMake(612, 612);
	UIGraphicsBeginImageContextWithOptions(resultSize, NO, 1);

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextScaleCTM(context, 1, -1);
	CGContextTranslateCTM(context, 0, -resultSize.height);
	CGContextClearRect(context, CGRectMake(0, 0, resultSize.width, resultSize.height));
	CGContextSetFillColorWithColor(context, self.collageBackColor.CGColor);
	CGContextFillRect(context, CGRectMake(0, 0, resultSize.width, resultSize.height));
	NSArray* array = [CollageLayoutsHelper newGetLayout:_imagesData.count];


	
	for(int i = 0;i<array.count;i++)
	{
		NSDictionary* dict = [_imagesData objectAtIndex:i];
		NSString* url = [InstagramAPIHelper getStandartImageLink:dict];
		
		UIImage* image = [_downloadedImages valueForKey:url];
		if(image)
		{
			CGRect rect = [[array objectAtIndex:i] CGRectValue];
			rect.origin.x=rect.origin.x*resultSize.width+border;
			rect.size.width=rect.size.width*resultSize.width-border*2;
			rect.origin.y=rect.origin.y*resultSize.height+border;
			rect.size.height=rect.size.height*resultSize.height-border*2;
			CGRect rectForCrop;
			if(rect.size.width>rect.size.height)
			{
				float height = image.size.width* (rect.size.height/rect.size.width);
				rectForCrop = CGRectMake(0, image.size.height/2-height/2, image.size.width, height);
				
			}
			else
			{
				float width = image.size.height* (rect.size.width/rect.size.height);
				rectForCrop = CGRectMake(image.size.width/2-width/2, 0, width, image.size.height);
				
			}
			
			CGImageRef imageRef =  CGImageCreateWithImageInRect(image.CGImage, rectForCrop);
			CGContextDrawImage(context, rect, imageRef);
			CGImageRelease(imageRef);
		}
			
	}
	
	
	[array release];
	UIImage* image = [UIGraphicsGetImageFromCurrentImageContext() retain];
	UIGraphicsEndImageContext();
	_resultImageView.image = image;
	[image release];
	_processingView.hidden = YES;
	[pool drain];
}

-(BOOL)onDataDownloadComplete:(NSData*)data forUrl:(NSString*)url
{
	UIImage* image = [[UIImage alloc ] initWithData:data scale:1];
	[_downloadedImages setObject:image forKey:url];
	[image release];
	if(_downloadedImages.count==_imagesData.count)
	{
		[self performSelectorOnMainThread:@selector(finishedAllDownloads) withObject:nil waitUntilDone:FALSE];
	}
	return YES;
}
-(BOOL)onDataDownloadFailedForUrl:(NSString*)url
{
	[self.navigationController popViewControllerAnimated:YES];
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WARNING",@"WARNING") message:NSLocalizedString(@"Some image cannot be loaded. Please try again later.",@"Some image cannot be loaded. Please try again later.") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];
	[alert release];

	return YES;
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.navigationController.navigationBarHidden = NO;
	if (!_isDownloadingBegun) {
		_isDownloadingBegun = YES;
		_downloadedImages = [NSMutableDictionary new];
		for (NSDictionary* imageData in _imagesData)
		{
			NSString* url = [InstagramAPIHelper getStandartImageLink:imageData];
			[[CacheDataDownloader sharedInstance] startDownload:url forDelegate:self shouldSave:NO];
		}
	}

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
