//
//  simonReportItemsViewController.m
//  SIMon
//
//  Created by Michael Enstone on 28/02/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import "simonReportItemsViewController.h"
#import "simonReportItemViewController.h"

@interface simonReportItemsViewController ()

@end

@implementation simonReportItemsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.reportItems = [self.thisReport.reportItems allObjects];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.thisReport.reportItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ReportItemListPrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    ReportItems *reportItem = [self.reportItems objectAtIndex:indexPath.row];
    Locations *location = reportItem.location;
    NSString *cellTitle = reportItem.activityOrItem;
    cellTitle = [cellTitle stringByAppendingString:@" - "];
    if (location.locationName) {
        cellTitle = [cellTitle stringByAppendingString:location.locationName];
    }
    cell.textLabel.text = cellTitle;
    cell.detailTextLabel.text = reportItem.itemDescription;
    return cell;
}

- (IBAction)unwindToReportItems:(UIStoryboardSegue *)segue
{
    self.reportItems = [self.thisReport.reportItems allObjects];
    [self.tableView reloadData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"editReportItemSegue"]){
        NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        simonReportItemViewController *controller = (simonReportItemViewController *)navController.topViewController;
        controller.thisReportItem = [self.reportItems objectAtIndex:selectedRowIndex.row];
        controller.isSVR = [self.thisReport.reportType boolValue];
        controller.reportsDataSource = self.reportsDataSource;
        controller.thisLocation = controller.thisReportItem.location;
        controller.thisProject = self.thisReport.project;
    } else if ([segue.identifier isEqualToString:@"newReportItemSegue"]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        simonReportItemViewController *controller = (simonReportItemViewController *)navController.topViewController;
        controller.thisReport = self.thisReport;
        controller.isSVR = [self.thisReport.reportType boolValue];
        controller.reportsDataSource = self.reportsDataSource;
        controller.thisProject = self.thisReport.project;
    }
}
@end
