//
//  ExercisesViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 09/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "ExercisesViewController.h"
#import "ExerciseDetailViewController.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "ExerciseCollectionViewCell.h"
#import "ExerciseFilterCollectionReusableView.h"
#import "MBProgressHUD.h"
#import "GymneaWSClient.h"
#import "GEADefinitions.h"
#import "Exercise.h"


@interface ExercisesViewController ()<UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout, ExerciseFilterCollectionReusableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    UICollectionView *_collectionView;
    UIView *_disableCollectionView;
    NSArray *exercisesList;
    BOOL needRefreshData;

    GymneaExerciseType exerciseType;
    GymneaMuscleType muscleType;
    GymneaEquipmentType equipmentType;
    GymneaExerciseLevel exerciseLevel;
    NSString *searchText;
    
    UIPickerView *exerciseTypePickerView;
    UIView *exerciseTypePickerToolbar;

    UIPickerView *musclePickerView;
    UIView *musclePickerToolbar;

    UIPickerView *equipmentPickerView;
    UIView *equipmentPickerToolbar;

    UIPickerView *exerciseLevelPickerView;
    UIView *exerciseLevelPickerToolbar;

}

@property (nonatomic) BOOL needRefreshData;
@property (nonatomic, copy) NSArray *exercisesList;
@property (nonatomic, retain) UIPickerView *exerciseTypePickerView;
@property (nonatomic, retain) UIView *exerciseTypePickerToolbar;
@property (nonatomic, retain) UIPickerView *musclePickerView;
@property (nonatomic, retain) UIView *musclePickerToolbar;
@property (nonatomic, retain) UIPickerView *equipmentPickerView;
@property (nonatomic, retain) UIView *equipmentPickerToolbar;
@property (nonatomic, retain) UIPickerView *exerciseLevelPickerView;
@property (nonatomic, retain) UIView *exerciseLevelPickerToolbar;
@property (nonatomic, retain) ExerciseFilterCollectionReusableView *headerView;
@property (nonatomic, retain) NSString *searchText;
@property (nonatomic, weak) IBOutlet UILabel *noExercisesFoundLabel;

- (void)hideAllKeyboards;
- (void)createExerciseTypePicker;
- (void)createMusclePicker;
- (void)createEquipmentPicker;
- (void)showExerciseDetailsAtIndexPath:(NSIndexPath*)indexPath;
- (CGFloat)calculateHeightForString:(NSString *)text withFont:(UIFont *)font withWidth:(CGFloat)maxWidth;
- (void)showExerciseTypeSelector;
- (void)showMuscleSelector;
- (void)showEquipmentSelector;
- (void)showExerciseLevelSelector;
- (void)selectionDone;
- (void)searchExercisesWithFilters;

@end

@implementation ExercisesViewController

@synthesize exerciseTypePickerView;
@synthesize exerciseTypePickerToolbar;
@synthesize musclePickerView;
@synthesize musclePickerToolbar;
@synthesize equipmentPickerView;
@synthesize equipmentPickerToolbar;
@synthesize exerciseLevelPickerView;
@synthesize exerciseLevelPickerToolbar;
@synthesize needRefreshData;
@synthesize exercisesList;
@synthesize searchText;

- (id)init
{
    self = [super initWithNibName:@"ExercisesViewController" bundle:nil];
    if (self)
    {
        self.needRefreshData = TRUE;
        self.exercisesList = nil;
        _collectionView = nil;
        _disableCollectionView = nil;
        self.headerView = nil;

        exerciseType = GymneaExerciseAny;
        muscleType = GymneaMuscleAny;
        equipmentType = GymneaEquipmentAny;
        exerciseLevel = GymneaExerciseLevelAny;
        self.searchText = @"";
    }
    return self;
}

- (void)createExerciseLevelPicker
{
    
    [self.view setNeedsDisplay];
    [self.parentViewController.view setNeedsDisplay];
    
    self.exerciseLevelPickerView = [[UIPickerView alloc] init];
    [self.exerciseLevelPickerView setBackgroundColor:[UIColor whiteColor]];
    CGRect exerciseTypePickerViewFrame = self.exerciseLevelPickerView.frame;
    CGFloat pickerHeight = exerciseTypePickerViewFrame.size.height;
    exerciseTypePickerViewFrame.origin.y = self.view.frame.size.height - pickerHeight;
    exerciseTypePickerViewFrame.origin.x = 0.0f;
    self.exerciseLevelPickerView.frame = exerciseTypePickerViewFrame;
    
    [self.exerciseLevelPickerView setDataSource: self];
    [self.exerciseLevelPickerView setDelegate: self];
    self.exerciseLevelPickerView.showsSelectionIndicator = YES;
    
    self.exerciseLevelPickerToolbar = [[UIView alloc] initWithFrame:CGRectMake(0, exerciseTypePickerViewFrame.origin.y - 44.0f, 320, 44)];
    [self.exerciseLevelPickerToolbar setBackgroundColor:[UIColor colorWithRed:222.0f/255.0f green:217.0f/255.0f blue:215.0f/255.0f alpha:1.0f]];
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 0.5f)];
    [topBorder setBackgroundColor:[UIColor colorWithRed:178.0/255.0f green:178.0/255.0f blue:178.0/255.0f alpha:1.0f]];
    [self.exerciseTypePickerToolbar addSubview:topBorder];
    
    UILabel *setWeightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [setWeightLabel setTextAlignment:NSTextAlignmentCenter];
    [setWeightLabel setText:@"Exercise Level"];
    [self.exerciseLevelPickerToolbar addSubview:setWeightLabel];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [doneBtn addTarget:self action:@selector(selectionDone) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    doneBtn.frame = CGRectMake(260.0, 0, 60.0, 44.0);
    
    [self.exerciseLevelPickerToolbar addSubview:doneBtn];
    
    [self.exerciseLevelPickerToolbar setHidden:YES];
    [self.exerciseLevelPickerView setHidden:YES];
    
    [self.view addSubview:self.exerciseLevelPickerView];
    [self.view addSubview:self.exerciseLevelPickerToolbar];
}

- (void)createEquipmentPicker
{
    
    [self.view setNeedsDisplay];
    [self.parentViewController.view setNeedsDisplay];
    
    self.equipmentPickerView = [[UIPickerView alloc] init];
    [self.equipmentPickerView setBackgroundColor:[UIColor whiteColor]];
    CGRect exerciseTypePickerViewFrame = self.equipmentPickerView.frame;
    CGFloat pickerHeight = exerciseTypePickerViewFrame.size.height;
    exerciseTypePickerViewFrame.origin.y = self.view.frame.size.height - pickerHeight;
    exerciseTypePickerViewFrame.origin.x = 0.0f;
    self.equipmentPickerView.frame = exerciseTypePickerViewFrame;
    
    [self.equipmentPickerView setDataSource: self];
    [self.equipmentPickerView setDelegate: self];
    self.equipmentPickerView.showsSelectionIndicator = YES;
    
    self.equipmentPickerToolbar = [[UIView alloc] initWithFrame:CGRectMake(0, exerciseTypePickerViewFrame.origin.y - 44.0f, 320, 44)];
    [self.equipmentPickerToolbar setBackgroundColor:[UIColor colorWithRed:222.0f/255.0f green:217.0f/255.0f blue:215.0f/255.0f alpha:1.0f]];
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 0.5f)];
    [topBorder setBackgroundColor:[UIColor colorWithRed:178.0/255.0f green:178.0/255.0f blue:178.0/255.0f alpha:1.0f]];
    [self.equipmentPickerToolbar addSubview:topBorder];
    
    UILabel *setWeightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [setWeightLabel setTextAlignment:NSTextAlignmentCenter];
    [setWeightLabel setText:@"Equipment"];
    [self.equipmentPickerToolbar addSubview:setWeightLabel];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [doneBtn addTarget:self action:@selector(selectionDone) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    doneBtn.frame = CGRectMake(260.0, 0, 60.0, 44.0);
    
    [self.equipmentPickerToolbar addSubview:doneBtn];
    
    [self.equipmentPickerToolbar setHidden:YES];
    [self.equipmentPickerView setHidden:YES];
    
    [self.view addSubview:self.equipmentPickerView];
    [self.view addSubview:self.equipmentPickerToolbar];
}

- (void)createMusclePicker
{
    
    [self.view setNeedsDisplay];
    [self.parentViewController.view setNeedsDisplay];
    
    self.musclePickerView = [[UIPickerView alloc] init];
    [self.musclePickerView setBackgroundColor:[UIColor whiteColor]];
    CGRect exerciseTypePickerViewFrame = self.musclePickerView.frame;
    CGFloat pickerHeight = exerciseTypePickerViewFrame.size.height;
    exerciseTypePickerViewFrame.origin.y = self.view.frame.size.height - pickerHeight;
    exerciseTypePickerViewFrame.origin.x = 0.0f;
    self.musclePickerView.frame = exerciseTypePickerViewFrame;
    
    [self.musclePickerView setDataSource: self];
    [self.musclePickerView setDelegate: self];
    self.musclePickerView.showsSelectionIndicator = YES;
    
    self.musclePickerToolbar = [[UIView alloc] initWithFrame:CGRectMake(0, exerciseTypePickerViewFrame.origin.y - 44.0f, 320, 44)];
    [self.musclePickerToolbar setBackgroundColor:[UIColor colorWithRed:222.0f/255.0f green:217.0f/255.0f blue:215.0f/255.0f alpha:1.0f]];
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 0.5f)];
    [topBorder setBackgroundColor:[UIColor colorWithRed:178.0/255.0f green:178.0/255.0f blue:178.0/255.0f alpha:1.0f]];
    [self.musclePickerToolbar addSubview:topBorder];
    
    UILabel *setWeightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [setWeightLabel setTextAlignment:NSTextAlignmentCenter];
    [setWeightLabel setText:@"Muscle"];
    [self.musclePickerToolbar addSubview:setWeightLabel];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [doneBtn addTarget:self action:@selector(selectionDone) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    doneBtn.frame = CGRectMake(260.0, 0, 60.0, 44.0);
    
    [self.musclePickerToolbar addSubview:doneBtn];
    
    [self.musclePickerToolbar setHidden:YES];
    [self.musclePickerView setHidden:YES];
    
    [self.view addSubview:self.musclePickerView];
    [self.view addSubview:self.musclePickerToolbar];
}

- (void)createExerciseTypePicker
{

    [self.view setNeedsDisplay];
    [self.parentViewController.view setNeedsDisplay];

    self.exerciseTypePickerView = [[UIPickerView alloc] init];
    [self.exerciseTypePickerView setBackgroundColor:[UIColor whiteColor]];
    CGRect exerciseTypePickerViewFrame = self.exerciseTypePickerView.frame;
    CGFloat pickerHeight = exerciseTypePickerViewFrame.size.height;
    exerciseTypePickerViewFrame.origin.y = self.view.frame.size.height - pickerHeight;
    exerciseTypePickerViewFrame.origin.x = 0.0f;
    self.exerciseTypePickerView.frame = exerciseTypePickerViewFrame;
    
    [self.exerciseTypePickerView setDataSource: self];
    [self.exerciseTypePickerView setDelegate: self];
    self.exerciseTypePickerView.showsSelectionIndicator = YES;
    
    self.exerciseTypePickerToolbar = [[UIView alloc] initWithFrame:CGRectMake(0, exerciseTypePickerViewFrame.origin.y - 44.0f, 320, 44)];
    [self.exerciseTypePickerToolbar setBackgroundColor:[UIColor colorWithRed:222.0f/255.0f green:217.0f/255.0f blue:215.0f/255.0f alpha:1.0f]];

    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 0.5f)];
    [topBorder setBackgroundColor:[UIColor colorWithRed:178.0/255.0f green:178.0/255.0f blue:178.0/255.0f alpha:1.0f]];
    [self.exerciseTypePickerToolbar addSubview:topBorder];

    UILabel *setWeightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [setWeightLabel setTextAlignment:NSTextAlignmentCenter];
    [setWeightLabel setText:@"Exercise Type"];
    [self.exerciseTypePickerToolbar addSubview:setWeightLabel];

    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [doneBtn addTarget:self action:@selector(selectionDone) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    doneBtn.frame = CGRectMake(260.0, 0, 60.0, 44.0);

    [self.exerciseTypePickerToolbar addSubview:doneBtn];

    [self.exerciseTypePickerToolbar setHidden:YES];
    [self.exerciseTypePickerView setHidden:YES];
    
    [self.view addSubview:self.exerciseTypePickerView];
    [self.view addSubview:self.exerciseTypePickerToolbar];
}

- (void)showExerciseDetailsAtIndexPath:(NSIndexPath*)indexPath
{
    Exercise *exercise = (Exercise *)[self.exercisesList objectAtIndex:indexPath.row];

    ExerciseDetailViewController *viewController = [[ExerciseDetailViewController alloc] initWithExercise:exercise];
    [viewController.view setFrame:CGRectMake(0,0,320,690)];
    CGRect viewControllerFrame = viewController.navigationController.toolbar.frame;
    viewControllerFrame.origin.y = 20;
    viewController.navigationController.toolbar.frame = viewControllerFrame;
    viewController.edgesForExtendedLayout = UIRectEdgeNone;
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

    [self.noExercisesFoundLabel setHidden:YES];

    CGRect viewFrame = self.view.frame;
    viewFrame.size.height-=20.0f;
    self.view.frame = viewFrame;


    if(self.needRefreshData) {

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        GymneaWSClient *gymneaWSClient = [GymneaWSClient sharedInstance];
        [gymneaWSClient requestExercisesWithCompletionBlock:^(GymneaWSClientRequestStatus success, NSArray *exercises) {

            if(success == GymneaWSClientRequestSuccess) {

                self.exercisesList = exercises;

                if(_collectionView == nil) {
                    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
                    [layout setSectionInset:UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f)];
                    [layout setHeaderHeight:126.0f];

                    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
                    [_collectionView setDataSource:self];
                    [_collectionView setDelegate:self];

                    [_collectionView registerNib:[UINib nibWithNibName:@"ExerciseCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"exerciseCellIdentifier"];
                    [_collectionView setBackgroundColor:[UIColor clearColor]];

                    [_collectionView registerClass:[ExerciseFilterCollectionReusableView class] forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:@"exerciseFilterHeaderView"];
                    [_collectionView registerNib:[UINib nibWithNibName:@"ExerciseFilterCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:@"exerciseFilterHeaderView"];

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

                if(![exercises count]) {
                    [self.noExercisesFoundLabel setHidden:NO];
                }

                self.needRefreshData = FALSE;

                // Hide HUD after 0.3 seconds
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });

            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An unexpected error occurred. Check your Internet connection and retry again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                [alert show];
            }

        }];

    }

}

-(void)selectionDone {

    [self.noExercisesFoundLabel setHidden:YES];

    [self.exerciseTypePickerToolbar setHidden:YES];
    [self.exerciseTypePickerView setHidden:YES];

    [self.musclePickerToolbar setHidden:YES];
    [self.musclePickerView setHidden:YES];
    
    [self.equipmentPickerToolbar setHidden:YES];
    [self.equipmentPickerView setHidden:YES];

    [self.exerciseLevelPickerToolbar setHidden:YES];
    [self.exerciseLevelPickerView setHidden:YES];

    [_disableCollectionView setHidden:YES];
    [_collectionView setScrollEnabled:YES];

    [self searchExercisesWithFilters];

}

- (void)searchExercisesWithFilters
{
    // Reload the exercises applying the filters
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    GymneaWSClient *gymneaWSClient = [GymneaWSClient sharedInstance];
    [gymneaWSClient requestLocalExercisesWithType:exerciseType
                                       withMuscle:muscleType
                                    withEquipment:equipmentType
                                        withLevel:exerciseLevel
                                         withName:searchText
                              withCompletionBlock:^(GymneaWSClientRequestStatus success, NSArray *exercises) {
                                  
                                  if(success == GymneaWSClientRequestSuccess) {
                                      
                                      self.exercisesList = exercises;
                                      
                                      if(_collectionView != nil) {
                                          [_collectionView reloadData];
                                      }
                                      
                                  }
                                  
                                  // Hide HUD after 0.3 seconds
                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                      if(![exercises count]) {
                                          [self.noExercisesFoundLabel setHidden:NO];
                                      }
                                      
                                      [MBProgressHUD hideHUDForView:self.view animated:YES];
                                  });
                                  
                              }];

}

- (void)searchExerciseWithText:(NSString *)theSearchText
{
    [self.noExercisesFoundLabel setHidden:YES];

    self.searchText = theSearchText;
    [self searchExercisesWithFilters];

    [_disableCollectionView setHidden:YES];
    [_collectionView setScrollEnabled:YES];

}

- (void)searchExerciseWithTextDidBegin
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

- (void)showExerciseTypeSelector
{
    CGRect disableCollectionViewFrame = _disableCollectionView.frame;
    disableCollectionViewFrame.origin.y = 0.0f;
    _disableCollectionView.frame = disableCollectionViewFrame;

    [_disableCollectionView setHidden:NO];
    [_collectionView setScrollEnabled:NO];


    if(self.exerciseTypePickerView == nil) {
        [self createExerciseTypePicker];
    }
    
    [self hideAllKeyboards];
    
    [self.exerciseTypePickerToolbar setHidden:NO];
    [self.exerciseTypePickerView setHidden:NO];

    [self.musclePickerToolbar setHidden:YES];
    [self.musclePickerView setHidden:YES];

    [self.equipmentPickerToolbar setHidden:YES];
    [self.equipmentPickerView setHidden:YES];

    [self.exerciseLevelPickerToolbar setHidden:YES];
    [self.exerciseLevelPickerView setHidden:YES];
}

- (void)showMuscleSelector
{
    CGRect disableCollectionViewFrame = _disableCollectionView.frame;
    disableCollectionViewFrame.origin.y = 0.0f;
    _disableCollectionView.frame = disableCollectionViewFrame;

    [_disableCollectionView setHidden:NO];
    [_collectionView setScrollEnabled:NO];
    
    if(self.musclePickerView == nil) {
        [self createMusclePicker];
    }
    
    [self hideAllKeyboards];

    [self.exerciseTypePickerToolbar setHidden:YES];
    [self.exerciseTypePickerView setHidden:YES];

    [self.musclePickerToolbar setHidden:NO];
    [self.musclePickerView setHidden:NO];

    [self.equipmentPickerToolbar setHidden:YES];
    [self.equipmentPickerView setHidden:YES];

    [self.exerciseLevelPickerToolbar setHidden:YES];
    [self.exerciseLevelPickerView setHidden:YES];
}

- (void)showEquipmentSelector
{
    CGRect disableCollectionViewFrame = _disableCollectionView.frame;
    disableCollectionViewFrame.origin.y = 0.0f;
    _disableCollectionView.frame = disableCollectionViewFrame;

    [_disableCollectionView setHidden:NO];
    [_collectionView setScrollEnabled:NO];
    
    if(self.equipmentPickerView == nil) {
        [self createEquipmentPicker];
    }
    
    [self hideAllKeyboards];
    
    [self.exerciseTypePickerToolbar setHidden:YES];
    [self.exerciseTypePickerView setHidden:YES];
    
    [self.musclePickerToolbar setHidden:YES];
    [self.musclePickerView setHidden:YES];

    [self.equipmentPickerToolbar setHidden:NO];
    [self.equipmentPickerView setHidden:NO];

    [self.exerciseLevelPickerToolbar setHidden:YES];
    [self.exerciseLevelPickerView setHidden:YES];
}

- (void)showExerciseLevelSelector
{
    CGRect disableCollectionViewFrame = _disableCollectionView.frame;
    disableCollectionViewFrame.origin.y = 0.0f;
    _disableCollectionView.frame = disableCollectionViewFrame;

    [_disableCollectionView setHidden:NO];
    [_collectionView setScrollEnabled:NO];
    
    if(self.exerciseLevelPickerView == nil) {
        [self createExerciseLevelPicker];
    }
    
    [self hideAllKeyboards];
    
    [self.exerciseTypePickerToolbar setHidden:YES];
    [self.exerciseTypePickerView setHidden:YES];
    
    [self.musclePickerToolbar setHidden:YES];
    [self.musclePickerView setHidden:YES];
    
    [self.equipmentPickerToolbar setHidden:YES];
    [self.equipmentPickerView setHidden:YES];

    [self.exerciseLevelPickerToolbar setHidden:NO];
    [self.exerciseLevelPickerView setHidden:NO];
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
            self.headerView = (ExerciseFilterCollectionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:@"exerciseFilterHeaderView" forIndexPath:indexPath];
            [self.headerView setDelegate:self];
            [self setFilterDelegate:self.headerView];

            self.headerView.containerTypeView.layer.cornerRadius = 4.0;
            UIBezierPath *containerTypeViewShadowPath = [UIBezierPath bezierPathWithRect:self.headerView.containerTypeView.bounds];
            self.headerView.containerTypeView.layer.shadowPath = containerTypeViewShadowPath.CGPath;

            self.headerView.containerMuscleView.layer.cornerRadius = 4.0;
            UIBezierPath *containerMuscleViewShadowPath = [UIBezierPath bezierPathWithRect:self.headerView.containerMuscleView.bounds];
            self.headerView.containerMuscleView.layer.shadowPath = containerMuscleViewShadowPath.CGPath;

            self.headerView.containerEquipmentView.layer.cornerRadius = 4.0;
            UIBezierPath *containerEquipmentViewShadowPath = [UIBezierPath bezierPathWithRect:self.headerView.containerEquipmentView.bounds];
            self.headerView.containerEquipmentView.layer.shadowPath = containerEquipmentViewShadowPath.CGPath;

            self.headerView.containerLevelView.layer.cornerRadius = 4.0;
            UIBezierPath *containerLevelViewShadowPath = [UIBezierPath bezierPathWithRect:self.headerView.containerLevelView.bounds];
            self.headerView.containerLevelView.layer.shadowPath = containerLevelViewShadowPath.CGPath;

            if([self.filterDelegate respondsToSelector:@selector(exerciseTypeNameSelected:)])
                [self.filterDelegate exerciseTypeNameSelected:[GEADefinitions retrieveTitleForExerciseType:GymneaExerciseAny]];

        }

        reusableview = self.headerView;
    }

    return reusableview;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(self.exercisesList != nil) {
        return [self.exercisesList count];
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = (ExerciseCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"exerciseCellIdentifier" forIndexPath:indexPath];

        Exercise *exercise = (Exercise *)[self.exercisesList objectAtIndex:indexPath.row];

        [[(ExerciseCollectionViewCell *)cell exerciseTitle] setText:exercise.name];
        CGRect titleFrame = [(ExerciseCollectionViewCell *)cell exerciseTitle].frame;
        CGFloat titleHeight = [self calculateHeightForString:exercise.name withFont:[(ExerciseCollectionViewCell *)cell exerciseTitle].font withWidth:titleFrame.size.width];
        titleFrame.size.height = titleHeight;
        [[(ExerciseCollectionViewCell *)cell exerciseTitle] setFrame:titleFrame];

        CGRect attributesViewFrame = [(ExerciseCollectionViewCell *)cell attributesView].frame;
        attributesViewFrame.origin.y = CGRectGetMaxY(titleFrame) + 8.0f;
        [[(ExerciseCollectionViewCell *)cell attributesView] setFrame:attributesViewFrame];

        [[(ExerciseCollectionViewCell *)cell exerciseType] setText:[GEADefinitions retrieveTitleForExerciseType:exercise.typeId]];
        [[(ExerciseCollectionViewCell *)cell exerciseMuscle] setText:[GEADefinitions retrieveTitleForMuscle:exercise.muscleId]];
        [[(ExerciseCollectionViewCell *)cell exerciseEquipment] setText:[GEADefinitions retrieveTitleForEquipment:exercise.equipmentId]];
        [[(ExerciseCollectionViewCell *)cell exerciseLevel] setText:[GEADefinitions retrieveTitleForExerciseLevel:exercise.levelId]];
        [[(ExerciseCollectionViewCell *)cell thumbnail] setImage:[UIImage imageNamed:@"exercise-default-thumbnail"]];
        [(ExerciseCollectionViewCell *)cell setBackgroundColor:[GEADefinitions retrieveColorForExerciseType:exercise.typeId]];

        [[GymneaWSClient sharedInstance] requestImageForExercise:exercise.exerciseId
                                                        withSize:ExerciseImageSizeMedium
                                             withCompletionBlock:^(GymneaWSClientRequestStatus success, UIImage *exerciseImage) {

                                                 if(success==GymneaWSClientRequestSuccess) {
                                                     [[(ExerciseCollectionViewCell *)cell thumbnail] setImage:exerciseImage];
                                                 }

                                             }];

        cell.layer.borderWidth = 0.5f;
        cell.layer.borderColor = [UIColor colorWithRed:80.0/255.0 green:80.0/255.0 blue:80.0/255.0 alpha:0.3].CGColor;
        cell.layer.cornerRadius = 4.0;
        UIBezierPath *cellViewShadowPath = [UIBezierPath bezierPathWithRect:cell.bounds];
        cell.layer.shadowPath = cellViewShadowPath.CGPath;

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{

        Exercise *exercise = (Exercise *)[self.exercisesList objectAtIndex:indexPath.row];
        UIFont *titleFont = [UIFont fontWithName:@"AvenirNext-DemiBold" size:11.0f];

        CGFloat titleHeight = [self calculateHeightForString:exercise.name withFont:titleFont withWidth:133.0f];

        return CGSizeMake(145.0f, 252.0f + titleHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self showExerciseDetailsAtIndexPath:indexPath];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component
{
    
    if(pickerView == self.exerciseTypePickerView)
    {
        NSDictionary *exerciseTypesDict = [GEADefinitions retrieveExerciseTypesDictionary];
        NSArray *exerciseTypesDictKeys = [exerciseTypesDict allKeys];
        NSNumber *exerciseKey = (NSNumber *)[exerciseTypesDictKeys objectAtIndex:row];
        exerciseType = (GymneaExerciseType)[exerciseKey intValue];

        if([self.filterDelegate respondsToSelector:@selector(exerciseTypeNameSelected:)])
            [self.filterDelegate exerciseTypeNameSelected:[exerciseTypesDict objectForKey:exerciseKey]];
    }
    else if(pickerView == self.musclePickerView)
    {
        NSDictionary *musclesDict = [GEADefinitions retrieveMusclesDictionary];
        NSArray *musclesDictKeys = [musclesDict allKeys];
        NSNumber *muscleKey = (NSNumber *)[musclesDictKeys objectAtIndex:row];
        muscleType = (GymneaMuscleType)[muscleKey intValue];
        
        if([self.filterDelegate respondsToSelector:@selector(muscleNameSelected:)])
            [self.filterDelegate muscleNameSelected:[musclesDict objectForKey:muscleKey]];
    }
    else if(pickerView == self.equipmentPickerView)
    {
        NSDictionary *equipmentsDict = [GEADefinitions retrieveEquipmentsDictionary];
        NSArray *equipmentsDictKeys = [equipmentsDict allKeys];
        NSNumber *equipmentKey = (NSNumber *)[equipmentsDictKeys objectAtIndex:row];
        equipmentType = (GymneaEquipmentType)[equipmentKey intValue];

        if([self.filterDelegate respondsToSelector:@selector(equipmentNameSelected:)])
            [self.filterDelegate equipmentNameSelected:[equipmentsDict objectForKey:equipmentKey]];
    }
    else if(pickerView == self.exerciseLevelPickerView)
    {
        NSDictionary *levelsDict = [GEADefinitions retrieveExerciseLevelsDictionary];
        NSArray *levelsDictKeys = [levelsDict allKeys];
        NSNumber *levelKey = (NSNumber *)[levelsDictKeys objectAtIndex:row];
        exerciseLevel = (GymneaExerciseLevel)[levelKey intValue];
        
        if([self.filterDelegate respondsToSelector:@selector(exerciseLevelNameSelected:)])
            [self.filterDelegate exerciseLevelNameSelected:[levelsDict objectForKey:levelKey]];
    }

}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if(pickerView == self.exerciseTypePickerView)
    {
        return [GEADefinitions retrieveTotalExerciseTypes];
    }
    else if(pickerView == self.musclePickerView)
    {
        return [GEADefinitions retrieveTotalMuscles];
    }
    else if(pickerView == self.equipmentPickerView)
    {
        return [GEADefinitions retrieveTotalEquipments];
    }
    else if(pickerView == self.exerciseLevelPickerView)
    {
        return [GEADefinitions retrieveTotalExerciseLevels];
    }

    return 0;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {

    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if(pickerView == self.exerciseTypePickerView)
    {
        NSDictionary *exerciseTypesDict = [GEADefinitions retrieveExerciseTypesDictionary];
        NSArray *exerciseTypesDictKeys = [exerciseTypesDict allKeys];
        NSNumber *exerciseKey = (NSNumber *)[exerciseTypesDictKeys objectAtIndex:row];
        return (NSString *)[exerciseTypesDict objectForKey:exerciseKey];
    }
    else if(pickerView == self.musclePickerView)
    {
        NSDictionary *musclesDict = [GEADefinitions retrieveMusclesDictionary];
        NSArray *musclesDictKeys = [musclesDict allKeys];
        NSNumber *muscleKey = (NSNumber *)[musclesDictKeys objectAtIndex:row];
        return (NSString *)[musclesDict objectForKey:muscleKey];
    }
    else if(pickerView == self.equipmentPickerView)
    {
        NSDictionary *equipmentsDict = [GEADefinitions retrieveEquipmentsDictionary];
        NSArray *equipmentsDictKeys = [equipmentsDict allKeys];
        NSNumber *equipmentKey = (NSNumber *)[equipmentsDictKeys objectAtIndex:row];
        return (NSString *)[equipmentsDict objectForKey:equipmentKey];
    }
    else if(pickerView == self.exerciseLevelPickerView)
    {
        NSDictionary *levelsDict = [GEADefinitions retrieveExerciseLevelsDictionary];
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
