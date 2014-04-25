//
//  PhotoPickerImageCell.h
//  SSS
//
//  Created by DimasSup on 24.04.14.
//  Copyright (c) 2014 DimasSup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageViewExtended.h"
@interface PhotoPickerImageCell : UITableViewCell
{
	IBOutlet UIImageViewExtended* _imageView;
	NSDictionary* _imageData;
	
	
	
}
@property(nonatomic,retain)NSDictionary* imageData;
-(void)cancelDownload;
-(void)startDownload;
@end
