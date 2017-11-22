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

@property (nonatomic, strong) PHImageManager *imageManager;
@property(nonatomic, strong) PHFetchResult *assetsFetchResults;
@property(nonatomic, strong) NSMutableArray *dataSource;


@property(nonatomic, strong) NSMutableArray *selectedResults;


@end

@implementation RY_ImagePickerVC (private)

- (void)_cancel{

    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)_sure{

    if (self.selectedResults.count == 0) {
        return;
    }
    if (self.delegate) {
        [self.delegate RY_ImagePickerVC:self didselectWithAssets:self.selectedResults];
    }
}
- (void)_back{
    
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    self.assetsFetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];

    self.dataSource = [NSMutableArray array];
    for (PHAsset *asset in self.assetsFetchResults) {
        RY_Asset *ryAsset = [[RY_Asset alloc] init];
        ryAsset.asset = asset;
        ryAsset.isGIF = NO;
        ryAsset.thullmImage = nil;
        [self.dataSource addObject:ryAsset];
    }
    
    if ([NSThread isMainThread]) {
        
        [self _reloadData];
    }
    else{
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [self _reloadData];
        });
    }
   
   
    if (self.isGIFAvailable) {
        
        PHImageRequestOptions *requestoptions = [[PHImageRequestOptions alloc] init];
        [requestoptions setVersion:PHImageRequestOptionsVersionCurrent];
        [requestoptions setResizeMode:PHImageRequestOptionsResizeModeFast];
        [requestoptions setDeliveryMode:PHImageRequestOptionsDeliveryModeOpportunistic];
        
        NSArray *temp = [NSArray arrayWithArray:self.dataSource];
        for (RY_Asset *asset  in temp) {
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:asset.asset.localIdentifier] == nil
) {
                
                [self.imageManager requestImageDataForAsset:asset.asset options:requestoptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    
                    BOOL isGIF = NO;
                    if ([dataUTI isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
                        
                        isGIF = YES;
                    }
                    
                    for ( int i = 0; i < self.dataSource.count; i ++) {
                        
                        RY_Asset *ry = [self.dataSource objectAtIndex:i];
                        if ([ry.asset isEqual:asset.asset]) {
                            
                            ry.isGIF = isGIF;
                            
                            [_collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]]];
                            
                            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isGIF] forKey:asset.asset.localIdentifier];
                        }
                    }
                }];
            }
        }
    }
}
- (void)_scrollToBottom:(NSTimer *)timer{

    if (self.dataSource.count > 0) {
        
 [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.dataSource.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
    
    [timer invalidate];
}
- (void)_reloadData{

    [_collectionView reloadData];
    if ([[UIDevice currentDevice] systemVersion].floatValue < 10.0) {
        
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(_scrollToBottom:) userInfo:nil repeats:NO];
    }
    else{
        
        [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:NO block:^(NSTimer * _Nonnull timer) {
            
            if (self.dataSource.count > 0) {
                
                 [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.dataSource.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
            }
            [timer invalidate];
        }];
    }
}
- (void)_initData{

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


@end

@implementation RY_ImagePickerVC


#pragma mark -
#pragma mark - sharedInstance
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
- (PHImageManager *)imageManager{

    return [PHImageManager defaultManager];
}
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
    [self _initData];
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
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
- (void)isGIFAsset:(PHAsset *)asset withResult:(isGIFBlock)result{
        
        PHImageRequestOptions *requestoptions = [[PHImageRequestOptions alloc] init];
        [requestoptions setVersion:PHImageRequestOptionsVersionCurrent];
        [requestoptions setResizeMode:PHImageRequestOptionsResizeModeExact];
        [requestoptions setDeliveryMode:PHImageRequestOptionsDeliveryModeOpportunistic];
        [self.imageManager requestImageDataForAsset:asset options:requestoptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            
            BOOL isGIF = NO;
            if ([dataUTI isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
                
                isGIF = YES;
            }
            
            result(isGIF);
        }];
}


#pragma mark -
#pragma mark - UICollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.dataSource.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    RY_PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RY_PhotoCell" forIndexPath:indexPath];
    
    RY_Asset *asset = [self.dataSource objectAtIndex:indexPath.row];
    
    if ([self.selectedResults containsObject:asset.asset]) {
        
        cell.seletedImageView.image = [UIImage imageNamed:@"c_d_15"];
    }
    else{
    
        cell.seletedImageView.image = [UIImage imageNamed:@"c_d_14"];
    }
    
    
    if (self.isGIFAvailable) {
        
        BOOL isGif = [[[NSUserDefaults standardUserDefaults] objectForKey:asset.asset.localIdentifier] boolValue];
        asset.isGIF = isGif;
        if (asset.isGIF){
            
            cell.gifLabel.hidden = NO;
        }
        else{
            
            cell.gifLabel.hidden = YES;
        }   
    }
    
    
    
    UIImage *image = asset.thullmImage;
///*
    if (image && [image isKindOfClass:[UIImage class]]) {
        
        cell.thumbImageView.image = asset.thullmImage;
    }
    else{
              
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.synchronous = YES;
        [options setVersion:PHImageRequestOptionsVersionCurrent];
        [options setResizeMode:PHImageRequestOptionsResizeModeFast];
        [options setDeliveryMode:PHImageRequestOptionsDeliveryModeOpportunistic];
        
        float width = (SCREEN_WIDTH - SPACING * (NUM_IN_ROW + 1)) / NUM_IN_ROW;
        
        CGSize size = CGSizeMake(width, width);
        
        CGFloat scale = [[UIScreen mainScreen] scale];
        size = CGSizeMake(size.width * scale, size.height * scale);
        
     PHImageRequestID requestID = [self.imageManager requestImageForAsset:asset.asset
                                     targetSize:size
                                    contentMode:PHImageContentModeAspectFill
                                        options:options
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      
                                          cell.thumbImageView.image = result;
                                          
                                          for ( int i = 0; i < self.dataSource.count; i ++) {
                                              
                                              RY_Asset *ry = [self.dataSource objectAtIndex:i];
                                              if ([ry.asset isEqual:asset.asset]) {
                                                  
                                                  ry.thullmImage = result;
                                                break;
                                              }
                                          }
                                  }];
        
        NSLog(@"%d", requestID);
        
    }
    //*/
         
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











