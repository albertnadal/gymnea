//
//  EditProfileViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 14/09/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "EditProfileViewController.h"
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "GEALabel+Gymnea.h"
#import "UIImage+Resize.h"
#import "GymneaWSClient.h"
#import "MBProgressHUD.h"
#import "EditPersonalProfileForm.h"
#import "EditEmailForm.h"
#import "GEAAuthentication.h"
#import "GEAAuthenticationKeychainStore.h"

@interface EditProfileViewController ()
{
    UIPickerView *birthdatePickerView;
    UIToolbar *birthdatePickerToolbar;
    BOOL ageSelected;
    
    UIPickerView *weightPickerView;
    UIToolbar *weightPickerToolbar;
    BOOL weightSelected;
    
    UIPickerView *heightPickerView;
    UIToolbar *heightPickerToolbar;
    BOOL heightSelected;
    
    UIPickerView *genderPickerView;
    UIToolbar *genderPickerToolbar;
    BOOL genderSelected;
}

@property (nonatomic, weak) IBOutlet UITextField *firstNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *lastNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *emailAddressTextField;
@property (nonatomic, weak) IBOutlet UITextField *ageTextField;
@property (nonatomic, weak) IBOutlet UITextField *weightTextField;
@property (nonatomic, weak) IBOutlet UITextField *heightTextField;
@property (nonatomic, weak) IBOutlet UITextField *genderTextField;
@property (nonatomic, weak) IBOutlet UIButton *ageButton;
@property (nonatomic, retain) UIPickerView *birthdatePickerView;
@property (nonatomic, retain) UIToolbar *birthdatePickerToolbar;
@property (nonatomic) BOOL ageSelected;
@property (nonatomic, weak) IBOutlet UIButton *weightButton;
@property (nonatomic, retain) UIPickerView *weightPickerView;
@property (nonatomic, retain) UIToolbar *weightPickerToolbar;
@property (nonatomic) BOOL weightSelected;
@property (nonatomic, weak) IBOutlet UIButton *heightButton;
@property (nonatomic, retain) UIPickerView *heightPickerView;
@property (nonatomic, retain) UIToolbar *heightPickerToolbar;
@property (nonatomic) BOOL heightSelected;
@property (nonatomic, weak) IBOutlet UIButton *genderButton;
@property (nonatomic, retain) UIPickerView *genderPickerView;
@property (nonatomic, retain) UIToolbar *genderPickerToolbar;
@property (nonatomic) BOOL genderSelected;
@property (nonatomic) int day;
@property (nonatomic) int month;
@property (nonatomic) int year;
@property (nonatomic) double weight;
@property (nonatomic) BOOL weightIsMetricUnits;
@property (nonatomic) int heightCentimeters;
@property (nonatomic) int heightFoot;
@property (nonatomic) int heightInches;
@property (nonatomic) BOOL heightIsMetricUnits;
@property (nonatomic) NSString *gender;
@property (nonatomic, retain) IBOutlet UILabel *viewTitle;
@property (nonatomic, retain) IBOutlet UIImageView *userAvatar;
@property (nonatomic, retain) IBOutlet UIView *userAvatarView;
@property (nonatomic, retain) UIImage *lastPhotoTaken;
@property (nonatomic, retain) MBProgressHUD *loadingIndicatorHud;

- (IBAction)cancelEditProfile:(id)sender;
- (IBAction)showChangePictureOptionsMenu:(id)sender;
- (void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
- (IBAction)showBirthdateSelector:(id)sender;
- (IBAction)showWeightSelector:(id)sender;
- (IBAction)showHeightSelector:(id)sender;
- (IBAction)showGenderSelector:(id)sender;
- (IBAction)hideSelectors:(id)sender;
- (IBAction)hideKeyboard:(id)sender;
- (void)hideAllKeyboards;
- (IBAction)sendEditedUserDataRequest:(id)sender;
- (void)sendEditedUnitsAndMeasuresRequest;
- (void)sendEditedEmailRequest;
- (void)sendEditedAvatarRequest;
- (void)createBirthdatePicker;
- (void)createWeightPicker;
- (void)createGenderPicker;
- (void)birthdayDoneButtonPressed;
- (void)weightDoneButtonPressed;
- (void)heightDoneButtonPressed;
- (void)genderDoneButtonPressed;

@end

@implementation EditProfileViewController

@synthesize birthdatePickerView;
@synthesize birthdatePickerToolbar;
@synthesize ageSelected;
@synthesize weightPickerView;
@synthesize weightPickerToolbar;
@synthesize weightSelected;
@synthesize heightPickerView;
@synthesize heightPickerToolbar;
@synthesize heightSelected;
@synthesize genderPickerView;
@synthesize genderPickerToolbar;
@synthesize genderSelected;

- (void)viewDidLoad {

    [super viewDidLoad];

    self.screenName = @"EditProfileViewController";

    GEALabel *titleModal = [[GEALabel alloc] initWithText:self.viewTitle.text fontSize:18.0f frame:self.viewTitle.frame];
    [self.view addSubview:titleModal];
    [self.viewTitle removeFromSuperview];

    // Make the user picture full rounded
    UIBezierPath *userPictureViewShadowPath = [UIBezierPath bezierPathWithRect:self.userAvatarView.bounds];
    self.userAvatarView.layer.shadowPath = userPictureViewShadowPath.CGPath;
    self.userAvatarView.layer.rasterizationScale = 2;
    self.userAvatarView.layer.cornerRadius = self.userAvatarView.frame.size.width / 2.0f;;
    self.userAvatarView.layer.masksToBounds = YES;

    self.lastPhotoTaken = nil;

    self.birthdatePickerView = nil;
    
    NSDate *currentDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate];
    
    self.month = (int)[components month];
    self.day = (int)[components day];
    self.year = (int)[components year];
    
    self.ageSelected = NO;
    self.weightSelected = NO;
    self.heightSelected = NO;
    self.genderSelected = NO;
    
    self.weight = 0.0f;
    self.weightIsMetricUnits = NO;
    
    self.heightCentimeters = 0;
    self.heightFoot = 0;
    self.heightInches = 0;
    self.heightIsMetricUnits = NO;
    
    self.gender = @"";

    self.loadingIndicatorHud = nil;

    [[GymneaWSClient sharedInstance] requestLocalUserInfoWithCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, UserInfo *userInfo) {

        NSLog(@"USER INFO name: %@ | lastname: %@ | birthdate: %@", userInfo.firstName, userInfo.lastName, userInfo.birthDate);

        NSDateComponents* birthdateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:userInfo.birthDate];

        self.month = (int)[birthdateComponents month];
        self.day = (int)[birthdateComponents day];
        self.year = (int)[birthdateComponents year];

        self.weight = userInfo.weightKilograms;
        self.weightIsMetricUnits = userInfo.weightIsMetric;

        self.heightCentimeters = userInfo.heightCentimeters;
        self.heightIsMetricUnits = userInfo.heightIsMetric;

        float inches = (userInfo.heightCentimeters * 0.39370078740157477f);
        self.heightFoot = (int)(inches / 12);
        self.heightInches = fmodf(inches, 12);

        self.gender = [userInfo gender];

        // Calculate the user age from his birthdate
        NSDate *today = [[NSDate alloc] init];
        NSCalendar *sysCalendar = [NSCalendar currentCalendar];
        unsigned int unitFlags = NSYearCalendarUnit;
        NSDate *differentialDate = [[NSDate alloc] initWithTimeInterval:[[userInfo birthDate] timeIntervalSinceNow] sinceDate:today];
        NSDateComponents *userAgeComponents = [sysCalendar components:unitFlags fromDate:today  toDate:differentialDate  options:0];
        
        // Calculate the user height (cm <-> ft/in)
        float centimeters = [userInfo heightCentimeters];
        NSString *heightString = nil;
        
        if([userInfo heightIsMetric]) {
            heightString = [NSString stringWithFormat:@"%.0fcm", centimeters];
        } else {
            float inches = (centimeters * 0.39370078740157477f);
            int feet = (int)(inches / 12);
            inches = fmodf(inches, 12);
            heightString = [NSString stringWithFormat:@"%d' %.2f\"", feet, inches];
        }

        [self.heightTextField setText:heightString];

        // Calculate the user weight
        float kilograms = [userInfo weightKilograms];
        NSString *weightString = nil;
        
        if([userInfo weightIsMetric]) {
            weightString = [NSString stringWithFormat:@"%.1fkg", kilograms];
        } else {
            weightString = [NSString stringWithFormat:@"%.1flbs", (kilograms * 2.20462262f)];
        }

        [self.weightTextField setText:weightString];

        [self.ageTextField setText:[NSString stringWithFormat:@"%d years", abs((int)[userAgeComponents year])]];

        [self.genderTextField setText:[userInfo.gender capitalizedString]];

        [self.firstNameTextField setText:[userInfo firstName]];

        [self.lastNameTextField setText:[userInfo lastName]];

        [self.emailAddressTextField setText:[userInfo email]];

        if(userInfo.picture) {
            [self.userAvatar setImage:[UIImage imageWithData:userInfo.picture]];
        }

    }];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self createWeightPicker];
    [self createBirthdatePicker];
    [self createHeightPicker];
    [self createGenderPicker];
}

- (void)hideAllKeyboards
{
    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
    [self.emailAddressTextField resignFirstResponder];
    [self.genderTextField resignFirstResponder];
    [self.ageTextField resignFirstResponder];
    [self.weightTextField resignFirstResponder];
    [self.heightTextField resignFirstResponder];
}

- (IBAction)hideKeyboard:(id)sender
{
    if([sender respondsToSelector:@selector(resignFirstResponder)]) {
        [(UITextField *)sender resignFirstResponder];
    }
}

- (IBAction)hideSelectors:(id)sender
{
    [self.genderPickerToolbar setHidden:YES];
    [self.genderPickerView setHidden:YES];
    
    [self.birthdatePickerToolbar setHidden:YES];
    [self.birthdatePickerView setHidden:YES];
    
    [self.weightPickerToolbar setHidden:YES];
    [self.weightPickerView setHidden:YES];
    
    [self.heightPickerToolbar setHidden:YES];
    [self.heightPickerView setHidden:YES];
}

- (IBAction)showBirthdateSelector:(id)sender
{
    if(self.birthdatePickerView == nil) {
        [self createBirthdatePicker];
    }

    [self hideAllKeyboards];

    NSDateComponents* components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    int currentYear = (int)[components year];

    [self.birthdatePickerView selectRow:(self.day - 1) inComponent:0 animated:NO];
    [self.birthdatePickerView selectRow:(self.month - 1) inComponent:1 animated:NO];
    [self.birthdatePickerView selectRow:(currentYear - self.year) inComponent:2 animated:NO];

    [self.genderPickerToolbar setHidden:YES];
    [self.genderPickerView setHidden:YES];
    
    [self.birthdatePickerToolbar setHidden:NO];
    [self.birthdatePickerView setHidden:NO];
    
    [self.weightPickerToolbar setHidden:YES];
    [self.weightPickerView setHidden:YES];
    
    [self.heightPickerToolbar setHidden:YES];
    [self.heightPickerView setHidden:YES];
}

- (IBAction)showWeightSelector:(id)sender
{
    [self hideAllKeyboards];
    [self hideSelectors:nil];

    if(self.weightIsMetricUnits) {
        // KG
        [self.weightPickerView selectRow:1 inComponent:2 animated:NO];
    } else {
        // LBS
        [self.weightPickerView selectRow:0 inComponent:2 animated:NO];
    }

    int weightIntegerValue = (int)self.weight;
    [self.weightPickerView selectRow:weightIntegerValue - 30 inComponent:0 animated:NO];

    NSString *str = [NSString stringWithFormat:@"%f",self.weight];
    NSArray *arr = [str componentsSeparatedByString:@"."];
    int weightDecimalValue = [[[arr lastObject] substringWithRange:NSMakeRange(0, 1)] intValue];
    [self.weightPickerView selectRow:weightDecimalValue inComponent:1 animated:NO];

    [self.genderPickerToolbar setHidden:YES];
    [self.genderPickerView setHidden:YES];
    
    [self.weightPickerToolbar setHidden:NO];
    [self.weightPickerView setHidden:NO];
    
    [self.birthdatePickerToolbar setHidden:YES];
    [self.birthdatePickerView setHidden:YES];
    
    [self.heightPickerToolbar setHidden:YES];
    [self.heightPickerView setHidden:YES];
}

- (IBAction)showHeightSelector:(id)sender
{
    if(self.heightPickerView == nil) {
        [self createHeightPicker];
    }

    [self hideAllKeyboards];

    if(self.heightIsMetricUnits) {
        // m/cm
        [self.heightPickerView selectRow:1 inComponent:2 animated:NO];

        int heightIntegerValue = (int)(self.heightCentimeters / 100);
        [self.heightPickerView selectRow:heightIntegerValue - 1 inComponent:0 animated:NO];

        NSString *str = [NSString stringWithFormat:@"%f",(self.heightCentimeters / 100.0f)];
        NSArray *arr = [str componentsSeparatedByString:@"."];
        int heightDecimalValue = [[[arr lastObject] substringWithRange:NSMakeRange(0, 2)] intValue];
        [self.heightPickerView selectRow:heightDecimalValue inComponent:1 animated:NO];

    } else {
        // ft/in
        [self.heightPickerView selectRow:0 inComponent:2 animated:NO];

        [self.heightPickerView selectRow:self.heightFoot - 1 inComponent:0 animated:NO];
        [self.heightPickerView selectRow:self.heightInches inComponent:1 animated:NO];

    }

    [self.genderPickerToolbar setHidden:YES];
    [self.genderPickerView setHidden:YES];

    [self.heightPickerToolbar setHidden:NO];
    [self.heightPickerView setHidden:NO];

    [self.weightPickerToolbar setHidden:YES];
    [self.weightPickerView setHidden:YES];

    [self.birthdatePickerToolbar setHidden:YES];
    [self.birthdatePickerView setHidden:YES];
}

- (IBAction)showGenderSelector:(id)sender
{
    if(self.genderPickerView == nil) {
        [self createGenderPicker];
    }
    
    [self hideAllKeyboards];

    // Set selected the current selected gender option
    if([[self.gender lowercaseString] isEqualToString: @"male"]) {
        // Male
        [self.genderPickerView selectRow:0 inComponent:0 animated:NO];
    } else {
        // Female
        [self.genderPickerView selectRow:1 inComponent:0 animated:NO];
    }

    [self.genderPickerToolbar setHidden:NO];
    [self.genderPickerView setHidden:NO];
    
    [self.heightPickerToolbar setHidden:YES];
    [self.heightPickerView setHidden:YES];
    
    [self.weightPickerToolbar setHidden:YES];
    [self.weightPickerView setHidden:YES];
    
    [self.birthdatePickerToolbar setHidden:YES];
    [self.birthdatePickerView setHidden:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.firstNameTextField) {
        [self.firstNameTextField resignFirstResponder];
        [self.lastNameTextField becomeFirstResponder];
        
    } else if(textField == self.lastNameTextField) {
        [self.lastNameTextField resignFirstResponder];
        [self.emailAddressTextField becomeFirstResponder];
        
    } else if(textField == self.emailAddressTextField) {
        [self.emailAddressTextField resignFirstResponder];

        if(self.genderPickerView == nil) {
            [self createGenderPicker];
        }
        
        [self.genderPickerToolbar setHidden:NO];
        [self.genderPickerView setHidden:NO];
    }
    
    //    [self sendSignUpRequest];
    
    return TRUE;
}

- (void)createBirthdatePicker
{
    self.birthdatePickerView = [[UIPickerView alloc] init];
    CGRect birthdatePickerViewFrame = self.birthdatePickerView.frame;
    CGFloat pickerHeight = birthdatePickerViewFrame.size.height;
    birthdatePickerViewFrame.origin.y = self.view.frame.size.height - pickerHeight;
    birthdatePickerViewFrame.origin.x = 0.0f;
    self.birthdatePickerView.frame = birthdatePickerViewFrame;
    
    [self.birthdatePickerView setDataSource: self];
    [self.birthdatePickerView setDelegate: self];
    self.birthdatePickerView.showsSelectionIndicator = YES;
    
    self.birthdatePickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    birthdatePickerToolbar.barStyle = UIBarStyleDefault;
    [birthdatePickerToolbar sizeToFit];
    
    UILabel *setBirtdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [setBirtdayLabel setTextAlignment:NSTextAlignmentCenter];
    [setBirtdayLabel setText:@"Set Birthdate"];
    [birthdatePickerToolbar addSubview:setBirtdayLabel];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(birthdayDoneButtonPressed)];
    
    [birthdatePickerToolbar setItems:@[flexSpace, doneBtn] animated:YES];
    
    CGRect pickerToolbarFrame = birthdatePickerToolbar.frame;
    pickerToolbarFrame.origin.y = birthdatePickerViewFrame.origin.y - pickerToolbarFrame.size.height;
    birthdatePickerToolbar.frame = pickerToolbarFrame;
    
    [self.birthdatePickerToolbar setHidden:YES];
    [self.birthdatePickerView setHidden:YES];
    
    [self.view addSubview:birthdatePickerView];
    [self.view addSubview:birthdatePickerToolbar];
}

- (void)createWeightPicker
{
    self.weightPickerView = [[UIPickerView alloc] init];
    CGRect weightPickerViewFrame = self.weightPickerView.frame;
    CGFloat pickerHeight = weightPickerViewFrame.size.height;
    weightPickerViewFrame.origin.y = self.view.frame.size.height - pickerHeight;
    weightPickerViewFrame.origin.x = 0.0f;
    self.weightPickerView.frame = weightPickerViewFrame;
    
    [self.weightPickerView setDataSource: self];
    [self.weightPickerView setDelegate: self];
    self.weightPickerView.showsSelectionIndicator = YES;
    
    self.weightPickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    weightPickerToolbar.barStyle = UIBarStyleDefault;
    [weightPickerToolbar sizeToFit];
    
    UILabel *setWeightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [setWeightLabel setTextAlignment:NSTextAlignmentCenter];
    [setWeightLabel setText:@"Set Weight"];
    [weightPickerToolbar addSubview:setWeightLabel];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(weightDoneButtonPressed)];
    
    [weightPickerToolbar setItems:@[flexSpace, doneBtn] animated:YES];
    
    CGRect pickerToolbarFrame = weightPickerToolbar.frame;
    pickerToolbarFrame.origin.y = weightPickerViewFrame.origin.y - pickerToolbarFrame.size.height;
    weightPickerToolbar.frame = pickerToolbarFrame;
    
    [self.weightPickerToolbar setHidden:YES];
    [self.weightPickerView setHidden:YES];
    
    [self.view addSubview:weightPickerView];
    [self.view addSubview:weightPickerToolbar];
}

- (void)createHeightPicker
{
    self.heightPickerView = [[UIPickerView alloc] init];
    CGRect heightPickerViewFrame = self.heightPickerView.frame;
    CGFloat pickerHeight = heightPickerViewFrame.size.height;
    heightPickerViewFrame.origin.y = self.view.frame.size.height - pickerHeight;
    heightPickerViewFrame.origin.x = 0.0f;
    self.heightPickerView.frame = heightPickerViewFrame;
    
    [self.heightPickerView setDataSource: self];
    [self.heightPickerView setDelegate: self];
    self.heightPickerView.showsSelectionIndicator = YES;
    
    self.heightPickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    heightPickerToolbar.barStyle = UIBarStyleDefault;
    [heightPickerToolbar sizeToFit];
    
    UILabel *setHeightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [setHeightLabel setTextAlignment:NSTextAlignmentCenter];
    [setHeightLabel setText:@"Set Height"];
    [heightPickerToolbar addSubview:setHeightLabel];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(heightDoneButtonPressed)];
    
    [heightPickerToolbar setItems:@[flexSpace, doneBtn] animated:YES];
    
    CGRect pickerToolbarFrame = heightPickerToolbar.frame;
    pickerToolbarFrame.origin.y = heightPickerViewFrame.origin.y - pickerToolbarFrame.size.height;
    heightPickerToolbar.frame = pickerToolbarFrame;
    
    [self.heightPickerToolbar setHidden:YES];
    [self.heightPickerView setHidden:YES];
    
    [self.view addSubview:heightPickerView];
    [self.view addSubview:heightPickerToolbar];
}

- (void)createGenderPicker
{
    self.genderPickerView = [[UIPickerView alloc] init];
    CGRect genderPickerViewFrame = self.genderPickerView.frame;
    CGFloat pickerHeight = genderPickerViewFrame.size.height;
    genderPickerViewFrame.origin.y = self.view.frame.size.height - pickerHeight;
    genderPickerViewFrame.origin.x = 0.0f;
    self.genderPickerView.frame = genderPickerViewFrame;
    
    [self.genderPickerView setDataSource: self];
    [self.genderPickerView setDelegate: self];
    self.genderPickerView.showsSelectionIndicator = YES;
    
    self.genderPickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    genderPickerToolbar.barStyle = UIBarStyleDefault;
    [genderPickerToolbar sizeToFit];
    
    UILabel *setGenderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [setGenderLabel setTextAlignment:NSTextAlignmentCenter];
    [setGenderLabel setText:@"Set Gender"];
    [genderPickerToolbar addSubview:setGenderLabel];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(genderDoneButtonPressed)];
    
    [genderPickerToolbar setItems:@[flexSpace, doneBtn] animated:YES];
    
    CGRect pickerToolbarFrame = genderPickerToolbar.frame;
    pickerToolbarFrame.origin.y = genderPickerViewFrame.origin.y - pickerToolbarFrame.size.height;
    genderPickerToolbar.frame = pickerToolbarFrame;
    
    [self.genderPickerToolbar setHidden:YES];
    [self.genderPickerView setHidden:YES];
    
    [self.view addSubview:genderPickerView];
    [self.view addSubview:genderPickerToolbar];
    
    self.gender = @"male";
    
    [self.genderButton setTitle:[self.gender capitalizedString] forState:UIControlStateNormal];
    [self.genderButton setBackgroundColor:[UIColor whiteColor]];
    
    self.genderSelected = YES;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    
    if(pickerView == self.birthdatePickerView)
    {
        if(component == 1) {
            //MONTH
            self.month = (int)row + 1; // 1 => January...12 => December
            [pickerView reloadComponent:0];
        } else if(component == 2) {
            //YEAR
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *components = [gregorian components:NSYearCalendarUnit fromDate:[NSDate date]];
            self.year = (int)[components year] - (int)row;
        }
        
        //DAY
        self.day = (int)[pickerView selectedRowInComponent:0] + 1;
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        NSDate *selectedDate = [df dateFromString:[NSString stringWithFormat:@"%d-%02d-%02d", self.year, self.month, self.day]];
        NSTimeInterval todaysDiff = [selectedDate timeIntervalSinceNow];
        
        NSDate *today = [[NSDate alloc] init];
        
        NSCalendar *sysCalendar = [NSCalendar currentCalendar];
        unsigned int unitFlags = NSYearCalendarUnit;
        NSDate *differentialDate = [[NSDate alloc] initWithTimeInterval:todaysDiff sinceDate:today];
        NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:today  toDate:differentialDate  options:0];
        
        [self.ageButton setTitle:[NSString stringWithFormat:@"%d years", abs((int)[breakdownInfo year])] forState:UIControlStateNormal];
        [self.ageButton setBackgroundColor:[UIColor whiteColor]];

        self.ageSelected = YES;
    }
    else if(pickerView == self.weightPickerView)
    {
        if(component == 2) {
            
            if(row == 0) {
                self.weightIsMetricUnits = NO;
            } else {
                self.weightIsMetricUnits = YES;
            }
            
            [pickerView reloadComponent:0];
            [pickerView reloadComponent:1];
        }

        double weightDecimals = [[NSString stringWithFormat:@"%.1f", [pickerView selectedRowInComponent:1]/10.0f] floatValue];

        if(self.weightIsMetricUnits) {
            self.weight = ([pickerView selectedRowInComponent:0] + 30.0f) + weightDecimals;
            [self.weightButton setTitle:[NSString stringWithFormat:@"%.1f kg", self.weight] forState:UIControlStateNormal];

        } else {
            self.weight = ([pickerView selectedRowInComponent:0] + 30.0f) + weightDecimals;
            [self.weightButton setTitle:[NSString stringWithFormat:@"%.1f lbs", self.weight] forState:UIControlStateNormal];

        }

        [self.weightButton setBackgroundColor:[UIColor whiteColor]];
        self.weightSelected = YES;
    }
    else if(pickerView == self.heightPickerView)
    {
        if(component == 2) {
            
            if(row == 0) {
                self.heightIsMetricUnits = NO;
            } else {
                self.heightIsMetricUnits = YES;
            }
            
            [pickerView reloadComponent:0];
            [pickerView reloadComponent:1];
        }
        
        if(self.heightIsMetricUnits) {
            self.heightCentimeters = (((int)[pickerView selectedRowInComponent:0] + 1) * 100) + ((int)[pickerView selectedRowInComponent:1]);
            [self.heightButton setTitle:[NSString stringWithFormat:@"%dm %dcm", (int)[pickerView selectedRowInComponent:0] + 1, (int)[pickerView selectedRowInComponent:1]] forState:UIControlStateNormal];
            
        } else {
            self.heightFoot = [pickerView selectedRowInComponent:0] + 1.0f;
            self.heightInches = (int)[pickerView selectedRowInComponent:1];
            [self.heightButton setTitle:[NSString stringWithFormat:@"%d' %d\"", (int)[pickerView selectedRowInComponent:0] + 1, (int)[pickerView selectedRowInComponent:1]] forState:UIControlStateNormal];
            
        }
        
        [self.heightButton setBackgroundColor:[UIColor whiteColor]];
        self.heightSelected = YES;
    }
    else if(pickerView == self.genderPickerView)
    {
        if(row == 0)        self.gender = @"male";
        else if(row == 1)   self.gender = @"female";
        
        [self.genderButton setTitle:[self.gender capitalizedString] forState:UIControlStateNormal];
        [self.genderButton setBackgroundColor:[UIColor whiteColor]];
        
        self.genderSelected = YES;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if(pickerView == self.birthdatePickerView)
    {
        if(component == 0) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd"];
            NSDate *date = [df dateFromString:[NSString stringWithFormat:@"%d-%02d-01", self.year, self.month]];
            NSCalendar *c = [NSCalendar currentCalendar];
            NSRange days = [c rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
            return days.length;
            
        } else if(component == 1) {
            return 12; // 12 months/year
            
        } else if(component == 2) {
            return 100; // Last 100 years
            
        } else {
            return 0;
        }
    }
    else if(pickerView == weightPickerView)
    {
        if(component == 0) {
            if(self.weightIsMetricUnits) {
                return 100;
                
            } else {
                return 430;
                
            }
            
        } else if(component == 1) {
            return 10;
            
        } else if(component == 2) {
            return 2;
            
        }
    }
    else if(pickerView == self.heightPickerView)
    {
        if(component == 0) {
            if(self.heightIsMetricUnits) {
                return 3;
                
            } else {
                return 9;
                
            }
            
        } else if(component == 1) {
            if(self.heightIsMetricUnits) {
                return 100;
                
            } else {
                return 12;
                
            }
            
        } else if(component == 2) {
            return 2;
            
        }
    }
    else if(pickerView == self.genderPickerView)
    {
        return 2;
    }
    
    return 0;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    if(pickerView == self.birthdatePickerView)
    {
        return 3;
    }
    else if(pickerView == self.weightPickerView)
    {
        return 3;
    }
    else if(pickerView == self.heightPickerView)
    {
        return 3;
    }
    else if(pickerView == self.genderPickerView)
    {
        return 1;
    }
    
    return 0;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if(pickerView == self.birthdatePickerView)
    {
        if(component == 0) {
            return [NSString stringWithFormat:@"%d", (int)row + 1];
            
        } else if(component == 1) {
            //MONTH
            NSString * dateString = [NSString stringWithFormat: @"%d", (int)row + 1];
            
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM"];
            NSDate* myDate = [dateFormatter dateFromString:dateString];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMMM"];
            return [formatter stringFromDate:myDate];
        } else if(component == 2) {
            //YEAR
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *components = [gregorian components:NSYearCalendarUnit fromDate:[NSDate date]];
            return [NSString stringWithFormat:@"%d", (int)[components year] - (int)row];
        }
    }
    else if(pickerView == self.weightPickerView)
    {
        if(component == 0) {
            if(self.weightIsMetricUnits) {
                return [NSString stringWithFormat:@"%d", (int)row + 30];
            } else {
                return [NSString stringWithFormat:@"%d", (int)row + 30];
            }
            
        } else if(component == 1) {
            if(self.weightIsMetricUnits) {
                return [NSString stringWithFormat:@"%d", (int)row];
            } else {
                return [NSString stringWithFormat:@"%d", (int)row];
            }
            
        } else if(component == 2) {
            
            //lbs/kg
            switch (row) {
                case 0: return @"lbs";
                    break;
                    
                case 1: return @"kg";
                    break;
                    
                default:
                    break;
            }
            
        }
    }
    else if(pickerView == self.heightPickerView)
    {
        if(component == 0) {
            if(self.heightIsMetricUnits) {
                return [NSString stringWithFormat:@"%d m", (int)row + 1];
            } else {
                return [NSString stringWithFormat:@"%d '", (int)row + 1];
            }
            
        } else if(component == 1) {
            if(self.heightIsMetricUnits) {
                return [NSString stringWithFormat:@"%d cm", (int)row];
            } else {
                return [NSString stringWithFormat:@"%d \"", (int)row];
            }
            
        } else if(component == 2) {
            
            //lbs/kg
            switch (row) {
                case 0: return @"ft/in";
                    break;
                    
                case 1: return @"m/cm";
                    break;
                    
                default:
                    break;
            }
            
        }
    }
    else if(pickerView == self.genderPickerView)
    {
        switch (row) {
            case 0: return @"Male";
                break;
                
            case 1: return @"Female";
                break;
                
            default:
                break;
        }
    }
    
    return @"";
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
    if(pickerView == self.birthdatePickerView)
    {
        if(component == 0)      return 50;
        else if(component == 1) return 175;
        else if(component == 2) return 75;
        else return 75;
    }
    else if(pickerView == self.weightPickerView)
    {
        if(component == 0)      return 120;
        else if(component == 1) return 120;
        else if(component == 2) return 80;
        else return 75;
    }
    else if(pickerView == self.heightPickerView)
    {
        if(component == 0)      return 100;
        else if(component == 1) return 100;
        else if(component == 2) return 120;
        else return 75;
    }
    else if(pickerView == self.genderPickerView)
    {
        return 300;
    }
    
    return 0;
}

- (void)genderDoneButtonPressed {

    [self.genderPickerToolbar setHidden:YES];
    [self.genderPickerView setHidden:YES];
}

-(void)birthdayDoneButtonPressed {

    [self.birthdatePickerToolbar setHidden:YES];
    [self.birthdatePickerView setHidden:YES];
}

-(void)weightDoneButtonPressed {

    [self.weightPickerToolbar setHidden:YES];
    [self.weightPickerView setHidden:YES];
}

- (void)heightDoneButtonPressed {

    [self.heightPickerToolbar setHidden:YES];
    [self.heightPickerView setHidden:YES];
}

- (IBAction)sendEditedUserDataRequest:(id)sender
{
    [self hideAllKeyboards];
    [self hideSelectors:nil];

    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"EditProfile"
                                                                                        action:@"Save"
                                                                                         label:@""
                                                                                         value:nil] build]];
    [[GAI sharedInstance] dispatch];

    self.loadingIndicatorHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.loadingIndicatorHud.labelText = @"Saving name, age and gender";

    EditPersonalProfileForm *editPersonalProfileForm = [[EditPersonalProfileForm alloc] initWithName:self.firstNameTextField.text
                                                                                            lastName:self.lastNameTextField.text
                                                                                              gender:self.gender
                                                                                                 day:self.day
                                                                                               month:self.month
                                                                                                year:self.year];

    [[GymneaWSClient sharedInstance] editPersonalProfileWithForm:editPersonalProfileForm
                                             withCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSString  *theMessage) {

                                                 [self.loadingIndicatorHud hide:YES];

                                                 if(success == GymneaWSClientRequestSuccess) {

                                                     [self performSelector:@selector(sendEditedUnitsAndMeasuresRequest) withObject:nil afterDelay:0.3f];

                                                 } else {

                                                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:theMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                                                     [alert show];

                                                 }

               }];

}

- (void)sendEditedUnitsAndMeasuresRequest
{
    self.loadingIndicatorHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.loadingIndicatorHud.labelText = @"Saving length and weight";
    
    EditUnitsMeasuresForm *editUnitsMeasuresForm = [[EditUnitsMeasuresForm alloc] initWithCm:[NSString stringWithFormat:@"%d", self.heightCentimeters]
                                                                                        feet:[NSString stringWithFormat:@"%d", self.heightFoot]
                                                                                        inch:[NSString stringWithFormat:@"%d", self.heightInches]
                                                                                        kilo:[NSString stringWithFormat:@"%f", self.weight]
                                                                                         lbs:@""
                                                                                          st:@""
                                                                                       stLbs:@""
                                                                                 unit_length:self.heightIsMetricUnits ? @"centimeters" : @"inches"
                                                                                 unit_weight:self.weightIsMetricUnits ? @"kilograms" : @"stone"];
    
    [[GymneaWSClient sharedInstance] editUnitsMeasuresProfileWithForm:editUnitsMeasuresForm
                                                  withCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSString  *theMessage) {

                                                 [self.loadingIndicatorHud hide:YES];
                                                 
                                                 if(success == GymneaWSClientRequestSuccess) {

                                                     [self performSelector:@selector(sendEditedEmailRequest) withObject:nil afterDelay:0.3f];

                                                 } else {
                                                     
                                                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:theMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                                                     [alert show];
                                                     
                                                 }
                                                 
                                             }];
}

- (void)sendEditedEmailRequest
{
    GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
    GEAAuthentication *auth = [keychainStore authenticationForIdentifier:@"gymnea"];

    if([self.emailAddressTextField.text isEqualToString:auth.userEmail]) {

        // Same email, so its not necessary to update the email address, proced to send the avatar picture
        [self performSelector:@selector(sendEditedAvatarRequest) withObject:nil afterDelay:0.3f];

    } else {

        // Different email, is necessary to save the email
        self.loadingIndicatorHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.loadingIndicatorHud.labelText = @"Saving email";

        EditEmailForm *editEmailForm = [[EditEmailForm alloc] initWithEmail:[self.emailAddressTextField text]];

        [[GymneaWSClient sharedInstance] editEmailProfileWithForm:editEmailForm
                                              withCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSString  *theMessage) {
                                                          
                                                          [self.loadingIndicatorHud hide:YES];
                                                          
                                                          if(success == GymneaWSClientRequestSuccess) {
                                                              
                                                              [self performSelector:@selector(sendEditedAvatarRequest) withObject:nil afterDelay:0.3f];
                                                              
                                                          } else {
                                                              
                                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:theMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                                                              [alert show];
                                                            
                                                          }
                                                          
                                                      }];

    }
}

- (void)sendEditedAvatarRequest
{
    if(self.lastPhotoTaken == nil) {

        // Download the updated user information from server
        [[GymneaWSClient sharedInstance] requestUserInfoWithCompletionBlock:nil];

        // Show update confirmation message
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Profile updated!" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Continue", nil];
        [alert setTag:1];
        [alert show];

    } else {

        // Different email, is necessary to save the email
        self.loadingIndicatorHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.loadingIndicatorHud.labelText = @"Saving avatar";
        
        EditAvatarForm *editAvatarForm = [[EditAvatarForm alloc] initWithPicture:UIImagePNGRepresentation(self.lastPhotoTaken)];
        
        [[GymneaWSClient sharedInstance] editAvatarWithForm:editAvatarForm
                                        withCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSString  *theMessage) {
                                                  
                                                  [self.loadingIndicatorHud hide:YES];
                                                  
                                                  if(success == GymneaWSClientRequestSuccess) {

                                                      // Download the updated user information from server
                                                      [[GymneaWSClient sharedInstance] requestUserInfoWithCompletionBlock:nil];
                                                      
                                                      // Show update confirmation message
                                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Profile updated!" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Continue", nil];
                                                      [alert setTag:1];
                                                      [alert show];
                                                      
                                                  } else {
                                                      
                                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:theMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                                                      [alert show];
                                                      
                                                  }
                                                  
                                              }];
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView tag] == 1)
    {
        [self hideAllKeyboards];

        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"EditProfile"
                                                                                            action:@"Save Success"
                                                                                             label:@""
                                                                                             value:nil] build]];
        [[GAI sharedInstance] dispatch];

        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)showChangePictureOptionsMenu:(id)sender
{
    UIActionSheet *popupOptions = [[UIActionSheet alloc] initWithTitle:@"Change avatar" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Take new picture", @"Choose existing picture", nil];
    popupOptions.actionSheetStyle = UIActionSheetStyleDefault;
    [popupOptions showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    UIView *overlayView = nil;

    switch (buttonIndex) {
        case 0:         // Take a new picture from camera
                        {
                            sourceType = UIImagePickerControllerSourceTypeCamera;

                            CGRect overlayFrame = [[UIScreen mainScreen] bounds];
                            overlayFrame.size.height-=100;
                            overlayView = [[UIView alloc] initWithFrame:overlayFrame];
                            UIView *topBlack = [[UIView alloc] initWithFrame:CGRectMake(0, 40, [[UIScreen mainScreen] bounds].size.width, 35)];
                            [topBlack setBackgroundColor:[UIColor blackColor]];
                            [overlayView addSubview:topBlack];

                            UIView *bottomBlack = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topBlack.frame) + [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width, 103)];
                            [bottomBlack setBackgroundColor:[UIColor blackColor]];
                            [overlayView addSubview:bottomBlack];
                        }

                        break;

        case 1:         // Choose a picture from camera roll
                        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

                        break;

        default:
                        break;
    }

    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = sourceType;
        imagePicker.mediaTypes =  @[(NSString *)kUTTypeImage];
        imagePicker.allowsEditing = NO;

        if(overlayView) {
            [imagePicker setCameraOverlayView: overlayView];
        }

        [self presentViewController:imagePicker animated:YES completion:nil];
    }

}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.lastPhotoTaken = [self fixrotation:info[UIImagePickerControllerOriginalImage]];

    UIImageWriteToSavedPhotosAlbum(self.lastPhotoTaken, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
    UIImage *fixedRotationImage = [self fixrotation:self.lastPhotoTaken];
    CGFloat originalWidth = fixedRotationImage.size.width;
    CGFloat originalHeight = fixedRotationImage.size.height;
    
    CGFloat imageHeight = 774.0f;
    CGFloat imageWidth = (originalWidth * 774.0f) / originalHeight;
    
    self.lastPhotoTaken = [self.lastPhotoTaken resizedImageToFitInSize:CGSizeMake(imageWidth, imageHeight) scaleIfSmaller:YES];
    
    self.lastPhotoTaken = [self imageByCropping:self.lastPhotoTaken toRect:CGRectMake(0, (imageHeight/2.0f) - (imageWidth/2.0f), imageWidth, imageWidth)];

    [picker dismissViewControllerAnimated:YES completion:^{
        [self.userAvatar setImage:self.lastPhotoTaken];
    }];
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil];
        [alert show];
    }
}

-(UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return cropped;
}

-(UIImage *)fixrotation:(UIImage *)image
{
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
}

- (IBAction)cancelEditProfile:(id)sender
{
    [self hideAllKeyboards];

    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"EditProfile"
                                                                                        action:@"Cancel"
                                                                                         label:@""
                                                                                         value:nil] build]];
    [[GAI sharedInstance] dispatch];

    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
