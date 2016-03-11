//
//  GestureView.h
//  手势
//
//  Created by Jack on 16/2/29.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GestureView : UIView
//手势绘制错误
@property (copy, nonatomic) void (^errorHanle)(NSString *error);
//开始绘制时操作
@property (copy, nonatomic) void (^touchStart)(void);
//手势正确绘制结束返回触摸点
@property (copy, nonatomic) void (^touchEnd)(NSString *gestures);

@end
