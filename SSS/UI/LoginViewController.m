//
//  LoginViewController.m
//  SSS
//
//  Created by DimasSup on 23.04.14.
//  Copyright (c) 2014 DimasSup. All rights reserved.
//

#import "LoginViewController.h"
#import "PhotosPicker.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)dealloc
{
	[_tfUserName release];
	[super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[InstagramAPIHelper sharedInstance] setDelegate:self];
	self.navigationController.navigationBarHidden = YES;
	[_tfUserName becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)btnOnCreateClicked:(UIButton *)button
{
	if(_tfUserName.text && _tfUserName.text.length>0)
	{
		[[InstagramAPIHelper sharedInstance] searchUserByString:_tfUserName.text.lowercaseString force:YES];
	}
//	https://api.instagram.com/v1/tags/SEARCH_TAG/media/recent?client_id=CLIENT_ID&callback=MY_CALLBACK
}

-(void)findedUsers:(NSArray *)users
{
	if(users.count>1)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Information", @"Information") message:NSLocalizedString(@"Too many users with same nickname. Please refine your query.", @"Too many users with same nickname. Please refine your query.") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	else if (users.count==0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Information", @"Information") message:NSLocalizedString(@"Cannot find user with this nickname.", @"Cannot find user with this nickname.") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	
	NSDictionary* user = [users objectAtIndex:0];
	PhotosPicker* picker = [[PhotosPicker alloc] initWithNibName:@"PhotosPicker" bundle:nil andUser:user];
	[self.navigationController pushViewController:picker animated:YES];
	[picker release];
	 
	 
//	[[InstagramAPIHelper sharedInstance] getMediaRecentByUserId:[user valueForKey:@"id"] count:100];
	
}
-(void)failedFindUsers:(NSError *)reason
{
	
}

-(void)mediaGetted:(NSArray *)media nextUrl:(NSString *)nextUrl
{
	NSLog(@"%@",media);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
