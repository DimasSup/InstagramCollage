//
//  PhotosPicker.h
//  SSS
//
//  Created by DimasSup on 24.04.14.
//  Copyright (c) 2014 DimasSup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstagramAPIHelper.h"
@interface PhotosPicker : UIViewController<InstagramApiDelegate,UITableViewDataSource,UITableViewDelegate>
{
	NSDictionary* _user;
	IBOutlet UITableView* _tableView;
	IBOutlet UISegmentedControl* _segmentController;
	IBOutlet UIView* _processingView;
	IBOutlet UIActivityIndicatorView* _activityIndicator;
	IBOutlet UILabel* _selectdCountLabel;
	IBOutlet UIButton* _createCollage;
	NSString* _nextLink;
	
	
	NSMutableArray* _images;
	NSMutableArray* _selectedImageIndexes;
	
	int _maxImages;
	BOOL _isLoadingBegun;
}
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUser:(NSDictionary*)user;
-(IBAction)btnCreateClicked:(id)sender;
@end
