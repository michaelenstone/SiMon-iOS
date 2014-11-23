//
//  simonReportHeaderViewController.h
//  SIMon
//
//  Created by Michael Enstone on 09/02/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "Reports.h"
#import "Projects.h"
#import "simonReportsDataSource.h"
#import "simonProjectsDataSource.h"
#import "simonXMLRPCInterface.h"

@interface simonReportHeaderViewController : UIViewController <UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate>

- (IBAction)unwindToReportHeader:(UIStoryboardSegue *)segue;
@property Reports *thisReport;
@property Projects *thisProject;
@property simonProjectsDataSource *projectsDataSource;
@property simonReportsDataSource *reportsDataSource;
@property NSString *reportTypeRef;

@end

CGFloat animatedDistance;
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.25;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.95;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;