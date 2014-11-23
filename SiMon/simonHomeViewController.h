//
//  simonHomeViewController.h
//  SIMon
//
//  Created by Michael Enstone on 28/02/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "simonXMLRPCInterface.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "Reachability.h"
#import "simonProjectsDataSource.h"

@interface simonHomeViewController : UIViewController <UITextFieldDelegate>
- (IBAction)unwindToHome:(UIStoryboardSegue *)segue;
@end

CGFloat animatedDistance;
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.35;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.85;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

