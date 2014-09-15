//
//  GenericWorkoutsViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 21/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "GenericWorkoutsViewController.h"
#import "GenericWorkoutCollectionViewCell.h"
#import "WorkoutDetailViewController.h"

@interface GenericWorkoutsViewController ()


- (void)hideAllKeyboards;
- (void)createWorkoutTypePicker;
- (void)createFrequencyPicker;
- (void)createWorkoutLevelPicker;
- (void)showWorkoutTypeSelector;
- (void)showWorkoutFrequencySelector;
- (void)showWorkoutLevelSelector;
- (void)selectionDone;
- (void)searchWorkoutsWithFilters;

@end

@implementation GenericWorkoutsViewController

@synthesize workoutTypePickerView;
@synthesize workoutTypePickerToolbar;
@synthesize frequencyPickerView;
@synthesize frequencyPickerToolbar;
@synthesize workoutLevelPickerView;
@synthesize workoutLevelPickerToolbar;
@synthesize needRefreshData;
@synthesize loadingData;
@synthesize workoutsList;
@synthesize searchText;

- (id)init
{
    self = [super initWithNibName:@"GenericWorkoutsViewController" bundle:nil];
    if (self)
    {
        self.needRefreshData = TRUE;
        self.loadingData = FALSE;
        self.workoutsList = nil;
        _collectionView = nil;
        _disableCollectionView = nil;
        self.headerView = nil;
        
        workoutType = GymneaWorkoutAny;
        workoutFrequency = 0;
        workoutLevel = GymneaWorkoutLevelAny;
        self.searchText = @"";
    }
    return self;
}

- (void)createWorkoutLevelPicker
{
    
    [self.view setNeedsDisplay];
    [self.parentViewController.view setNeedsDisplay];
    
    self.workoutLevelPickerView = [[UIPickerView alloc] init];
    [self.workoutLevelPickerView setBackgroundColor:[UIColor whiteColor]];
    CGRect exerciseTypePickerViewFrame = self.workoutLevelPickerView.frame;
    CGFloat pickerHeight = exerciseTypePickerViewFrame.size.height;
    exerciseTypePickerViewFrame.origin.y = self.view.frame.size.height - pickerHeight;
    exerciseTypePickerViewFrame.origin.x = 0.0f;
    self.workoutLevelPickerView.frame = exerciseTypePickerViewFrame;
    
    [self.workoutLevelPickerView setDataSource: self];
    [self.workoutLevelPickerView setDelegate: self];
    self.workoutLevelPickerView.showsSelectionIndicator = YES;
    
    self.workoutLevelPickerToolbar = [[UIView alloc] initWithFrame:CGRectMake(0, exerciseTypePickerViewFrame.origin.y - 44.0f, 320, 44)];
    [self.workoutLevelPickerToolbar setBackgroundColor:[UIColor colorWithRed:222.0f/255.0f green:217.0f/255.0f blue:215.0f/255.0f alpha:1.0f]];
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 0.5f)];
    [topBorder setBackgroundColor:[UIColor colorWithRed:178.0/255.0f green:178.0/255.0f blue:178.0/255.0f alpha:1.0f]];
    [self.workoutTypePickerToolbar addSubview:topBorder];
    
    UILabel *setWeightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [setWeightLabel setTextAlignment:NSTextAlignmentCenter];
    [setWeightLabel setText:@"Workout Level"];
    [self.workoutLevelPickerToolbar addSubview:setWeightLabel];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [doneBtn addTarget:self action:@selector(selectionDone) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    doneBtn.frame = CGRectMake(260.0, 0, 60.0, 44.0);
    
    [self.workoutLevelPickerToolbar addSubview:doneBtn];
    
    [self.workoutLevelPickerToolbar setHidden:YES];
    [self.workoutLevelPickerView setHidden:YES];
    
    [self.view addSubview:self.workoutLevelPickerView];
    [self.view addSubview:self.workoutLevelPickerToolbar];
}

- (void)createFrequencyPicker
{
    
    [self.view setNeedsDisplay];
    [self.parentViewController.view setNeedsDisplay];
    
    self.frequencyPickerView = [[UIPickerView alloc] init];
    [self.frequencyPickerView setBackgroundColor:[UIColor whiteColor]];
    CGRect exerciseTypePickerViewFrame = self.frequencyPickerView.frame;
    CGFloat pickerHeight = exerciseTypePickerViewFrame.size.height;
    exerciseTypePickerViewFrame.origin.y = self.view.frame.size.height - pickerHeight;
    exerciseTypePickerViewFrame.origin.x = 0.0f;
    self.frequencyPickerView.frame = exerciseTypePickerViewFrame;
    
    [self.frequencyPickerView setDataSource: self];
    [self.frequencyPickerView setDelegate: self];
    self.frequencyPickerView.showsSelectionIndicator = YES;
    
    self.frequencyPickerToolbar = [[UIView alloc] initWithFrame:CGRectMake(0, exerciseTypePickerViewFrame.origin.y - 44.0f, 320, 44)];
    [self.frequencyPickerToolbar setBackgroundColor:[UIColor colorWithRed:222.0f/255.0f green:217.0f/255.0f blue:215.0f/255.0f alpha:1.0f]];
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 0.5f)];
    [topBorder setBackgroundColor:[UIColor colorWithRed:178.0/255.0f green:178.0/255.0f blue:178.0/255.0f alpha:1.0f]];
    [self.frequencyPickerToolbar addSubview:topBorder];
    
    UILabel *setWeightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [setWeightLabel setTextAlignment:NSTextAlignmentCenter];
    [setWeightLabel setText:@"Workout Frequency"];
    [self.frequencyPickerToolbar addSubview:setWeightLabel];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [doneBtn addTarget:self action:@selector(selectionDone) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    doneBtn.frame = CGRectMake(260.0, 0, 60.0, 44.0);
    
    [self.frequencyPickerToolbar addSubview:doneBtn];
    
    [self.frequencyPickerToolbar setHidden:YES];
    [self.frequencyPickerView setHidden:YES];
    
    [self.view addSubview:self.frequencyPickerView];
    [self.view addSubview:self.frequencyPickerToolbar];
}

- (void)createWorkoutTypePicker
{
    
    [self.view setNeedsDisplay];
    [self.parentViewController.view setNeedsDisplay];
    
    self.workoutTypePickerView = [[UIPickerView alloc] init];
    [self.workoutTypePickerView setBackgroundColor:[UIColor whiteColor]];
    CGRect exerciseTypePickerViewFrame = self.workoutTypePickerView.frame;
    CGFloat pickerHeight = exerciseTypePickerViewFrame.size.height;
    exerciseTypePickerViewFrame.origin.y = self.view.frame.size.height - pickerHeight;
    exerciseTypePickerViewFrame.origin.x = 0.0f;
    self.workoutTypePickerView.frame = exerciseTypePickerViewFrame;
    
    [self.workoutTypePickerView setDataSource: self];
    [self.workoutTypePickerView setDelegate: self];
    self.workoutTypePickerView.showsSelectionIndicator = YES;
    
    self.workoutTypePickerToolbar = [[UIView alloc] initWithFrame:CGRectMake(0, exerciseTypePickerViewFrame.origin.y - 44.0f, 320, 44)];
    [self.workoutTypePickerToolbar setBackgroundColor:[UIColor colorWithRed:222.0f/255.0f green:217.0f/255.0f blue:215.0f/255.0f alpha:1.0f]];
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 0.5f)];
    [topBorder setBackgroundColor:[UIColor colorWithRed:178.0/255.0f green:178.0/255.0f blue:178.0/255.0f alpha:1.0f]];
    [self.workoutTypePickerToolbar addSubview:topBorder];
    
    UILabel *setWeightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [setWeightLabel setTextAlignment:NSTextAlignmentCenter];
    [setWeightLabel setText:@"Workout Type"];
    [self.workoutTypePickerToolbar addSubview:setWeightLabel];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [doneBtn addTarget:self action:@selector(selectionDone) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    doneBtn.frame = CGRectMake(260.0, 0, 60.0, 44.0);
    
    [self.workoutTypePickerToolbar addSubview:doneBtn];
    
    [self.workoutTypePickerToolbar setHidden:YES];
    [self.workoutTypePickerView setHidden:YES];
    
    [self.view addSubview:self.workoutTypePickerView];
    [self.view addSubview:self.workoutTypePickerToolbar];
}

- (void)showWorkoutDetailsAtIndexPath:(NSIndexPath*)indexPath
{
    Workout *workout = (Workout *)[self.workoutsList objectAtIndex:indexPath.row];
    
    WorkoutDetailViewController *viewController = [[WorkoutDetailViewController alloc] initWithWorkout:workout];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.noWorkoutsFoundLabel setHidden:YES];

}

- (void)reloadData
{
    
    if((self.needRefreshData) && (!self.loadingData)) {
        
        self.loadingData = TRUE;

        self.loadWorkoutsHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.loadWorkoutsHud.labelText = @"Loading workouts";
        
        GymneaWSClient *gymneaWSClient = [GymneaWSClient sharedInstance];
        [gymneaWSClient requestWorkoutsWithCompletionBlock:^(GymneaWSClientRequestStatus success, NSArray *workouts) {
            
            if(success == GymneaWSClientRequestSuccess) {
                self.needRefreshData = FALSE;
                
                self.workoutsList = workouts;
                
                if(_collectionView == nil) {
                    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
                    [layout setSectionInset:UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f)];
                    [layout setHeaderHeight:126.0f];
                    
                    CGRect collectionViewFrame = self.view.frame;
                    collectionViewFrame.origin.x = 0;
                    
                    _collectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:layout];
                    [_collectionView setHidden:YES];
                    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
                    [_collectionView setDataSource:self];
                    [_collectionView setDelegate:self];
                    
                    [_collectionView registerNib:[UINib nibWithNibName:@"GenericWorkoutCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"workoutCellIdentifier"];
                    [_collectionView setBackgroundColor:[UIColor clearColor]];
                    
                    [_collectionView registerClass:[WorkoutFilterCollectionReusableView class] forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:@"workoutFilterHeaderView"];
                    [_collectionView registerNib:[UINib nibWithNibName:@"WorkoutFilterCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:@"workoutFilterHeaderView"];
                    
                    _disableCollectionView = [[UIView alloc] initWithFrame:self.view.frame];
                    [_disableCollectionView setBackgroundColor:[UIColor whiteColor]];
                    [_disableCollectionView setAlpha:0.3];
                    [_disableCollectionView setHidden:YES];
                    
                    [self.view addSubview:_disableCollectionView];
                    [self.view sendSubviewToBack:_disableCollectionView];
                    [self.view addSubview:_collectionView];
                    [self.view sendSubviewToBack:_collectionView];
                    
                    [_collectionView reloadData];
                }
                
                if(![workouts count]) {
                    [self.noWorkoutsFoundLabel setHidden:NO];
                }
                
                self.needRefreshData = FALSE;
                
                // Hide HUD after 0.3 seconds
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    
                    [self.loadWorkoutsHud hide:YES];
                    self.loadingData = FALSE;

                    [self.loadWorkoutsHud hide:YES];
                    
                    [_collectionView setAlpha:0.0f];
                    [_collectionView setHidden:NO];
                    
                    [UIView beginAnimations:@"fade in" context:nil];
                    [UIView setAnimationDuration:0.3];
                    _collectionView.alpha = 1.0;
                    [UIView commitAnimations];

                });
                
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An unexpected error occurred. Check your Internet connection and retry again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                [alert show];
                
                [self.loadWorkoutsHud hide:YES];
                self.loadingData = FALSE;
                self.needRefreshData = TRUE;
            }
            
        }];
        
    }
    
}

-(void)selectionDone {
    
    [self.noWorkoutsFoundLabel setHidden:YES];
    
    [self.workoutTypePickerToolbar setHidden:YES];
    [self.workoutTypePickerView setHidden:YES];

    [self.frequencyPickerToolbar setHidden:YES];
    [self.frequencyPickerView setHidden:YES];
    
    [self.workoutLevelPickerToolbar setHidden:YES];
    [self.workoutLevelPickerView setHidden:YES];
    
    [_disableCollectionView setHidden:YES];
    [_collectionView setScrollEnabled:YES];
    
    [self searchWorkoutsWithFilters];
    
}

- (void)searchWorkoutsWithFilters
{
    // Reload the exercises applying the filters

    [_collectionView setHidden:YES];

    self.loadWorkoutsHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.loadWorkoutsHud.labelText = @"Searching";

    GymneaWSClient *gymneaWSClient = [GymneaWSClient sharedInstance];
    [gymneaWSClient requestLocalWorkoutsWithType:workoutType
                                    withFrequency:workoutFrequency
                                        withLevel:workoutLevel
                                         withName:searchText
                              withCompletionBlock:^(GymneaWSClientRequestStatus success, NSArray *workouts) {
                                  
                                  if(success == GymneaWSClientRequestSuccess) {
                                      
                                      self.workoutsList = workouts;
                                      
                                      if(_collectionView != nil) {
                                          [_collectionView reloadData];
                                      }
                                      
                                  }
                                  
                                  // Hide HUD after 0.3 seconds
                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                      if(![workouts count]) {
                                          [self.noWorkoutsFoundLabel setHidden:NO];
                                      }
                                      
                                      [self.loadWorkoutsHud hide:YES];

                                      [_collectionView setAlpha:0.0f];
                                      [_collectionView setHidden:NO];

                                      [UIView beginAnimations:@"fade in" context:nil];
                                      [UIView setAnimationDuration:0.3];
                                      _collectionView.alpha = 1.0;
                                      [UIView commitAnimations];
                                  });
                                  
                              }];
}

- (void)searchWorkoutWithText:(NSString *)theSearchText
{
    [self.noWorkoutsFoundLabel setHidden:YES];
    
    self.searchText = theSearchText;
    [self searchWorkoutsWithFilters];
    
    [_disableCollectionView setHidden:YES];
    [_collectionView setScrollEnabled:YES];
    
}

- (void)searchWorkoutWithTextDidBegin
{
    CGRect disableCollectionViewFrame = _disableCollectionView.frame;
    disableCollectionViewFrame.origin.y = 40.0f;
    _disableCollectionView.frame = disableCollectionViewFrame;
    
    [_disableCollectionView setHidden:NO];
    [_collectionView setScrollEnabled:NO];
    
}

- (void)hideAllKeyboards
{
    //    [self.heightTextField resignFirstResponder];
}

- (void)showWorkoutTypeSelector
{
    CGRect disableCollectionViewFrame = _disableCollectionView.frame;
    disableCollectionViewFrame.origin.y = 0.0f;
    _disableCollectionView.frame = disableCollectionViewFrame;
    
    [_disableCollectionView setHidden:NO];
    [_collectionView setScrollEnabled:NO];
    
    
    if(self.workoutTypePickerView == nil) {
        [self createWorkoutTypePicker];
    }
    
    [self hideAllKeyboards];
    
    [self.workoutTypePickerToolbar setHidden:NO];
    [self.workoutTypePickerView setHidden:NO];
    
    [self.frequencyPickerToolbar setHidden:YES];
    [self.frequencyPickerView setHidden:YES];
    
    [self.workoutLevelPickerToolbar setHidden:YES];
    [self.workoutLevelPickerView setHidden:YES];
}

- (void)showWorkoutFrequencySelector
{
    CGRect disableCollectionViewFrame = _disableCollectionView.frame;
    disableCollectionViewFrame.origin.y = 0.0f;
    _disableCollectionView.frame = disableCollectionViewFrame;
    
    [_disableCollectionView setHidden:NO];
    [_collectionView setScrollEnabled:NO];
    
    if(self.frequencyPickerView == nil) {
        [self createFrequencyPicker];
    }
    
    [self hideAllKeyboards];
    
    [self.workoutTypePickerToolbar setHidden:YES];
    [self.workoutTypePickerView setHidden:YES];
    
    [self.frequencyPickerToolbar setHidden:NO];
    [self.frequencyPickerView setHidden:NO];
    
    [self.workoutLevelPickerToolbar setHidden:YES];
    [self.workoutLevelPickerView setHidden:YES];
}

- (void)showWorkoutLevelSelector
{
    CGRect disableCollectionViewFrame = _disableCollectionView.frame;
    disableCollectionViewFrame.origin.y = 0.0f;
    _disableCollectionView.frame = disableCollectionViewFrame;
    
    [_disableCollectionView setHidden:NO];
    [_collectionView setScrollEnabled:NO];
    
    if(self.workoutLevelPickerView == nil) {
        [self createWorkoutLevelPicker];
    }
    
    [self hideAllKeyboards];
    
    [self.workoutTypePickerToolbar setHidden:YES];
    [self.workoutTypePickerView setHidden:YES];
    
    [self.frequencyPickerToolbar setHidden:YES];
    [self.frequencyPickerView setHidden:YES];
    
    [self.workoutLevelPickerToolbar setHidden:NO];
    [self.workoutLevelPickerView setHidden:NO];
}

- (CGFloat)calculateHeightForString:(NSString *)text withFont:(UIFont *)font withWidth:(CGFloat)maxWidth
{
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text
                                                                         attributes:@{
                                                                                      NSFontAttributeName: font
                                                                                      }];
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){maxWidth, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    return ceilf(size.height);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == CHTCollectionElementKindSectionHeader) {
        
        if(self.headerView == nil) {
            self.headerView = (WorkoutFilterCollectionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:@"workoutFilterHeaderView" forIndexPath:indexPath];
            [self.headerView setDelegate:self];
            [self setFilterDelegate:self.headerView];
            
            self.headerView.containerTypeView.layer.cornerRadius = 4.0;
            UIBezierPath *containerTypeViewShadowPath = [UIBezierPath bezierPathWithRect:self.headerView.containerTypeView.bounds];
            self.headerView.containerTypeView.layer.shadowPath = containerTypeViewShadowPath.CGPath;
            
            self.headerView.containerFrequencyView.layer.cornerRadius = 4.0;
            UIBezierPath *containerFrequencyViewShadowPath = [UIBezierPath bezierPathWithRect:self.headerView.containerFrequencyView.bounds];
            self.headerView.containerFrequencyView.layer.shadowPath = containerFrequencyViewShadowPath.CGPath;
            
            self.headerView.containerLevelView.layer.cornerRadius = 4.0;
            UIBezierPath *containerLevelViewShadowPath = [UIBezierPath bezierPathWithRect:self.headerView.containerLevelView.bounds];
            self.headerView.containerLevelView.layer.shadowPath = containerLevelViewShadowPath.CGPath;
            
            if([self.filterDelegate respondsToSelector:@selector(workoutTypeNameSelected:)])
                [self.filterDelegate workoutTypeNameSelected:[GEADefinitions retrieveTitleForWorkoutType:GymneaWorkoutAny]];
            
        }
        
        reusableview = self.headerView;
    }
    
    return reusableview;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(self.workoutsList != nil) {
        return [self.workoutsList count];
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = (GenericWorkoutCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"workoutCellIdentifier" forIndexPath:indexPath];
    
    Workout *workout = (Workout *)[self.workoutsList objectAtIndex:indexPath.row];
    
    [[(GenericWorkoutCollectionViewCell *)cell workoutTitle] setText:workout.name];
    CGRect titleFrame = [(GenericWorkoutCollectionViewCell *)cell workoutTitle].frame;
    CGFloat titleHeight = [self calculateHeightForString:workout.name withFont:[(GenericWorkoutCollectionViewCell *)cell workoutTitle].font withWidth:titleFrame.size.width];
    titleFrame.size.height = titleHeight;
    [[(GenericWorkoutCollectionViewCell *)cell workoutTitle] setFrame:titleFrame];
    
    CGRect attributesViewFrame = [(GenericWorkoutCollectionViewCell *)cell attributesView].frame;
    attributesViewFrame.origin.y = CGRectGetMaxY(titleFrame) + 8.0f;
    [[(GenericWorkoutCollectionViewCell *)cell attributesView] setFrame:attributesViewFrame];

    [[(GenericWorkoutCollectionViewCell *)cell workoutType] setText:[GEADefinitions retrieveTitleForWorkoutType:workout.typeId]];
    [[(GenericWorkoutCollectionViewCell *)cell workoutFrequency] setText:[NSString stringWithFormat:@"%d days / week", workout.frequency]];
    [[(GenericWorkoutCollectionViewCell *)cell workoutLevel] setText:[GEADefinitions retrieveTitleForWorkoutLevel:workout.levelId]];
    [[(GenericWorkoutCollectionViewCell *)cell thumbnail] setImage:[UIImage imageNamed:@"exercise-default-thumbnail"]];
    [[(GenericWorkoutCollectionViewCell *)cell thumbnail] setTag:workout.workoutId];
    [(GenericWorkoutCollectionViewCell *)cell setBackgroundColor:[GEADefinitions retrieveColorForWorkoutType:workout.typeId]];

    [[GymneaWSClient sharedInstance] requestImageForWorkout:workout.workoutId
                                                   withSize:WorkoutImageSizeMedium
                                        withCompletionBlock:^(GymneaWSClientRequestStatus success, UIImage *workoutImage, int workoutId) {

                                             if(success==GymneaWSClientRequestSuccess) {
                                                 
                                                 if(workoutImage == nil) {
                                                     workoutImage = [UIImage imageNamed:@"exercise-default-thumbnail"];
                                                 }

                                                 if([[(GenericWorkoutCollectionViewCell *)cell thumbnail] tag] == workoutId) {
                                                     [[(GenericWorkoutCollectionViewCell *)cell thumbnail] setImage:workoutImage];
                                                 }
                                             }

                                         }];

    if(cell.layer.cornerRadius != 4.0) {
        cell.layer.borderWidth = 0.5f;
        cell.layer.borderColor = [UIColor colorWithRed:80.0/255.0 green:80.0/255.0 blue:80.0/255.0 alpha:0.3].CGColor;
        cell.layer.cornerRadius = 4.0;
        UIBezierPath *cellViewShadowPath = [UIBezierPath bezierPathWithRect:cell.bounds];
        cell.layer.shadowPath = cellViewShadowPath.CGPath;
    }

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    Workout *workout = (Workout *)[self.workoutsList objectAtIndex:indexPath.row];
    UIFont *titleFont = [UIFont fontWithName:@"AvenirNext-DemiBold" size:11.0f];
    
    CGFloat titleHeight = [self calculateHeightForString:workout.name withFont:titleFont withWidth:133.0f];
    
    return CGSizeMake(145.0f, 211.0f + titleHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self showWorkoutDetailsAtIndexPath:indexPath];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component
{
    
    if(pickerView == self.workoutTypePickerView)
    {
        NSDictionary *exerciseTypesDict = [GEADefinitions retrieveWorkoutTypesDictionary];
        NSArray *exerciseTypesDictKeys = [exerciseTypesDict allKeys];
        NSNumber *exerciseKey = (NSNumber *)[exerciseTypesDictKeys objectAtIndex:row];
        workoutType = (GymneaWorkoutType)[exerciseKey intValue];
        
        if([self.filterDelegate respondsToSelector:@selector(workoutTypeNameSelected:)])
            [self.filterDelegate workoutTypeNameSelected:[exerciseTypesDict objectForKey:exerciseKey]];
    }
    else if(pickerView == self.frequencyPickerView)
    {
        workoutFrequency = (int)row;

        NSString *weekFrequency = @"Any";
        if(row) {
            weekFrequency = [NSString stringWithFormat:@"%d days / week", (int)row];
        }

        if([self.filterDelegate respondsToSelector:@selector(workoutFrequencyNameSelected:)])
            [self.filterDelegate workoutFrequencyNameSelected:weekFrequency];
    }
    else if(pickerView == self.workoutLevelPickerView)
    {
        NSDictionary *levelsDict = [GEADefinitions retrieveWorkoutLevelsDictionary];
        NSArray *levelsDictKeys = [levelsDict allKeys];
        NSNumber *levelKey = (NSNumber *)[levelsDictKeys objectAtIndex:row];
        workoutLevel = (GymneaWorkoutLevel)[levelKey intValue];
        
        if([self.filterDelegate respondsToSelector:@selector(workoutLevelNameSelected:)])
            [self.filterDelegate workoutLevelNameSelected:[levelsDict objectForKey:levelKey]];    }
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if(pickerView == self.workoutTypePickerView)
    {
        return [GEADefinitions retrieveTotalWorkoutTypes];
    }
    else if(pickerView == self.frequencyPickerView)
    {
        return 8; // Any + [1..7]
    }
    else if(pickerView == self.workoutLevelPickerView)
    {
        return [GEADefinitions retrieveTotalWorkoutLevels];
    }
    
    return 0;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if(pickerView == self.workoutTypePickerView)
    {
        NSDictionary *exerciseTypesDict = [GEADefinitions retrieveWorkoutTypesDictionary];
        NSArray *exerciseTypesDictKeys = [exerciseTypesDict allKeys];
        NSNumber *exerciseKey = (NSNumber *)[exerciseTypesDictKeys objectAtIndex:row];
        return (NSString *)[exerciseTypesDict objectForKey:exerciseKey];
    }
    else if(pickerView == self.frequencyPickerView)
    {
        NSString *weekFrequency = @"Any";
        if(row) {
            weekFrequency = [NSString stringWithFormat:@"%d days / week", (int)row];
        }

        return weekFrequency;
    }
    else if(pickerView == self.workoutLevelPickerView)
    {
        NSDictionary *levelsDict = [GEADefinitions retrieveWorkoutLevelsDictionary];
        NSArray *levelsDictKeys = [levelsDict allKeys];
        NSNumber *levelKey = (NSNumber *)[levelsDictKeys objectAtIndex:row];
        return (NSString *)[levelsDict objectForKey:levelKey];
    }
    
    return @"";
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
    return 300.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
