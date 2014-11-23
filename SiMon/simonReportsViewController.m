//
//  simonReportsViewController.m
//  SIMon
//
//  Created by Michael Enstone on 18/02/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import "simonReportsViewController.h"

@interface simonReportsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) NSArray *menuOptionsArray;

@end

@implementation simonReportsViewController

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
    if (!self.reportsDataSource) {
        self.reportsDataSource = [[simonReportsDataSource alloc] init];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [self.reportsDataSource.reports count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ReportListPrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Reports *report = [self.reportsDataSource.reports objectAtIndex:indexPath.row];
    Projects *rowProject = report.project;
    NSDate *myDate = report.reportDate;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    NSString *prettyVersion = [dateFormat stringFromDate:myDate];
    NSString *cellTitle = rowProject.projectName;
    cellTitle = [cellTitle stringByAppendingString:@" - "];
    cellTitle = [cellTitle stringByAppendingString:prettyVersion];
    cell.textLabel.text = cellTitle;
    cell.detailTextLabel.text = report.reportRef;
    return cell;
}

- (IBAction)unwindToReports:(UIStoryboardSegue *)segue
{
    [self.reportsDataSource loadInitialData];
    [self.tableView reloadData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"editReportSegue"]){
        NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        simonReportHeaderViewController *controller = (simonReportHeaderViewController *)navController.topViewController;
        controller.thisReport = [self.reportsDataSource.reports objectAtIndex:selectedRowIndex.row];
        controller.reportsDataSource = self.reportsDataSource;
    } else if ([segue.identifier isEqualToString:@"newReportSegue"]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        simonReportHeaderViewController *controller = (simonReportHeaderViewController *)navController.topViewController;
        controller.reportsDataSource = self.reportsDataSource;
    }
}
@end
