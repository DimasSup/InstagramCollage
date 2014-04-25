//
//  PhotosPicker.m
//  SSS
//
//  Created by DimasSup on 24.04.14.
//  Copyright (c) 2014 DimasSup. All rights reserved.
//

#import "PhotosPicker.h"
#import "PhotoPickerImageCell.h"
#import "GenerateCollageController.h"
@interface PhotosPicker ()

@end

@implementation PhotosPicker

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUser:(NSDictionary *)user
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		_user = [user retain];
		_maxImages = 5;
    }
    return self;
}
-(void)dealloc
{
	[_user release];
	[_tableView release];
	[_segmentController release];
	[_selectdCountLabel release];
	[_selectedImageIndexes release];
	[_images release];
	[super dealloc];
}
-(void)segmentedControllerChangedState:(UISegmentedControl*)sender
{
	[_selectedImageIndexes removeAllObjects];
	[self updateUIState];
	if(_segmentController.selectedSegmentIndex == 1)
	{
		
		[_images sortUsingComparator:^NSComparisonResult(NSDictionary* obj1, NSDictionary* obj2) {
		return [[obj2 valueForKey:@"created_time"] compare:[obj1 valueForKey:@"created_time"]];
		}];
	}
	else
	{
	[_images sortUsingComparator:^NSComparisonResult(NSDictionary* obj1, NSDictionary* obj2) {
			return [[[obj2 valueForKey:@"likes"] valueForKey:@"count"] compare:[[obj1 valueForKey:@"likes"] valueForKey:@"count"]];
		}];
	}
	[_tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	_isLoadingBegun = false;
	[_segmentController addTarget:self action:@selector(segmentedControllerChangedState:) forControlEvents:UIControlEventValueChanged];
	if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier
		self.navigationController.navigationBar.tintColor = self.view.backgroundColor;
		self.navigationItem.title = NSLocalizedString(@"Choose images", @"Choose images");
    } else {
        // Load resources for iOS 7 or later
        self.edgesForExtendedLayout = UIRectEdgeNone;
		self.navigationController.navigationBar.translucent = NO;
		UIColor* color = _segmentController.tintColor;
		CGFloat r,g,b,a;
		if([color getRed:&r green:&g blue:&b alpha:&a])
		{
			_segmentController.tintColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:a];
		}
		
		UILabel* titleLabel = [[UILabel alloc] init];
		titleLabel.text =  NSLocalizedString(@"Choose images", @"Choose images");
		titleLabel.textColor = self.view.backgroundColor;
		titleLabel.textAlignment = NSTextAlignmentCenter;
		titleLabel.frame = CGRectMake(0, 0, 300, 44);
		titleLabel.font = [UIFont systemFontOfSize:20];
		self.navigationItem.titleView = titleLabel;
		[titleLabel release];
		
		
		
    }
	UINib* cellNib = [UINib nibWithNibName:@"PhotoPickerImageCell" bundle:nil];
	[_tableView registerNib:cellNib forCellReuseIdentifier:@"image_cell"];
	_selectdCountLabel.text = [NSString stringWithFormat:@"0/%i",_maxImages];
	
	
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.navigationController.navigationBarHidden = NO;
	if(!_isLoadingBegun)
	{
		_isLoadingBegun = YES;
		_processingView.hidden = NO;
		
		[[InstagramAPIHelper sharedInstance] setDelegate:self];
		if(!_nextLink)
		{
			[_images release];
			_images = [NSMutableArray new];
			[_tableView reloadData];
			
			[_selectedImageIndexes release];
			_selectedImageIndexes = [NSMutableArray new];
			
			[[InstagramAPIHelper sharedInstance] getMediaRecentByUserId:[_user valueForKey:@"id"] count:100];
		}
		else
		{
			[[InstagramAPIHelper sharedInstance] getNextMedia:_nextLink];
		}
	}
	
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)mediaGetted:(NSArray *)media nextUrl:(NSString *)nextUrl
{
	[_nextLink release];
	_nextLink = [nextUrl retain];
	if(!_nextLink || !_nextLink.length )
	{
		_activityIndicator.hidden = YES;
		[_segmentController setEnabled:YES forSegmentAtIndex:0];

	}
	_processingView.hidden = YES;
	[self insertItems:media];
	[self performSelector:@selector(nextImages) withObject:nil afterDelay:0.1];
}
-(void)insertItems:(NSArray*)items
{
	if(_images.count==0)
	{
		[_images addObjectsFromArray:items];
		[_tableView reloadData];
		return;
	}
	NSMutableArray* indexes= [NSMutableArray new];
	for (int  i =0; i<items.count; i++)
	{
		[indexes addObject:[NSIndexPath indexPathForRow:_images.count inSection:0]];
		[_images addObject:[items objectAtIndex:i]];
		
	}
	
	[_tableView beginUpdates];
	[_tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
	[_tableView endUpdates];
	[indexes release];
	
}
-(void)nextImages
{
	if(_nextLink && _nextLink.length)
	{
		[[InstagramAPIHelper sharedInstance] getNextMedia:_nextLink];
		_activityIndicator.hidden = NO;
		[_segmentController setSelectedSegmentIndex:1];
		[_segmentController setEnabled:NO forSegmentAtIndex:0];
	}
}

-(void)updateUIState
{
	_selectdCountLabel.text = [NSString stringWithFormat:@"%i/%i",_selectedImageIndexes.count,_maxImages];
	if(_selectedImageIndexes.count)
	{
		CGRect rect = _tableView.frame;
		
		float newHeight =_createCollage.frame.origin.y - rect.origin.y - 5;
		if(rect.size.height!=newHeight)
		{
			rect.size.height = newHeight;
			_createCollage.alpha = 0;
			_createCollage.hidden = NO;
			[UIView animateWithDuration:0.2 animations:^{
				_tableView.frame = rect;
				_createCollage.alpha = 1;
			} completion:^(BOOL finished) {
				
			}];
		}
	}
	else
	{
		CGRect rect = _tableView.frame;
		float newHeight =_createCollage.frame.origin.y +_createCollage.frame.size.height-rect.origin.y;
		if(rect.size.height!=newHeight)
		{
			rect.size.height = newHeight;
			
			[UIView animateWithDuration:0.2 animations:^{
				_tableView.frame = rect;
				_createCollage.alpha = 0;
			} completion:^(BOOL finished) {
				_createCollage.hidden = YES;
			}];
		}
	}
}

-(void)btnCreateClicked:(id)sender
{
	NSMutableArray* selectedImage = [NSMutableArray new];
	for (NSNumber* index in _selectedImageIndexes)
	{
		[selectedImage addObject:[_images objectAtIndex:[index intValue]]];
	}
	
	
	GenerateCollageController* generateCollage = [[GenerateCollageController alloc] initWithNibName:@"GenerateCollageController" bundle:nil withImages:selectedImage];
	[selectedImage release];
	[self.navigationController pushViewController:generateCollage animated:YES];
	[generateCollage release];
	
	
}
#pragma mark  - table view delagetes


-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(_selectedImageIndexes.count<_maxImages)
	{
		return indexPath;
	}
	
	return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[_selectedImageIndexes addObject:@(indexPath.row)];
	[self updateUIState];
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[_selectedImageIndexes removeObject:@(indexPath.row)];
	[self updateUIState];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 200;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _images.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	PhotoPickerImageCell* cell = [tableView dequeueReusableCellWithIdentifier:@"image_cell"];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	[cell setImageData:[_images objectAtIndex:indexPath.row] ];
	[cell startDownload];
	cell.selected = [_selectedImageIndexes containsObject:@(indexPath.row)];
	return cell;
}
@end
