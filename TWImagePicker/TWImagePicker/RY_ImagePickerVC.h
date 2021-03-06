//
//  RY_ImagePickerVC.h
//  Utilities
//
//  Created by luomeng on 2017/1/20.
//  Copyright © 2017年 XRY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

#define RY_IMAGE_PICKER   

@class RY_ImagePickerVC;

typedef void(^isGIFBlock)(BOOL isGif);

@protocol RY_ImagePickerVCDelegate <NSObject>

- (void)RY_ImagePickerVC:(RY_ImagePickerVC *)vc didselectWithAssets:(NSArray *)assets;

@end

@interface RY_ImagePickerVC : UIViewController

@property(nonatomic, assign)id<RY_ImagePickerVCDelegate>delegate;
@property(nonatomic, assign)NSInteger maxSelectedCount;
@property(nonatomic, assign)BOOL isGIFAvailable;


+ (RY_ImagePickerVC *)sharedInstance;



- (BOOL)isExistAsset:(PHAsset *)asset;
- (void)isGIFAsset:(PHAsset *)asset withResult:(isGIFBlock)result;




@end
