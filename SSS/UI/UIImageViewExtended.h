//
//  UIImageViewExtended.h
//  Created by DimasSup on 10.02.14.
//  Copyright (c) 2014 DimasSup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CacheDataDownloader.h"
@interface UIImageViewExtended : UIImageView <CacheDataDownloaderDelegate>
{

    id _target;
    SEL _selector;
    UIActivityIndicatorView * _activityIndicator;

}

@property (nonatomic, readonly) NSString *imageLink;
-(void)setImageLink:(NSString *)value;
-(void)setTarget:(id)target withSelector:(SEL)selector;
- (void)loadImage;
-(void)cancelLoad;
-(void)forceSetImage:(UIImage*)image;
@end