//
//  ViewController.m
//  TWImagePickerDemo
//
//  Created by luomeng on 2017/5/26.
//  Copyright © 2017年 XRY. All rights reserved.
//

#import "ViewController.h"
#import "RY_ImagePickerVC.h"

@interface ViewController ()
<
RY_ImagePickerVCDelegate
>

@end

@implementation ViewController


- (IBAction)_picker:(id)sender {
    
    RY_ImagePickerVC *picker = [[RY_ImagePickerVC alloc] init];
    picker.maxSelectedCount = 1;
    picker.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
    [self presentViewController:nav animated:YES completion:nil];
}


#pragma mark -
#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark - RY_ImagePickerVCDelegate
- (void)RY_ImagePickerVC:(RY_ImagePickerVC *)vc didselectWithAssets:(NSArray *)assets{

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end











