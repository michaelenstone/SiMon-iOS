//
//  simonReportHeaderViewController.m
//  SIMon
//
//  Created by Michael Enstone on 09/02/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import "simonReportHeaderViewController.h"
#import "simonProjectsDataSource.h"
#import "simonReportsViewController.h"
#import "simonReportItemsViewController.h"
#import "simonPDFViewController.h"

@interface simonReportHeaderViewController () <MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
    long long expectedLength;
    long long currentLength;
}

@property (weak, nonatomic) IBOutlet UITextField *projectTextField;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UITextField *authorTextField;
@property (weak, nonatomic) IBOutlet UITextField *reportRefTextField;
@property (weak, nonatomic) IBOutlet UITextField *weatherTextField;
@property (weak, nonatomic) IBOutlet UITextField *tempTextField;
@property (weak, nonatomic) IBOutlet UIButton *PDFButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tempTypeControl;
- (IBAction)deleteReportButton:(UIButton *)sender;
- (IBAction)uploadReportItem:(UIButton *)sender;
- (IBAction)createPDFButton:(UIButton *)sender;

@end

@implementation simonReportHeaderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIPickerView *picker = [[UIPickerView alloc] init];
    picker.dataSource = self;
    picker.delegate = self;
    self.projectTextField.inputView = picker;
    self.projectTextField.delegate = self;
    self.projectsDataSource = [[simonProjectsDataSource alloc] init];
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker setDate:[NSDate date]];
    [datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    [self.dateTextField setInputView:datePicker];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    NSString *prettyVersion = [dateFormat stringFromDate:[NSDate date]];
    self.dateTextField.text = prettyVersion;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    self.dateTextField.delegate = self;
    self.authorTextField.delegate = self;
    self.reportRefTextField.delegate = self;
    self.weatherTextField.delegate = self;
    self.tempTextField.delegate = self;
    
    if (!self.thisReport) {
        self.thisReport = [NSEntityDescription insertNewObjectForEntityForName:@"Reports" inManagedObjectContext:self.reportsDataSource.coreDataInterface.context];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Report Type"
                                                        message:@"Please select the type of report you wish to create"
                                                       delegate:self
                                              cancelButtonTitle:@"Site Visit Report"
                                              otherButtonTitles:@"Progress Report", nil];
        [alert show];
        NSString *authorname = [defaults objectForKey:@"Name_simon"];
        if (authorname) {
            self.thisReport.supervisor = authorname;
            self.authorTextField.text = authorname;
        }
    } else {
        self.thisProject = self.thisReport.project;
        self.projectTextField.text = self.thisProject.projectName;
        NSDate *myDate = self.thisReport.reportDate;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yyyy"];
        NSString *prettyVersion = [dateFormat stringFromDate:myDate];
        self.dateTextField.text = prettyVersion;
        self.authorTextField.text = self.thisReport.supervisor;
        self.reportRefTextField.text = self.thisReport.reportRef;
        self.weatherTextField.text = self.thisReport.weather;
        self.tempTextField.text = self.thisReport.temp.stringValue;
        if (self.thisReport.tempType) {
            self.tempTypeControl.selectedSegmentIndex = 1;
        } else {
            self.tempTypeControl.selectedSegmentIndex = 0;
        }
        [self makeReportTypeRef:self.thisReport.reportType];
        if (self.thisReport.reportPDF.length > 1) {
            [self.PDFButton setTitle:@"Open PDF" forState:UIControlStateNormal];
        }
    }
    
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)picker;
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)picker numberOfRowsInComponent:(NSInteger)component;
{
    return self.projectsDataSource.projects.count;
    
}

- (NSString *)pickerView:(UIPickerView *)picker titleForRow:(NSInteger)row forComponent: (NSInteger)component;
{
    Projects *rowProject = [self.projectsDataSource.projects objectAtIndex:row];
    return rowProject.projectName;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    Projects *rowProject = [self.projectsDataSource.projects objectAtIndex:row];
    self.projectTextField.text = rowProject.projectName;
    self.thisProject = rowProject;
    NSMutableString *reportRef = [[NSMutableString alloc] init];
    [reportRef appendString:self.thisProject.projectNumber];
    [reportRef appendString:self.reportTypeRef];
    int count = 1;
    self.thisReport.project = self.thisProject;
    NSString *reportNumber = [NSString stringWithFormat:@"%03d", count];
    [reportRef appendString:reportNumber];
    self.reportRefTextField.text = reportRef;
    [self.projectTextField resignFirstResponder];
}

-(void)updateTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)self.dateTextField.inputView;
    NSDate *myDate = picker.date;
    self.thisReport.reportDate = myDate;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    NSString *prettyVersion = [dateFormat stringFromDate:myDate];
    self.dateTextField.text = prettyVersion;
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"saveReportSegue"]){
        [self commitValues];
    } else if([segue.identifier isEqualToString:@"viewItemsSegue"]){
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        simonReportItemsViewController *controller = (simonReportItemsViewController *)navController.topViewController;
        controller.thisReport = self.thisReport;
        controller.reportsDataSource = self.reportsDataSource;
        [self commitValues];
    } else if([segue.identifier isEqualToString:@"createPDFSegue"]){
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        simonPDFViewController *controller = (simonPDFViewController *)navController.topViewController;
        controller.thisReport = self.thisReport;
        controller.reportsDataSource = self.reportsDataSource;
        [self commitValues];
    }

}

- (void)commitValues {
    self.thisReport.project = self.thisProject;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    self.thisReport.reportDate = [dateFormat dateFromString:self.dateTextField.text];
    self.thisReport.supervisor = self.authorTextField.text;
    self.thisReport.reportRef = self.reportRefTextField.text;
    self.thisReport.weather = self.weatherTextField.text;
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    self.thisReport.temp = [NSDecimalNumber decimalNumberWithDecimal:[[f numberFromString:self.tempTextField.text] decimalValue]];
    if (self.tempTypeControl.selectedSegmentIndex == 1) {
        self.thisReport.tempType = [NSNumber numberWithBool:TRUE];
    } else {
        self.thisReport.tempType = [NSNumber numberWithBool:FALSE];
    }
    [self.reportsDataSource.coreDataInterface savetoDB];
}

- (void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alert.title isEqual:@"Report Type"]) {
        if (buttonIndex == 1) {
            self.thisReport.reportType = [NSNumber numberWithBool:false];
            [self makeReportTypeRef:[NSNumber numberWithBool:false]];
        } else {
            self.thisReport.reportType = [NSNumber numberWithBool:true];
            [self makeReportTypeRef:[NSNumber numberWithBool:true]];
        }
    } else if([alert.title isEqual:@"Delete Report"]) {
        if (buttonIndex == 1) {
            for (ReportItems *reportItem in self.thisReport.reportItems) {
                NSFileManager *manager = [NSFileManager defaultManager];
                NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSError *error = nil;
                for (Photo *photo in reportItem.photos) {
                    [manager removeItemAtPath:[docDirPath stringByAppendingPathComponent:photo.photoPath] error:&error];
                    [self.reportsDataSource.coreDataInterface.context deleteObject:photo];
                    [self.reportsDataSource.coreDataInterface savetoDB];
                }
                [self.reportsDataSource.coreDataInterface.context deleteObject:reportItem];
                [self.reportsDataSource.coreDataInterface savetoDB];
            }
            [self.reportsDataSource.coreDataInterface.context deleteObject:self.thisReport];
            [self.reportsDataSource.coreDataInterface savetoDB];
            self.thisReport = nil;
            [self performSegueWithIdentifier:@"exitSegue" sender:alert.title];
        } else {
        }
        
    }
}

- (void)makeReportTypeRef:(NSNumber *)isSVR {
    self.reportTypeRef = [[NSString alloc] init];
    if ([isSVR boolValue]) {
        self.reportTypeRef = @"/SVR/";
    } else {
        self.reportTypeRef = @"/PR/";
    }
}

- (IBAction)unwindToReportHeader:(UIStoryboardSegue *)segue
{
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0) {
        heightFraction = 0.0;
    } else if (heightFraction > 1.0) {
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    } else {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    viewFrame.size.height += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    viewFrame.size.height -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}
- (IBAction)deleteReportButton:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Report"
                                                    message:@"Are you sure you want to delete this report?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Delete", nil];
    [alert show];
}

- (IBAction)uploadReportItem:(UIButton *)sender {
    // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    HUD.labelText = @"Uploading Report";
    
    // Show the HUD while the provided method executes in a new thread
    [HUD showWhileExecuting:@selector(uploadReport) onTarget:self withObject:nil animated:YES];
}

- (IBAction)createPDFButton:(UIButton *)sender {
}

- (void) uploadReport {
    simonXMLRPCInterface *xmlrpcInterface = [[simonXMLRPCInterface alloc] init];
    [xmlrpcInterface UploadReport:self.thisReport Project:self.thisProject Datasource:self.reportsDataSource];
}
@end
