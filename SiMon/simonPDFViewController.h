//
//  simonPDFViewController.h
//  SIMon
//
//  Created by Michael Enstone on 19/10/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "simonPDFRenderer.h"
#import "Reports.h"
#import "simonReportsDataSource.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface simonPDFViewController : UIViewController

@property Reports *thisReport;
@property NSString *fileName;
@property simonReportsDataSource *reportsDataSource;

@end


