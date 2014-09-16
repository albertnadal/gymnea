//
//  SignUpViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 08/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "SignUpViewController.h"
#import "StartViewController.h"
#import "GymneaWSClient.h"
#import "MBProgressHUD.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

@interface SignUpViewController ()<UIPickerViewDataSource, UIPickerViewDelegate, UIActionSheetDelegate>
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
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
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
@property (nonatomic) float weight;
@property (nonatomic) BOOL weightIsMetricUnits;
@property (nonatomic) int heightCentimeters;
@property (nonatomic) int heightFoot;
@property (nonatomic) int heightInches;
@property (nonatomic) BOOL heightIsMetricUnits;
@property (nonatomic) NSString *gender;


@property (nonatomic, retain) SignUpForm *signUpForm;

- (IBAction)goBack:(id)sender;
- (IBAction)showBirthdateSelector:(id)sender;
- (IBAction)showWeightSelector:(id)sender;
- (IBAction)showHeightSelector:(id)sender;
- (IBAction)showGenderSelector:(id)sender;
- (IBAction)hideSelectors:(id)sender;
- (IBAction)hideKeyboard:(id)sender;
- (void)hideAllKeyboards;
- (IBAction)sendSignUpRequest:(id)sender;
- (void)createBirthdatePicker;
- (void)createWeightPicker;
- (void)createGenderPicker;
- (void)birthdayDoneButtonPressed;
- (void)weightDoneButtonPressed;
- (void)heightDoneButtonPressed;
- (void)genderDoneButtonPressed;

@end

@implementation SignUpViewController

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


- (id)initWithSignUpForm:(SignUpForm *)theSignUpForm
{
    self = [super initWithNibName:@"SignUpViewController" bundle:nil];
    if (self)
    {
        self.birthdatePickerView = nil;
        self.signUpForm = theSignUpForm;

        NSDate *currentDate = [NSDate date];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate]; // Get necessary date components

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
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.screenName = @"SignUpView";

    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Initial"
                                                                                        action:@"SignUp"
                                                                                         label:@"viewDidLoad"
                                                                                         value:nil] build]];
    [[GAI sharedInstance] dispatch];
}

- (void)hideAllKeyboards
{
    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
    [self.emailAddressTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
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
    if(self.weightPickerView == nil) {
        [self createWeightPicker];
    }

    [self hideAllKeyboards];

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

    [self.genderPickerToolbar setHidden:NO];
    [self.genderPickerView setHidden:NO];

    [self.heightPickerToolbar setHidden:YES];
    [self.heightPickerView setHidden:YES];
    
    [self.weightPickerToolbar setHidden:YES];
    [self.weightPickerView setHidden:YES];
    
    [self.birthdatePickerToolbar setHidden:YES];
    [self.birthdatePickerView setHidden:YES];
}

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
        [self.passwordTextField becomeFirstResponder];

    } else if(textField == self.passwordTextField) {
        [self.passwordTextField resignFirstResponder];
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

        if(self.weightIsMetricUnits) {
            self.weight = ([pickerView selectedRowInComponent:0] + 30.0f) + (([pickerView selectedRowInComponent:1])/10.0f);
            [self.weightButton setTitle:[NSString stringWithFormat:@"%.1f kg", self.weight] forState:UIControlStateNormal];

        } else {
            self.weight = ([pickerView selectedRowInComponent:0] + 30.0f) + (([pickerView selectedRowInComponent:1])/10.0f);
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
    if(self.birthdatePickerView == nil) {
        [self createBirthdatePicker];
    }

    [self.genderPickerToolbar setHidden:YES];
    [self.genderPickerView setHidden:YES];
    
    [self.birthdatePickerToolbar setHidden:NO];
    [self.birthdatePickerView setHidden:NO];
    
    [self.weightPickerToolbar setHidden:YES];
    [self.weightPickerView setHidden:YES];
    
    [self.heightPickerToolbar setHidden:YES];
    [self.heightPickerView setHidden:YES];
}

-(void)birthdayDoneButtonPressed {

    if(self.weightPickerView == nil) {
        [self createWeightPicker];
    }

    [self.genderPickerToolbar setHidden:YES];
    [self.genderPickerView setHidden:YES];

    [self.birthdatePickerToolbar setHidden:YES];
    [self.birthdatePickerView setHidden:YES];
    
    [self.weightPickerToolbar setHidden:NO];
    [self.weightPickerView setHidden:NO];

    [self.heightPickerToolbar setHidden:YES];
    [self.heightPickerView setHidden:YES];
}

-(void)weightDoneButtonPressed {

    if(self.heightPickerView == nil) {
        [self createHeightPicker];
    }

    [self.genderPickerToolbar setHidden:YES];
    [self.genderPickerView setHidden:YES];

    [self.birthdatePickerToolbar setHidden:YES];
    [self.birthdatePickerView setHidden:YES];

    [self.weightPickerToolbar setHidden:YES];
    [self.weightPickerView setHidden:YES];

    [self.heightPickerToolbar setHidden:NO];
    [self.heightPickerView setHidden:NO];
}

- (void)heightDoneButtonPressed {

    [self.genderPickerToolbar setHidden:YES];
    [self.genderPickerView setHidden:YES];

    [self.birthdatePickerToolbar setHidden:YES];
    [self.birthdatePickerView setHidden:YES];
    
    [self.weightPickerToolbar setHidden:YES];
    [self.weightPickerView setHidden:YES];
    
    [self.heightPickerToolbar setHidden:YES];
    [self.heightPickerView setHidden:YES];

}

- (IBAction)sendSignUpRequest:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [self.signUpForm setFirstName:self.firstNameTextField.text];
    [self.signUpForm setLastName:self.lastNameTextField.text];
    [self.signUpForm setEmailAddress:self.emailAddressTextField.text];
    [self.signUpForm setPassword:self.passwordTextField.text];
    [self.signUpForm setGender:self.gender];
    [self.signUpForm setDay:self.day];
    [self.signUpForm setMonth:self.month];
    [self.signUpForm setYear:self.year];
    [self.signUpForm setWeight:self.weight];
    [self.signUpForm setWeightIsMetricUnits:self.weightIsMetricUnits];
    [self.signUpForm setHeightCentimeters:self.heightCentimeters];
    [self.signUpForm setHeightFoot:self.heightFoot];
    [self.signUpForm setHeightInches:self.heightInches];
    [self.signUpForm setHeightIsMetricUnits:self.heightIsMetricUnits];

    GymneaWSClient *gymneaWSClient = [GymneaWSClient sharedInstance];
    [gymneaWSClient signUpWithForm:self.signUpForm
               withCompletionBlock:^(GymneaSignUpWSClientRequestResponse success, NSDictionary *responseData, UserInfo *userInfo) {

                   [MBProgressHUD hideHUDForView:self.view animated:YES];

                   if([[[responseData objectForKey:@"success"] lowercaseString] isEqual: @"false"]) {

                       [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Initial"
                                                                                                           action:@"SignUp"
                                                                                                            label:@"SignUp Failed"
                                                                                                            value:nil] build]];
                       [[GAI sharedInstance] dispatch];

                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[responseData objectForKey:@"errorMsg"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                       [alert show];
                   } else if([[[responseData objectForKey:@"success"] lowercaseString] isEqual: @"true"]){

                       [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Initial"
                                                                                                           action:@"SignUp"
                                                                                                            label:@"SignUp Success"
                                                                                                            value:nil] build]];
                       [[GAI sharedInstance] dispatch];

                       StartViewController *startViewController = [[StartViewController alloc] initShowingSplashScreen:NO];
                       [self.navigationController pushViewController:startViewController animated:NO];
                   } else {
                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An unexpected error occurred. Check your Internet connection and retry again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                       [alert show];
                   }

               }];
}

@end
