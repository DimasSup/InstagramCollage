//
//  PhotoPickerImageCell.m
//  SSS
//
//  Created by DimasSup on 24.04.14.
//  Copyright (c) 2014 DimasSup. All rights reserved.
//

#import "PhotoPickerImageCell.h"
#import "InstagramAPIHelper.h"
@implementation PhotoPickerImageCell
@synthesize imageData=_imageData;
-(void)dealloc
{
	[_imageData release];
	[_imageView release];
	[super dealloc];
}
-(void)setImageData:(NSDictionary *)imageData
{
	if(imageData!=_imageData)
	{
		[_imageData release];
		_imageData = [imageData retain];
	}

}

-(void)cancelDownload
{
	[_imageView setImageLink:nil];
}
-(void)startDownload
{
	[_imageView forceSetImage:nil];
	[_imageView setImageLink:[InstagramAPIHelper getImageLink:_imageData]];
}
-(void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	[self setNeedsLayout];
}
-(void)layoutSubviews
{
	[super layoutSubviews];

	_imageView.frame = CGRectMake(self.bounds.size.width/2-self.bounds.size.height/2, 0, self.bounds.size.height, self.bounds.size.height);
	_imageView.layer.borderWidth=4;
	self.backgroundColor = self.contentView.backgroundColor = [UIColor clearColor];
	_imageView.layer.borderColor = [UIColor clearColor].CGColor;

}
- (void)awakeFromNib
{
    // Initialization code
}
-(UIView *)selectedBackgroundView
{
	UIView* view = [super selectedBackgroundView];
	if(view)
	{
		view.backgroundColor = self.backgroundColor;
	}
	return view;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
	if(selected)
	{
		_imageView.layer.borderColor = [UIColor greenColor].CGColor;

	}
	else
	{
		_imageView.layer.borderColor = [UIColor clearColor].CGColor;

	}
    // Configure the view for the selected state
}

@end
