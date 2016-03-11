//
//  ViewController.m
//  GestureHandle
//
//  Created by Jack on 16/3/11.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import "ViewController.h"
#import "GestureView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GestureView *view = [[GestureView alloc]initWithFrame:CGRectMake(0, 200, 375, 400)];
    view.backgroundColor = [UIColor grayColor];
    //GestureView *view = [[GestureView alloc]init];
    __weak ViewController *weakSelf = self;
    [view setErrorHanle:^(NSString *error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:error preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:action];
        [weakSelf presentViewController:alert animated:NO completion:nil];
    }];
    
    [view setTouchStart:^{
        NSLog(@"开始触摸");
    }];
    [view setTouchEnd:^(NSString *gestures) {
        NSLog(@"gestures-%@",gestures);
    }];
    [self.view addSubview:view];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
