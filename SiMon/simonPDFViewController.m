//
//  simonPDFViewController.m
//  SIMon
//
//  Created by Michael Enstone on 19/10/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import "simonPDFViewController.h"

@interface simonPDFViewController () <MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)rebuildPDF:(id)sender;
- (IBAction)emailPDF:(id)sender;

@end

@implementation simonPDFViewController

- (void)viewDidLoad
{
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    if (!self.thisReport.reportPDF) {
        NSString* fileName = [self getPDFFileName];
        simonPDFRenderer *pdfRenderer = [[simonPDFRenderer alloc] init];
        [pdfRenderer drawPDF:[docDirPath stringByAppendingPathComponent:fileName] withReport:self.thisReport];
        self.thisReport.reportPDF = fileName;
        [self.reportsDataSource.coreDataInterface savetoDB];
    }
    [self showPDFFile:[docDirPath stringByAppendingPathComponent:self.thisReport.reportPDF]];
    
    [super viewDidLoad];
}
-(
  void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Assuming self.webView is our UIWebView
    // We go though all sub views of the UIWebView and set their backgroundColor to white
    UIView *v = self.webView;
    while (v) {
        v.backgroundColor = [UIColor whiteColor];
        v = [v.subviews firstObject];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showPDFFile:(NSString *) filePath
{
    
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView setScalesPageToFit:YES];
    [self.webView loadRequest:request];
}

-(NSString*)getPDFFileName
{
    NSMutableString *text = [[NSMutableString alloc] init];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy_"];
    [text appendString:[dateFormat stringFromDate:[NSDate date]]];
    [text appendString:[self sanitizeFileNameString:self.thisReport.reportRef]];
    [text appendString:@".pdf"];
    return text;
}

- (NSString *)sanitizeFileNameString:(NSString *)fileName {
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>"];
    return [[fileName componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@"-"];
}

- (IBAction)rebuildPDF:(id)sender {
    NSString* fileName = [self getPDFFileName];
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    simonPDFRenderer *pdfRenderer = [[simonPDFRenderer alloc] init];
    [pdfRenderer drawPDF:[docDirPath stringByAppendingPathComponent:fileName] withReport:self.thisReport];
    self.thisReport.reportPDF = fileName;
    [self.reportsDataSource.coreDataInterface savetoDB];
    [self showPDFFile:[docDirPath stringByAppendingPathComponent:self.thisReport.reportPDF]];
}

- (IBAction)emailPDF:(id)sender {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    NSMutableString *text = [[NSMutableString alloc] init];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    if (self.thisReport.reportType) {
        [text appendString:@"Site Visit Report - "];
    } else {
        [text appendString:@"Progress Report - "];
    }
    [text appendString:[dateFormat stringFromDate:self.thisReport.reportDate]];
    
    [picker setSubject:text];
    
    // Set up recipients
    // NSArray *toRecipients = [NSArray arrayWithObject:@"first@example.com"];
    // NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
    // NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"];
    
    // [picker setToRecipients:toRecipients];
    // [picker setCcRecipients:ccRecipients];
    // [picker setBccRecipients:bccRecipients];
    
    // Attach an image to the email
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSData *myData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[docDirPath stringByAppendingPathComponent:self.thisReport.reportPDF]]];
    [picker addAttachmentData:myData mimeType:@"application/pdf" fileName:[self.thisReport.reportPDF lastPathComponent]];
    
    // Fill out the email body text
    NSString *emailBody = @"See Report attached";
    [picker setMessageBody:emailBody isHTML:NO];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
