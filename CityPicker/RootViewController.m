//
//  ViewController.m
//  CityPicker
//
//  Created by cs on 2017/4/10.
//  Copyright © 2017年 cs. All rights reserved.
//

#import "RootViewController.h"
#import "CityPickerViewController.h"
#import "CityModel.h"
@interface RootViewController ()<CAAnimationDelegate>

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
    self.view.backgroundColor = [UIColor whiteColor];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getGo:(UIButton*)sender {
    CityPickerViewController *vc = [CityPickerViewController new];
    [self BottomPushViewController:vc];
    vc.selectCityModelHandler = ^(CityModel *model){
        [sender setTitle:model.CityName forState:0];
    };
}

- (IBAction)getBack:(UIButton*)sender {
    CityPickerViewController *vc = [CityPickerViewController new];
    [self BottomPushViewController:vc];
    vc.selectCityModelHandler = ^(CityModel *model){
         [sender setTitle:model.CityName forState:0];
    };

}
#pragma mark 向上推入动画
-(void)BottomPushViewController:(UIViewController *)VC
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController pushViewController:VC animated:NO];
    
}
@end
