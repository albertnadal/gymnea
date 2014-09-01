//
//  PicturesViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 01/09/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "PicturesViewController.h"
#import "MWPhotoBrowser.h"
#import "SDImageCache.h"
#import "MWCommon.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface PicturesViewController ()<MWPhotoBrowserDelegate>
{
    NSMutableArray *_selections;
}

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;
@property (nonatomic, strong) NSMutableArray *assets;

- (void)loadAssets;

@end

@implementation PicturesViewController

- (id)init
{
    self = [super initWithNibName:@"PicturesViewController" bundle:nil];
    if (self)
    {
        // Clear cache for testing
        [[SDImageCache sharedImageCache] clearDisk];
        [[SDImageCache sharedImageCache] clearMemory];

        [self loadAssets];

        return self;
    }

    return nil;
}

- (UIViewController *)getPhotoBrowser
{
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    MWPhoto *photo;
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = YES;
    
    
    // Photos & thumbs
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://albertnadal.cat/wp-content/uploads/2013/11/header_plantar_pi-150x150.jpg"]];
    photo.caption = @"Plantar un pi";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://albertnadal.cat/wp-content/uploads/2013/11/header_plantar_pi-150x150.jpg"]]];

    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://albertnadal.cat/wp-content/uploads/2013/03/bunquers_martinet_montella-150x150.jpg"]];
    photo.caption = @"Bunquers de Martinet";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://albertnadal.cat/wp-content/uploads/2013/03/bunquers_martinet_montella-150x150.jpg"]]];

    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://albertnadal.cat/wp-content/uploads/2013/03/bunquers_martinet_montella-150x150.jpg"]];
    photo.caption = @"Woburn Abbey";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm9.static.flickr.com/8379/8530199945_47b386320f_q.jpg"]]];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm9.static.flickr.com/8364/8268120482_332d61a89e_b.jpg"]];
    photo.caption = @"Frosty walk";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm9.static.flickr.com/8364/8268120482_332d61a89e_q.jpg"]]];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm8.static.flickr.com/7109/7604416018_f23733881b_b.jpg"]];
    photo.caption = @"Jury's Inn";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm8.static.flickr.com/7109/7604416018_f23733881b_q.jpg"]]];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm7.static.flickr.com/6002/6020924733_b21874f14c_b.jpg"]];
    photo.caption = @"Heavy Rain";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm7.static.flickr.com/6002/6020924733_b21874f14c_q.jpg"]]];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm5.static.flickr.com/4012/4501918517_5facf1a8c4_b.jpg"]];
    photo.caption = @"iPad Application Sketch Template v1";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm5.static.flickr.com/4012/4501918517_5facf1a8c4_q.jpg"]]];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2667/4072710001_f36316ddc7_b.jpg"]];
    photo.caption = @"Grotto of the Madonna";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2667/4072710001_f36316ddc7_q.jpg"]]];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2449/4052876281_6e068ac860_b.jpg"]];
    photo.caption = @"Beautiful Eyes";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2449/4052876281_6e068ac860_q.jpg"]]];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3528/4052875665_53e5b4dc61_b.jpg"]];
    photo.caption = @"Cousin Portrait";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3528/4052875665_53e5b4dc61_q.jpg"]]];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3520/3846053408_6ecf775a3e_b.jpg"]];
    photo.caption = @"iPhone Application Sketch Template v1.3";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3520/3846053408_6ecf775a3e_q.jpg"]]];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3624/3559209373_003152b4fd_b.jpg"]];
    photo.caption = @"Door Knocker of Capitanía General";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3624/3559209373_003152b4fd_q.jpg"]]];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3551/3523421738_30455b63e0_b.jpg"]];
    photo.caption = @"Parroquia Sta Maria del Mar";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3551/3523421738_30455b63e0_q.jpg"]]];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3224/3523355044_6551552f93_b.jpg"]];
    photo.caption = @"Central Atrium in Casa Batlló";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3224/3523355044_6551552f93_q.jpg"]]];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3567/3523321514_371d9ac42f_b.jpg"]];
    photo.caption = @"Gaudí's Casa Batlló spiral ceiling";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3567/3523321514_371d9ac42f_q.jpg"]]];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3629/3339128908_7aecabc34b_b.jpg"]];
    photo.caption = @"The Royal Albert Hall";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3629/3339128908_7aecabc34b_q.jpg"]]];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3338/3339119002_e0d8ec2f2e_b.jpg"]];
    photo.caption = @"Midday & Midnight at the RAH";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3338/3339119002_e0d8ec2f2e_q.jpg"]]];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3364/3338617424_7ff836d55f_b.jpg"]];
    photo.caption = @"Westminster Bridge";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3364/3338617424_7ff836d55f_q.jpg"]]];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3604/3328356821_5503b332aa_b.jpg"]];
    photo.caption = @"Prime Meridian Sculpture";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3604/3328356821_5503b332aa_q.jpg"]]];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3590/3329114220_5fbc5bc92b_b.jpg"]];
    photo.caption = @"Docklands";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3590/3329114220_5fbc5bc92b_q.jpg"]]];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3602/3329107762_64a1454080_b.jpg"]];
    photo.caption = @"Planetarium";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3602/3329107762_64a1454080_q.jpg"]]];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3122/3143635211_80b29ab354_b.jpg"]];
    photo.caption = @"Eurostar Perspective";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3122/3143635211_80b29ab354_q.jpg"]]];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3091/3144451298_db6f6da3f9_b.jpg"]];
    photo.caption = @"The Meeting Place";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3091/3144451298_db6f6da3f9_q.jpg"]]];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3110/3143623585_a12fa172fc_b.jpg"]];
    photo.caption = @"Embrace";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3110/3143623585_a12fa172fc_q.jpg"]]];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3107/3143613445_d9562105ea_b.jpg"]];
    photo.caption = @"See to the Sky with the Station Saver";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3107/3143613445_d9562105ea_q.jpg"]]];
    
    
    self.photos = photos;
    self.thumbs = thumbs;
    
    // Create browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = YES;
    /*
     #if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
     browser.wantsFullScreenLayout = YES;
     #endif
     */
    browser.enableGrid = enableGrid;
    browser.startOnGrid = startOnGrid;
    browser.enableSwipeToDismiss = YES;
    [browser setCurrentPhotoIndex:0];
    
    // Reset selections
    if (displaySelectionButtons) {
        _selections = [NSMutableArray new];
        for (int i = 0; i < photos.count; i++) {
            [_selections addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    
    // Test reloading of data after delay
    double delayInSeconds = 3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        
    });

    return browser;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Load Assets

- (void)loadAssets {
    
    // Initialise
    _assets = [NSMutableArray new];
    _assetLibrary = [[ALAssetsLibrary alloc] init];
    
    // Run in the background as it takes a while to get all assets from the library
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
        NSMutableArray *assetURLDictionaries = [[NSMutableArray alloc] init];
        
        // Process assets
        void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result != nil) {
                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                    [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                    NSURL *url = result.defaultRepresentation.url;
                    [_assetLibrary assetForURL:url
                                   resultBlock:^(ALAsset *asset) {
                                       if (asset) {
                                           @synchronized(_assets) {
                                               [_assets addObject:asset];
                                               if (_assets.count == 1) {
                                                   // Added first asset so reload data
                                                   // DO SOMETHING!
                                               }
                                           }
                                       }
                                   }
                                  failureBlock:^(NSError *error){
                                      NSLog(@"operation was not successfull!");
                                  }];
                    
                }
            }
        };
        
        // Process groups
        void (^ assetGroupEnumerator) (ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group != nil) {
                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:assetEnumerator];
                [assetGroups addObject:group];
            }
        };
        
        // Process!
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                         usingBlock:assetGroupEnumerator
                                       failureBlock:^(NSError *error) {
                                           NSLog(@"There is an error");
                                       }];
        
    });
    
}

@end
