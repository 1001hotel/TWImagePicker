//
//  RY_ImagePickerVC.m
//  Utilities
//
//  Created by luomeng on 2017/1/20.
//  Copyright © 2017年 XRY. All rights reserved.
//

#import "RY_ImagePickerVC.h"
#import "RY_PhotoCell.h"
#import <MobileCoreServices/MobileCoreServices.h>
//#import <UIImage+GIF.h>
#import "RY_Asset.h"



#define NUM_IN_ROW    4.0
#define SPACING       2.0
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)



@interface RY_ImagePickerVC ()
{

    __weak IBOutlet UICollectionView *_collectionView;
    
    UIBarButtonItem *_rightItem;
    
    
    __weak IBOutlet UILabel *_countLabel;
    __weak IBOutlet UIButton *_sureButton;
    
}

@property (strong) PHImageManager *imageManager;
@property(nonatomic, strong) PHFetchResult *assetsFetchResults;
@property(nonatomic, strong) NSMutableArray *dataSource;


@property(nonatomic, strong) NSMutableArray *selectedResults;


@end

@implementation RY_ImagePickerVC (private)

- (void)_cancel{

    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)_sure{

//  PHAsset *asset =  [self.selectedResults objectAtIndex:10000];
    /*
    [self.selectedResults removeAllObjects];
    for (int i = 0; i < self.assetsFetchResults.count; i ++) {
        
        if (i < 100) {
            PHAsset *asset = [self.assetsFetchResults objectAtIndex:i];
            
            [self.selectedResults addObject:asset];
        }
    }
    */
    if (self.selectedResults.count == 0) {
        return;
    }
    if (self.delegate) {
        [self.delegate RY_ImagePickerVC:self didselectWithAssets:self.selectedResults];
    }
    
}
- (void)_back{
    if (self.delegate) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)_showNoAcceessToPhotoLibrary{

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"在设置—途遇图记—权限中开启相册权限，以正常使用发布图记、收藏您喜欢的图片等功能。" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];//ios8以上可用
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            
            [[UIApplication sharedApplication] openURL:url];
//            [[UIApplication sharedApplication] openURL:url options:@{UIApplicationOpenURLOptionUniversalLinksOnly : @YES} completionHandler:^(BOOL success) {
//                
//                
//            }];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cancel];
    [alert addAction:ok];

    [self presentViewController:alert animated:YES completion:nil];
    
}
- (void)_loadData{
    
    self.imageManager = [PHImageManager defaultManager];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    self.assetsFetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];

    self.dataSource = [NSMutableArray array];
    for (PHAsset *asset in self.assetsFetchResults) {
        RY_Asset *ryAsset = [[RY_Asset alloc] init];
        ryAsset.asset = asset;
        ryAsset.gifTag = @"";
        [self.dataSource addObject:ryAsset];
    }
    
    if ([NSThread isMainThread]) {
        
        [_collectionView reloadData];
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(_scrollToBottom:) userInfo:nil repeats:NO];

//        [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:NO block:^(NSTimer * _Nonnull timer) {
//            
//            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.dataSource.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
//            
//            [timer invalidate];
//        }];
    }
    else{
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [_collectionView reloadData];
            
            [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(_scrollToBottom:) userInfo:nil repeats:NO];
//            
//            [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:NO block:^(NSTimer * _Nonnull timer) {
//                
//                [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.dataSource.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
//                
//                [timer invalidate];
//            }];
        });
    }
   
 
    
/*
//    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
//    [options setVersion:PHImageRequestOptionsVersionCurrent];
//    [options setResizeMode:PHImageRequestOptionsResizeModeFast];
//    [options setDeliveryMode:PHImageRequestOptionsDeliveryModeOpportunistic];

    NSArray *temp = [NSArray arrayWithArray:self.dataSource];
    for (RY_Asset *asset  in temp) {
        
        [self.imageManager requestImageDataForAsset:asset.asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            
            NSString *tag = @"";
            if ([dataUTI isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
                
                tag = @"1";
            }
            else{
                
                tag = @"0";
            }
            
            for ( int i = 0; i < self.dataSource.count; i ++) {
                
                RY_Asset *ry = [self.dataSource objectAtIndex:i];
                if ([ry.asset isEqual:asset.asset]) {
                    
                    ry.gifTag = tag;
                    
                    [_collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]]];
                }
            }
        }];
    }
   //*/
}
- (void)_scrollToBottom:(NSTimer *)timer{

    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.dataSource.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    
    [timer invalidate];
}

@end

@implementation RY_ImagePickerVC

+ (RY_ImagePickerVC *)sharedInstance {
    static dispatch_once_t onceToken;
    static RY_ImagePickerVC * userHelper;
    dispatch_once(&onceToken, ^{
        userHelper = [RY_ImagePickerVC new];
    });
    return userHelper;
}




#pragma mark -
#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"所有照片";
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(10, 0, 44, 44);
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_cancel) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    _rightItem = item;
    self.navigationItem.rightBarButtonItem = item;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:@"back"];
    
    if (img) {
        float imgWidthHeightRatio = img.size.width / img.size.height;
        backButton.frame = CGRectMake(10, 0, imgWidthHeightRatio * 44, 44);
        [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(_back) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backItem;
    }
    

    [_collectionView registerNib:[UINib nibWithNibName:@"RY_PhotoCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"RY_PhotoCell"];
    
    [_sureButton addTarget:self action:@selector(_sure) forControlEvents:UIControlEventTouchUpInside];
    _countLabel.layer.cornerRadius = 10;
    
    self.selectedResults = [NSMutableArray array];
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusDenied) {
        
        
        [self _showNoAcceessToPhotoLibrary];
    }
    else if (status == PHAuthorizationStatusNotDetermined) {
    
       [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
           
           if (status == PHAuthorizationStatusAuthorized) {
              
               [self _loadData];
           }
           else if (status == PHAuthorizationStatusDenied) {
                   
            [self _showNoAcceessToPhotoLibrary];
        }
       }];
    }
    else if (status == PHAuthorizationStatusAuthorized) {
       
        [self _loadData];
    }
}
- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
    if (self.isViewLoaded && !self.view.window) {
        
#ifdef INTERNAL_SERVER_DEBUG_MODE
        NSLog(@"%@ didReceiveMemoryWarning, it's view change nil.", [[self class] description]);
#endif
        self.view = nil;
    }
}



#pragma mark -
#pragma mark - public
- (BOOL)isExistAsset:(PHAsset *)asset{

    BOOL result = NO;
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    self.assetsFetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
    
    if ([self.assetsFetchResults containsObject:asset]) {
        
        result = YES;
    }
    return result;
}



#pragma mark -
#pragma mark - UICollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.assetsFetchResults.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    RY_PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RY_PhotoCell" forIndexPath:indexPath];
    
    RY_Asset *ryAsset = [self.dataSource objectAtIndex:indexPath.row];
    PHAsset *asset = ryAsset.asset;
    
    if ([self.selectedResults containsObject:asset]) {
        
        cell.seletedImageView.image = [UIImage imageNamed:@"c_d_15"];
    }
    else{
    
        cell.seletedImageView.image = [UIImage imageNamed:@"c_d_14"];
    }
    
    NSLog(@"%@", ryAsset.gifTag);
    if (ryAsset.gifTag.length == 0) {
        
    }
    else if ([ryAsset.gifTag isEqualToString:@"1"]){
        
        cell.gifLabel.hidden = NO;
    }
    else{
        
        cell.gifLabel.hidden = YES;
        
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        [options setVersion:PHImageRequestOptionsVersionCurrent];
        [options setResizeMode:PHImageRequestOptionsResizeModeFast];
        [options setDeliveryMode:PHImageRequestOptionsDeliveryModeOpportunistic];
        
        float width = (SCREEN_WIDTH - SPACING * (NUM_IN_ROW + 1)) / NUM_IN_ROW;
        
        CGSize size = CGSizeMake(width, width);
        
        CGFloat scale = [[UIScreen mainScreen] scale];
        size = CGSizeMake(size.width * scale, size.height * scale);
        
        [self.imageManager requestImageForAsset:asset
                                     targetSize:size
                                    contentMode:PHImageContentModeAspectFill
                                        options:options
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          
                                          cell.thumbImageView.image = result;
                                      });

                                  }];
        
            });
         
    return cell;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(SPACING, SPACING, SPACING, SPACING);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return 2.0f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return 1.0f;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    float width = (SCREEN_WIDTH - SPACING * (NUM_IN_ROW + 1)) / NUM_IN_ROW;

    return CGSizeMake(width, width);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
//    PHAsset *asset = [self.assetsFetchResults objectAtIndex:indexPath.row];
    RY_Asset *ryAsset = [self.dataSource objectAtIndex:indexPath.row];
    PHAsset *asset = ryAsset.asset;
    if ([self.selectedResults containsObject:asset]) {
        
        [self.selectedResults removeObject:asset];
    }
    else{
    
        if (self.selectedResults.count >= self.maxSelectedCount) {
            
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"你最多只能选择%ld张照片", (long)self.maxSelectedCount] message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *iKonw = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
                
            }];
            [alert addAction:iKonw];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }

        [self.selectedResults addObject:asset];
    }
    
    [_collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    
    _countLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)self.selectedResults.count];
    if (self.selectedResults.count == 0) {
        
        _sureButton.enabled = NO;
        _countLabel.hidden = YES;
    }
    else{
    
        _sureButton.enabled = YES;
        _countLabel.hidden = NO;
    }
}


@end

