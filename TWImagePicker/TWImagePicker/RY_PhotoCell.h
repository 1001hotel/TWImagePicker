//
//  RY_PhotoCell.h
//  Utilities
//
//  Created by luomeng on 2017/2/14.
//  Copyright © 2017年 XRY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RY_Asset.h"


#define NUM_IN_ROW    4.0
#define SPACING       2.0
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)



@interface RY_PhotoCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UIImageView *seletedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *gifImageView;
@property (weak, nonatomic) IBOutlet UILabel *gifLabel;
//@property (strong, nonatomic) RY_Asset *asset;

- (void)setDataWithAsset:(RY_Asset *)asset;

@end




