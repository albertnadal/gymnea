//
//  GenericWorkoutsViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 21/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "GenericWorkoutsViewController.h"
#import "WorkoutDetailViewController.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "GenericWorkoutCollectionViewCell.h"


@interface GenericWorkoutsViewController ()<UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout>
{
    UICollectionView *_collectionView;
}

- (void)showWorkoutDetails:(int)workoutId;

@end

@implementation GenericWorkoutsViewController

- (id)init
{
    self = [super initWithNibName:@"GenericWorkoutsViewController" bundle:nil];
    if (self)
    {
        
    }
    return self;
}

- (void)showWorkoutDetails:(int)workoutId
{
    WorkoutDetailViewController *viewController = [[WorkoutDetailViewController alloc] initWithEventId:workoutId];

    [viewController.view setFrame:CGRectMake(0,0,320,690)];
    CGRect frame2 = viewController.navigationController.toolbar.frame;
    frame2.origin.y = 20;
    viewController.navigationController.toolbar.frame = frame2;
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

    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    [layout setSectionInset:UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f)];

    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];

    [_collectionView registerNib:[UINib nibWithNibName:@"GenericWorkoutCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"genericWorkoutCellIdentifier"];
    [_collectionView setBackgroundColor:[UIColor clearColor]];

    [self.view addSubview:_collectionView];
    [self.view sendSubviewToBack:_collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"genericWorkoutCellIdentifier" forIndexPath:indexPath];

    if(cell == nil) {
        cell = [[GenericWorkoutCollectionViewCell alloc] init];
    }

    cell.layer.borderWidth = 0.5f;
    cell.layer.borderColor = [UIColor colorWithRed:80.0/255.0 green:80.0/255.0 blue:80.0/255.0 alpha:0.3].CGColor;
    cell.layer.cornerRadius = 4.0;
    UIBezierPath *cellViewShadowPath = [UIBezierPath bezierPathWithRect:cell.bounds];
    cell.layer.shadowPath = cellViewShadowPath.CGPath;

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(145.0f, 222.0f + (arc4random() % 50));
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self showWorkoutDetails:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
