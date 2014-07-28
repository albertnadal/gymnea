//
//  WorkoutsViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 21/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "WorkoutsViewController.h"
#import "WorkoutDetailViewController.h"
#import "CHTCollectionViewWaterfallLayout.h"


@interface WorkoutsViewController ()<UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout>
{
    UICollectionView *_collectionView;
}

- (IBAction)showWorkoutDetails:(id)sender;

@end

@implementation WorkoutsViewController

- (id)init
{
    self = [super initWithNibName:@"WorkoutsViewController" bundle:nil];
    if (self)
    {
        
    }
    return self;
}

- (IBAction)showWorkoutDetails:(id)sender
{
    WorkoutDetailViewController *viewController = [[WorkoutDetailViewController alloc] initWithEventId:1];

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

    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [_collectionView setBackgroundColor:[UIColor redColor]];

    [self.view addSubview:_collectionView];
    [self.view sendSubviewToBack:_collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 15;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];

    cell.backgroundColor = [UIColor greenColor];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(145.0f, 155.0f + (arc4random() % 150));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
