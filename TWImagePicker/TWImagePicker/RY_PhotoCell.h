//
//  RY_PhotoCell.h
//  Utilities
//
//  Created by luomeng on 2017/2/14.
//  Copyright © 2017年 XRY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RY_PhotoCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UIImageView *seletedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *gifImageView;
@property (weak, nonatomic) IBOutlet UILabel *gifLabel;

@end
