//
//  RY_PhotoCell.m
//  Utilities
//
//  Created by luomeng on 2017/2/14.
//  Copyright © 2017年 XRY. All rights reserved.
//

#import "RY_PhotoCell.h"

@implementation RY_PhotoCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    // Initialization code
}
- (void)setDataWithAsset:(RY_Asset *)asset{
    
    return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        [options setVersion:PHImageRequestOptionsVersionCurrent];
        [options setResizeMode:PHImageRequestOptionsResizeModeFast];
        [options setDeliveryMode:PHImageRequestOptionsDeliveryModeOpportunistic];
        
        float width = (SCREEN_WIDTH - SPACING * (NUM_IN_ROW + 1)) / NUM_IN_ROW;
        
        CGSize size = CGSizeMake(width, width);
        
        CGFloat scale = [[UIScreen mainScreen] scale];
        size = CGSizeMake(size.width * scale, size.height * scale);
        
        [[PHImageManager defaultManager] requestImageForAsset:asset.asset
                                     targetSize:size
                                    contentMode:PHImageContentModeAspectFill
                                        options:options
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          
                                                                                    self.thumbImageView.image = result;
                                          
//                                          for ( int i = 0; i < self.dataSource.count; i ++) {
//
//                                              RY_Asset *ry = [self.dataSource objectAtIndex:i];
//                                              if ([ry.asset isEqual:asset.asset]) {
//
//                                                  ry.thullmImage = result;
//
//                                                  //                                                  [_collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]]];
//                                                  break;
//                                              }
//                                          }
                                          
                                      });
                                      
                                  }];
        
        
    });
}


@end
