//
//  LoginViewController.h
//  SSS
//
//  Created by DimasSup on 23.04.14.
//  Copyright (c) 2014 DimasSup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstagramAPIHelper.h"
@interface LoginViewController : UIViewController<NSURLConnectionDelegate,InstagramApiDelegate>
{
	IBOutlet UITextField* _tfUserName;

}
-(IBAction)btnOnCreateClicked:(UIButton*)button;
@end
