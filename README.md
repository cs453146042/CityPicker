# CityPicker
这是一个类似于携程商旅类型的城市选择器<br>

特性
------
1.无侵入性<br>
2.使用方便<br>

展示
------
![image](https://github.com/cs453146042/CityPicker/blob/master/CityPickerVideo1.gif)  

使用方法
------
1.将工程中CityPicker中的Citypicker文件夹拖入你要使用的工程<br>
2 调用下方函数即可 <br>
CityPickerViewController *vc = [CityPickerViewController new];<br>
    [self BottomPushViewController:vc];<br>
    vc.selectCityModelHandler = ^(CityModel *model){<br>
        [sender setTitle:model.CityName forState:0];<br>
    };<br>
3.如果想使用向上弹出的动画调用<br>
-(void)BottomPushViewController:(UIViewController *)VC<br>
{<br>
    CATransition *transition = [CATransition animation];<br>
    transition.duration = 0.4f;<br>
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];<br>
    transition.type = kCATransitionMoveIn;<br>
    transition.subtype = kCATransitionFromTop;<br>
    transition.delegate = self;<br>
    [self.navigationController.view.layer addAnimation:transition forKey:nil];<br>
    [self.navigationController pushViewController:VC animated:NO];<br>
}<br>
4.完成<br>

