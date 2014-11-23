//
//  simonReportItemViewController.h
//  SIMon
//
//  Created by Michael Enstone on 13/02/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReportItems.h"
#import "simonReportsDataSource.h"
#import "Locations.h"
#import "Photo.h"
#import "Reports.h"
#import "Projects.h"
#import "MLPAutoCompleteTextField/MLPAutoCompleteTextFieldDelegate.h"
#import "MLPAutoCompleteTextField/MLPAutoCompleteTextFieldDataSource.h"


@class MLPAutoCompleteTextField;

@interface simonReportItemViewController : UIViewController <UINavigationControllerDelegate,UITextFieldDelegate, MLPAutoCompleteTextFieldDelegate,UITextViewDelegate, UIImagePickerControllerDelegate, MLPAutoCompleteTextFieldDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
@property Reports *thisReport;
@property ReportItems *thisReportItem;
@property Projects *thisProject;
@property simonReportsDataSource *reportsDataSource;
@property Locations *thisLocation;
@property Photo *photoToDelete;
@property BOOL isSVR;
@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property BOOL keyboardVisible;

@end

CGFloat animatedDistance;
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.3;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.85;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;