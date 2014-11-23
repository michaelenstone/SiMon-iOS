//
//  simonReportItemsViewController.h
//  SIMon
//
//  Created by Michael Enstone on 28/02/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "simonReportsDataSource.h"
#import "ReportItems.h"
#import "Reports.h"
#import "Locations.h"

@interface simonReportItemsViewController : UITableViewController

- (IBAction)unwindToReportItems:(UIStoryboardSegue *)segue;
@property simonReportsDataSource *reportsDataSource;
@property Reports *thisReport;
@property NSArray *reportItems;

@end
