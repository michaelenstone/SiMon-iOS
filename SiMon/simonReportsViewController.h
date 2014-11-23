//
//  simonReportsViewController.h
//  SIMon
//
//  Created by Michael Enstone on 18/02/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "simonReport.h"
#import "simonReportHeaderViewController.h"
#import "simonReportsDataSource.h"
//#import "simonProjectsDataSource.h"
//#import "Projects.h"

@interface simonReportsViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

- (IBAction)unwindToReports:(UIStoryboardSegue *)segue;
@property simonReportsDataSource *reportsDataSource;
@property simonProjectsDataSource *projectsDataSource;

@end
