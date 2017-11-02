//
//  RY_Asset.h
//  Gallery
//
//  Created by luomeng on 2017/4/14.
//  Copyright © 2017年 TourWay_iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface RY_Asset : NSObject

@property (nonatomic, strong)PHAsset *asset;
@property (nonatomic, assign)BOOL isGIF;
@property (nonatomic, strong)UIImage *thullmImage;


@end
