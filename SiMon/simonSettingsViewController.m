//
//  simonSettingsViewController.m
//  SIMon
//
//  Created by Michael Enstone on 23/03/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import "simonSettingsViewController.h"

@interface simonSettingsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UISwitch *autoSynSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *pdfImage;
@property (weak, nonatomic) IBOutlet UIButton *setLogoButton;
- (IBAction)setLogoButtonClick:(id)sender;
@property (nonatomic) UIImagePickerController *imagePickerControl;
@property NSString *logoPath;
@end

@implementation simonSettingsViewController

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
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    self.logoPath = [defaults objectForKey:@"PDFLogoPath_simon"];
    self.usernameTextField.text = [defaults objectForKey:@"Username_simon"];
    self.usernameTextField.delegate = self;
    self.passwordTextField.text = [defaults objectForKey:@"Password_simon"];
    self.passwordTextField.delegate = self;
    self.nameTextField.text =[defaults objectForKey:@"Name_simon"];
    self.nameTextField.delegate = self;
    self.autoSynSwitch.on = [defaults boolForKey:@"autoSync_simon"];
    if ([self.logoPath length] > 4) {
        NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        UIImage *imageFromFile = [UIImage imageWithContentsOfFile:[docDirPath stringByAppendingPathComponent:self.logoPath]];
        self.pdfImage.image = imageFromFile;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"settingsSaveSegue"]){
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.usernameTextField.text forKey:@"Username_simon"];
        [defaults setObject:self.passwordTextField.text forKey:@"Password_simon"];
        [defaults setObject:self.nameTextField.text forKey:@"Name_simon"];
        [defaults setBool:self.autoSynSwitch.isOn forKey:@"autoSync_simon"];
        [defaults setObject:self.logoPath forKey:@"PDFLogoPath_simon"];
    }
}

- (IBAction)setLogoButtonClick:(id)sender {
    
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    self.imagePickerControl = imagePickerController;
    [self presentViewController:self.imagePickerControl animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self.pdfImage setImage:image];
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    // You can directly use this image but in case you want to store it some where
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath =  [docDirPath stringByAppendingPathComponent:@"simonPDFLogo.png"];
    // Get PNG data from following method
    NSData *myData = UIImagePNGRepresentation(image);
    // It is better to get JPEG data because jpeg data will store the location and other related information of image.
    [myData writeToFile:filePath atomically:YES];
    self.logoPath = @"simonPDFLogo.png";
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
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
@end
