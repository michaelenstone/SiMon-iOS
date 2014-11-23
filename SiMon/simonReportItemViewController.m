//
//  simonReportItemViewController.m
//  SIMon
//
//  Created by Michael Enstone on 13/02/2014.
//  Copyright (c) 2014 SiMon. All rights reserved.
//

#import "simonReportItemViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MLPAutoCompleteTextField.h"

@interface simonReportItemViewController ()
@property (weak) IBOutlet MLPAutoCompleteTextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextField *activityTextField;
@property (weak, nonatomic) IBOutlet UITextField *progressTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *onTimeSelect;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionConstraint;
@property UITableView *autocompleteTableView;
@property NSMutableArray *autocompleteSuggestions;
@property (weak, nonatomic) IBOutlet UIToolbar *photosToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addPhotoButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *takePhotoButton;
- (IBAction)addPhotoPress:(id)sender;
- (IBAction)takePhotoPress:(id)sender;
@property (nonatomic) UIImagePickerController *imagePickerControl;
- (IBAction)trashButton:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomConstraint;

@end

@implementation simonReportItemViewController

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
    self.locationTextField.delegate = self;
    self.locationTextField.autoCompleteDelegate = self;
    self.activityTextField.delegate = self;
    self.progressTextField.delegate = self;
    self.descriptionTextView.layer.borderWidth = 0.5f;
    self.descriptionTextView.layer.shadowColor = [[UIColor whiteColor] CGColor];
    self.descriptionTextView.layer.borderColor = [[UIColor colorWithRed:193/255.0
                                                                  green:193/255.0
                                                                   blue:193/255.0
                                                                  alpha:1.0] CGColor];
    self.descriptionTextView.layer.cornerRadius = 6;
    
    if (self.isSVR) {
        [self.progressTextField setHidden:TRUE];
        [self.onTimeSelect setHidden:TRUE];
        self.descriptionConstraint.constant = 8.0f;
    }
    self.descriptionTextView.delegate = self;
    self.photosToolbar.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    self.locationTextField.autoCompleteDataSource = self;
    [self.locationTextField setShowAutoCompleteTableWhenEditingBegins:YES];
    [self.locationTextField setAutoCompleteTableBackgroundColor:[UIColor colorWithWhite:1 alpha:1]];
    [self.locationTextField setAutoCompleteTableAppearsAsKeyboardAccessory:true];
    self.locationTextField.applyBoldEffectToAutoCompleteSuggestions = NO;
    if (!self.thisReportItem) {
        self.thisReportItem = [NSEntityDescription insertNewObjectForEntityForName:@"ReportItems" inManagedObjectContext:self.reportsDataSource.coreDataInterface.context];
    } else {
        if (!self.thisLocation) {
            self.thisLocation = self.thisReportItem.location;
        }
        self.locationTextField.text = self.thisLocation.locationName;
        self.activityTextField.text = self.thisReportItem.activityOrItem;
        self.progressTextField.text = [[self.thisReportItem.progress stringValue] stringByAppendingString:@"%"];
        if ([self.thisReportItem.onTime isEqualToString: @"Ahead"]) {
            self.onTimeSelect.selectedSegmentIndex = 0;
        } else if ([self.thisReportItem.onTime isEqualToString: @"On Time"]) {
            self.onTimeSelect.selectedSegmentIndex = 1;
        } else {
            self.onTimeSelect.selectedSegmentIndex = 2;
        }
        self.descriptionTextView.text = self.thisReportItem.itemDescription;
    }
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.dataSource = self;
    [self registerForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"saveReportItemSegue"]){
        if (![self.locationTextField.text isEqualToString:self.thisLocation.locationName] ) {
            self.thisReportItem.location = self.thisLocation;
        }
        if (!self.thisLocation && [self.locationTextField.text length]>1) {
            Locations *newLocation = [NSEntityDescription insertNewObjectForEntityForName:@"Locations" inManagedObjectContext:self.reportsDataSource.coreDataInterface.context];
            newLocation.locationName = self.locationTextField.text;
            newLocation.project = self.thisProject;
            self.thisReportItem.location = newLocation;
            self.thisLocation = newLocation;
            [self.reportsDataSource.coreDataInterface savetoDB];
        }
        self.thisReportItem.location = self.thisLocation;
        self.thisReportItem.activityOrItem = self.activityTextField.text;
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        self.thisReportItem.progress = [NSDecimalNumber decimalNumberWithString:self.progressTextField.text];
        if (self.onTimeSelect.selectedSegmentIndex == 0) {
            self.thisReportItem.onTime = @"Ahead";
        } else if (self.onTimeSelect.selectedSegmentIndex == 1) {
            self.thisReportItem.onTime = @"On Time";
        } else {
            self.thisReportItem.onTime = @"Behind";
        }
        self.thisReportItem.itemDescription = self.descriptionTextView.text;
        NSMutableSet *mutableSet = [NSMutableSet setWithSet:self.thisReport.reportItems];
        [mutableSet addObject:self.thisReportItem];
        self.thisReport.reportItems = mutableSet;
        [self.reportsDataSource.coreDataInterface savetoDB];
    }
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

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
    CGRect textFieldRect = [self.view.window convertRect:textView.bounds fromView:textView];
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

- (void)textViewDidEndEditing:(UITextView *)textView
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

- (IBAction)addPhotoPress:(id)sender {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)takePhotoPress:(id)sender {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
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
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    // You can directly use this image but in case you want to store it some where
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSDate *myDate = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"_yyyy-MM-dd_HH-mm-ss"];
    NSString *prettyVersion = [dateFormat stringFromDate:myDate];
    NSMutableString *filename = [NSMutableString stringWithString:@"IMG_"];
    [filename appendString:[self sanitizeFileNameString:self.thisProject.projectNumber]];
    [filename appendString:prettyVersion];
    [filename appendString:@".jpg"];
    NSString *filePath =  [docDirPath stringByAppendingPathComponent:filename];
    
    // Get PNG data from following method
    NSData *myData = UIImageJPEGRepresentation(image, 0.9);
    // It is better to get JPEG data because jpeg data will store the location and other related information of image.
    [myData writeToFile:filePath atomically:YES];
    
    Photo *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:self.reportsDataSource.coreDataInterface.context];
    newPhoto.reportItem = self.thisReportItem;
    newPhoto.photoPath = filename;
    newPhoto.location = self.thisLocation;
    NSMutableSet *mutableSet = [NSMutableSet setWithSet:self.thisReportItem.photos];
    [mutableSet addObject:newPhoto];
    self.thisReportItem.photos = mutableSet;
    [self.reportsDataSource.coreDataInterface savetoDB];
    [self.photoCollectionView reloadData];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
 possibleCompletionsForString:(NSString *)string
            completionHandler:(void (^)(NSArray *))handler
{
        
        NSArray *completions;
        completions = [self.thisProject.locations allObjects];
        handler(completions);
    
}

- (BOOL)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
          shouldConfigureCell:(UITableViewCell *)cell
       withAutoCompleteString:(NSString *)autocompleteString
         withAttributedString:(NSAttributedString *)boldedString
        forAutoCompleteObject:(id<MLPAutoCompletionObject>)autocompleteObject
            forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    //This is your chance to customize an autocomplete tableview cell before it appears in the autocomplete tableview
    
    return YES;
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
  didSelectAutoCompleteString:(NSString *)selectedString
       withAutoCompleteObject:(id<MLPAutoCompletionObject>)selectedObject
            forRowAtIndexPath:(NSIndexPath *)indexPath {
    for (Locations *loopLocation in self.thisProject.locations) {
        if ([loopLocation.locationName isEqualToString:selectedString]) {
            self.thisLocation = loopLocation;
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.thisReportItem.photos.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImageView *photoImageView = (UIImageView *)[cell viewWithTag:100];
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    Photo *thisPhoto = [[self.thisReportItem.photos allObjects] objectAtIndex:indexPath.row];
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[docDirPath stringByAppendingPathComponent:thisPhoto.photoPath]];
    [photoImageView setImage:img];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.photoToDelete = [[self.thisReportItem.photos allObjects] objectAtIndex:indexPath.item];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Photo"
                                                    message:@"Would you like to delete this photo?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Delete", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alert.title isEqual:@"Delete Photo"]) {
        if (buttonIndex == 1) {
            NSMutableSet *mutableSet = [NSMutableSet setWithSet:self.thisReportItem.photos];
            [mutableSet removeObject:self.photoToDelete];
            self.thisReportItem.photos = mutableSet;
            [self.reportsDataSource.coreDataInterface.context deleteObject:self.photoToDelete];
            [self.reportsDataSource.coreDataInterface savetoDB];
            [self.photoCollectionView reloadData];
        } else {
        }
    } else if ([alert.title isEqual:@"Delete Report Item"]) {
        if (buttonIndex == 1) {
            NSFileManager *manager = [NSFileManager defaultManager];
            NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSError *error = nil;
            for (Photo *photo in self.thisReportItem.photos) {
                [manager removeItemAtPath:[docDirPath stringByAppendingPathComponent:photo.photoPath] error:&error];
                [self.reportsDataSource.coreDataInterface.context deleteObject:photo];
                [self.reportsDataSource.coreDataInterface savetoDB];
            }
            [self.reportsDataSource.coreDataInterface.context deleteObject:self.thisReportItem];
            [self.reportsDataSource.coreDataInterface savetoDB];
            self.thisReport = nil;
            [self performSegueWithIdentifier:@"exitSegue" sender:alert.title];
        } else {
        }
    }
}
- (IBAction)trashButton:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Report Item"
                                                    message:@"Would you like to delete this item?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Delete", nil];
    [alert show];
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardSizeChanged:)
                                                 name:UIKeyboardDidChangeFrameNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.keyboardVisible = true;
    
    if (!self.locationTextField.isFirstResponder) {
        self.toolbarBottomConstraint.constant = kbSize.height;
    }
}

// Called when the UIKeyboardDidChangeFrameNotification is sent.
- (void)keyboardSizeChanged:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    if (!self.locationTextField.isFirstResponder && self.keyboardVisible) {
        self.toolbarBottomConstraint.constant = kbSize.height;
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.toolbarBottomConstraint.constant = 0;
    self.keyboardVisible = false;
}


- (NSString *)sanitizeFileNameString:(NSString *)fileName {
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>"];
    return [[fileName componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@"-"];
}
@end
