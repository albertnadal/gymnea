//
//  GenericWorkoutsDownloadedViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 26/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "GenericWorkoutsDownloadedViewController.h"
#import "GenericWorkoutCollectionViewCell.h"

@implementation GenericWorkoutsDownloadedViewController

- (void)reloadData
{
    
    if((self.needRefreshData) && (!self.loadingData)) {
        
        self.loadingData = TRUE;

        self.loadWorkoutsHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.loadWorkoutsHud.labelText = @"Loading downloaded workouts";

        [self.noWorkoutsFoundLabel setText:@"No downloaded workouts found"];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            self.needRefreshData = FALSE;
            
            self.workoutsList = [Workout getDownloadedWorkouts];
            
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
            
            if(![self.workoutsList count]) {
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

        });
        
    }
    
}

- (void)searchWorkoutsWithFilters
{
    // Reload the exercises applying the filters
    [_collectionView setHidden:YES];

    self.loadWorkoutsHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.loadWorkoutsHud.labelText = @"Searching";

    GymneaWSClient *gymneaWSClient = [GymneaWSClient sharedInstance];
    [gymneaWSClient requestLocalDownloadedWorkoutsWithType:workoutType
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return [super collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [super collectionView:collectionView numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [super collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self showWorkoutDetailsAtIndexPath:indexPath];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(_collectionView != nil) {
        // Refresh downloaded workouts on view will appear
        self.workoutsList = [Workout getDownloadedWorkouts];

        [self.noWorkoutsFoundLabel setHidden:([self.workoutsList count] > 0)];

        [_collectionView reloadData];
    }
}

@end
