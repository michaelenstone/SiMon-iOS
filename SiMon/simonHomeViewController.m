//
//  simonHomeViewController.m
//  SIMon
//
//  Created by Michael Enstone on 28/02/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import "simonHomeViewController.h"

@interface simonHomeViewController () <MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
    long long expectedLength;
    long long currentLength;
    Reachability *internetReachableFoo;
}

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginFormVerticalConstraint;
@property (weak, nonatomic) IBOutlet UIButton *reportsButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *syncButton;
- (IBAction)loginButtonPress:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
- (IBAction)syncButtonPress:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
- (IBAction)registerButtonPress:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *homeLabel;
@property (weak, nonatomic) IBOutlet UIButton *visitSiteButton;
- (IBAction)visitSiteButtonPress:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *simonImageTopConstraint;
@property BOOL canReach;
@property BOOL isFirst;
@property simonProjectsDataSource *projectsDataSource;

@end

@implementation simonHomeViewController

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
    
    Reachability * reach = [Reachability reachabilityWithHostname:@"www.simon-app.com"];
    
    reach.reachableBlock = ^(Reachability*reach)
    {
        self.canReach = true;
    };
    
    reach.unreachableBlock = ^(Reachability*reach)
    {
        self.canReach = false;
    };
    
    [reach startNotifier];
    
    simonXMLRPCInterface *XMLRPCInterface = [[simonXMLRPCInterface alloc] init];
    self.projectsDataSource = [[simonProjectsDataSource alloc] init];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    self.visitSiteButton.hidden = true;
    
    if ([defaults objectForKey:@"Username_simon"] && [defaults objectForKey:@"Password_simon"] && self.canReach) {
        if ([XMLRPCInterface AuthenticateUser:false]) {
            self.usernameTextField.hidden = true;
            self.passwordTextField.hidden = true;
            self.registerButton.hidden = true;
            self.loginButton.hidden = true;
        } else {
            self.loginFormVerticalConstraint.constant = 16.0f;
            self.reportsButton.hidden = true;
            self.settingsButton.hidden = true;
            self.syncButton.hidden = true;
            self.usernameTextField.delegate = self;
            self.passwordTextField.delegate = self;
        }
    } else if ([defaults objectForKey:@"Username_simon"] && [defaults objectForKey:@"Password_simon"]) {
        self.usernameTextField.hidden = true;
        self.passwordTextField.hidden = true;
        self.registerButton.hidden = true;
        self.loginButton.hidden = true;
    } else {
        self.loginFormVerticalConstraint.constant = 16.0f;
        self.reportsButton.hidden = true;
        self.settingsButton.hidden = true;
        self.syncButton.hidden = true;
        self.usernameTextField.delegate = self;
        self.passwordTextField.delegate = self;
    }
    
    if (self.projectsDataSource.projects.count < 1 && !self.syncButton.isHidden) {
        self.reportsButton.enabled = false;
        self.homeLabel.text = @"Sync projects or add project at simon-app.com";
        self.visitSiteButton.hidden = false;
        self.isFirst = true;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)unwindToHome:(UIStoryboardSegue *)segue
{
    
}

- (IBAction)loginButtonPress:(id)sender {
    simonXMLRPCInterface *XMLRPCInterface = [[simonXMLRPCInterface alloc] init];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.usernameTextField.text forKey:@"Username_simon"];
    [defaults setObject:self.passwordTextField.text forKey:@"Password_simon"];
    if ([XMLRPCInterface AuthenticateUser:true]) {
        self.usernameTextField.hidden = true;
        self.passwordTextField.hidden = true;
        self.registerButton.hidden = true;
        self.loginButton.hidden = true;
        self.reportsButton.hidden = false;
        self.settingsButton.hidden = false;
        self.syncButton.hidden = false;
        self.reportsButton.enabled = false;
        self.homeLabel.text = @"Sync projects or add project at simon-app.com";
        self.visitSiteButton.hidden = false;
        self.isFirst = true;
        [self.view endEditing:true];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Error"
                                                        message:@"There was an error logging in: Bad username or Password"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
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
    self.simonImageTopConstraint.constant -= animatedDistance;
    
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
    self.simonImageTopConstraint.constant += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
        if (textField.tag == 1) {
            [self loginButtonPress:textField];
        }
    }
    return NO;
}

- (IBAction)syncButtonPress:(id)sender {
    // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    HUD.labelText = @"Syncing Projects and Locations";
    
    // Show the HUD while the provided method executes in a new thread
    [HUD showWhileExecuting:@selector(syncProjects) onTarget:self withObject:nil animated:YES];
    
}

- (void) syncProjects {
    simonXMLRPCInterface *XMLRPCInterface = [[simonXMLRPCInterface alloc] init];
    [XMLRPCInterface SyncProjects];
    if (self.isFirst) {
        self.reportsButton.enabled = true;
        self.homeLabel.text = @"Welcome to SiMon";
        self.visitSiteButton.hidden = true;
        self.isFirst = false;
    }
}

- (IBAction)registerButtonPress:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://www.simon-app.com/wp-login.php?action=register"];
    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
}

- (IBAction)visitSiteButtonPress:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://www.simon-app.com/wp-login.php"];
    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
}

@end
