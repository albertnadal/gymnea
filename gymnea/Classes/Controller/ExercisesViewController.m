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


@interface ExercisesViewController ()<UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout>
{
    UICollectionView *_collectionView;
    NSArray *exercisesList;
    BOOL needRefreshData;
}

@property (nonatomic) BOOL needRefreshData;
@property (nonatomic, copy) NSArray *exercisesList;

- (void)showExerciseDetails:(int)exerciseId;
- (CGFloat)calculateHeightForString:(NSString *)text withFont:(UIFont *)font withWidth:(CGFloat)maxWidth;

@end

@implementation ExercisesViewController


@synthesize needRefreshData;
@synthesize exercisesList;

- (id)init
{
    self = [super initWithNibName:@"ExercisesViewController" bundle:nil];
    if (self)
    {
        self.needRefreshData = TRUE;
        self.exercisesList = nil;
        _collectionView = nil;
    }
    return self;
}

- (void)showExerciseDetails:(int)exerciseId
{
    ExerciseDetailViewController *viewController = [[ExerciseDetailViewController alloc] initWithEventId:1];
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

    CGRect viewFrame = self.view.frame;
    viewFrame.size.height-=20.0f;
    self.view.frame = viewFrame;

    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];

    if(self.needRefreshData) {

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        GymneaWSClient *gymneaWSClient = [GymneaWSClient sharedInstance];
        [gymneaWSClient requestExercisesWithCompletionBlock:^(GymneaWSClientRequestStatus success, NSArray *exercises) {

            [MBProgressHUD hideHUDForView:self.view animated:YES];

            if(success == GymneaWSClientRequestSuccess) {

                self.exercisesList = exercises;

                if(_collectionView == nil) {
                    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
                    [layout setSectionInset:UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f)];
                    [layout setHeaderHeight:82.0f];

                    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
                    [_collectionView setDataSource:self];
                    [_collectionView setDelegate:self];

                    [_collectionView registerNib:[UINib nibWithNibName:@"ExerciseCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"exerciseCellIdentifier"];
                    [_collectionView setBackgroundColor:[UIColor clearColor]];

                    [_collectionView registerClass:[ExerciseFilterCollectionReusableView class] forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:@"exerciseFilterHeaderView"];
                    [_collectionView registerNib:[UINib nibWithNibName:@"ExerciseFilterCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:@"exerciseFilterHeaderView"];

                    [self.view addSubview:_collectionView];
                    [self.view sendSubviewToBack:_collectionView];

                    [_collectionView reloadData];
                }

                self.needRefreshData = FALSE;

            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An unexpected error occurred. Check your Internet connection and retry again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                [alert show];
            }

        }];

    }

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

        ExerciseFilterCollectionReusableView *headerView = (ExerciseFilterCollectionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:@"exerciseFilterHeaderView" forIndexPath:indexPath];
        
        
        reusableview = headerView;
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
    [self showExerciseDetails:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
