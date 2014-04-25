//
//  UIImageViewExtended.m
//
//  Created by DimasSup on 10.02.14.
//  Copyright (c) 2014 DimasSup. All rights reserved.
//

#import "UIImageViewExtended.h"

@implementation UIImageViewExtended
@synthesize imageLink;


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        self.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentMode = UIViewContentModeScaleAspectFit;
}

- (id)init {
    self = [super init];
    if (self) {


        self.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
    
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];  //To change the template use AppCode | Preferences | File Templates.
	[self showProgress];
}
-(void)showProgress
{
	if (!self.image && !_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        _activityIndicator.frame = CGRectMake(self.frame.size.width / 2 - 20 / 2, self.frame.size.height / 2 - 20 / 2, 20, 20);
        [self addSubview:_activityIndicator];
        [_activityIndicator startAnimating];
    }
}
-(void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	if(_activityIndicator)
	{
		_activityIndicator.frame = CGRectMake(self.frame.size.width / 2 - 20 / 2, self.frame.size.height / 2 - 20 / 2, 20, 20);
	}
}
-(BOOL)onDataDownloadComplete:(NSData *)data forUrl:(NSString *)url
{
	if (_activityIndicator)
	{
        [_activityIndicator removeFromSuperview];
        [_activityIndicator release];
        _activityIndicator = nil;
    }
	UIImage* image = [[UIImage alloc] initWithData:data];
	self.image = image;
	
	[image release];
	
	
    @try
	{
        
        if (_target)
		{
            [_target performSelector:_selector withObject:self];
        }
    }
    @catch (...)
	{
        
    }
}
-(void)forceSetImage:(UIImage*)image
{
	if (_activityIndicator && image!=nil)
	{
        [_activityIndicator removeFromSuperview];
        [_activityIndicator release];
        _activityIndicator = nil;
    }

	
	self.image = image;
	[self showProgress];
	@try
	{
        
        if (_target)
		{
            [_target performSelector:_selector withObject:self];
        }
    }
    @catch (...)
	{
        
    }
	[self setImageLink:nil];
}
-(BOOL)onDataDownloadFailedForUrl:(NSString *)url
{
	if (_activityIndicator)
	{
        [_activityIndicator removeFromSuperview];
        [_activityIndicator release];
        _activityIndicator = nil;
    }
	@try
	{
        
        if (_target)
		{
            [_target performSelector:_selector withObject:self];
        }
    }
    @catch (...)
	{
        
    }

}
- (void)setImageLink:(NSString *)value {
	
	BOOL shouldReload = FALSE;
	
	if(!imageLink || ![imageLink isEqual:value])
	{
		shouldReload = TRUE;
	}
	
	
	
	if (shouldReload)
	{
		
		[[CacheDataDownloader sharedInstance] removeDelegate:self forUrl:self.imageLink];
		if(imageLink!=value)
		{
			[imageLink release];
			imageLink = [value retain];
		}
		
		
		[self loadImage];
		
    }
	[self showProgress];
}

- (void)setTarget:(id)target withSelector:(SEL)selector {
    if (_target != target)
	{
        
        _target =target;
    }
    _selector = selector;
    
}

- (void)dealloc
{
    [[CacheDataDownloader sharedInstance] removeDelegate:self forUrl:imageLink];
	
    [imageLink release];
    [_activityIndicator release];
    [super dealloc];
}

- (void)loadImage
{
    [[CacheDataDownloader sharedInstance] startDownload:imageLink forDelegate:self shouldSave:TRUE];
}

- (void)cancelLoad
{
    [[CacheDataDownloader sharedInstance] removeDelegate:self forUrl:self.imageLink];
}

@end