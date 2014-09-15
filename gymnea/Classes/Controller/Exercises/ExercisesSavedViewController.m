//
//  ExercisesSavedViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 20/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "ExercisesSavedViewController.h"
#import "ExerciseCollectionViewCell.h"

@implementation ExercisesSavedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Listen for incoming new downloaded exercise

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadDataAgain)
                                                 name:GEANotificationFavoriteExercisesUpdated
                                               object:nil];

}

- (void)reloadDataAgain
{
    self.needRefreshData = TRUE;
    [self reloadData];
}

- (void)reloadData
{

    if((self.needRefreshData) && (!self.loadingData)) {

        self.loadingData = TRUE;

        dispatch_async(dispatch_get_main_queue(), ^{
            self.loadExercisesHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.loadExercisesHud.labelText = @"Loading favorite exercises";
        });

        [self.noExercisesFoundLabel setHidden:YES];
        [self.noExercisesFoundLabel setText:@"No favorite exercises found"];

        GymneaWSClient *gymneaWSClient = [GymneaWSClient sharedInstance];
        [gymneaWSClient requestSavedExercisesWithCompletionBlock:^(GymneaWSClientRequestStatus success, NSArray *exercises) {

            if(success == GymneaWSClientRequestSuccess) {
                self.needRefreshData = FALSE;

                self.exercisesList = exercises;
                
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
                    
                    [self.loadExercisesHud hide:YES];
                    self.loadingData = FALSE;

                    if(_collectionView != nil) {
                        [_collectionView reloadData];
                    }

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

                [self.loadExercisesHud hide:YES];
                self.loadingData = FALSE;
                self.needRefreshData = TRUE;
            }
            
        }];
        
    }

}

- (void)searchExercisesWithFilters
{
    // Reload the exercises applying the filters
    [_collectionView setHidden:YES];

    self.loadExercisesHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.loadExercisesHud.labelText = @"Searching";

    GymneaWSClient *gymneaWSClient = [GymneaWSClient sharedInstance];
    [gymneaWSClient requestLocalSavedExercisesWithType:exerciseType
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
                                      
                                      [self.loadExercisesHud hide:YES];

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
    [self showExerciseDetailsAtIndexPath:indexPath];
}

@end
