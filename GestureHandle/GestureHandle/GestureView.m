//
//  GestureView.m
//  手势
//
//  Created by Jack on 16/2/29.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import "GestureView.h"
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self
@interface CircleLayer : CAShapeLayer

@property (nonatomic, getter=isSelected) BOOL selected;
@property (strong, nonatomic) CAShapeLayer *selectedLayer;
@property (strong, nonatomic) NSMutableDictionary *gesture;

@end

@implementation CircleLayer

- (void)setLayerWithFrame:(CGRect)frame{
    self.frame = frame;
    self.cornerRadius = CGRectGetWidth(frame) > CGRectGetHeight(frame) ? CGRectGetWidth(frame)/2:CGRectGetHeight(frame)/2;
    self.borderColor = [UIColor greenColor].CGColor;
    self.borderWidth = 1.0f;
    self.masksToBounds = YES;


}

#pragma mark -- setter
- (void)setSelected:(BOOL)selected{
    _selected = selected;
    if (_selected) {
        [self addSublayer:self.selectedLayer];
    }else{
        [self.selectedLayer removeFromSuperlayer];
    }
}

#pragma mark -- getter
- (CAShapeLayer *)selectedLayer{
    if (!_selectedLayer) {
        _selectedLayer = [CAShapeLayer layer];
        _selectedLayer.fillColor = [UIColor greenColor].CGColor;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2) radius:20 startAngle:0 endAngle:M_PI * 2 clockwise:NO];
        
        _selectedLayer.path = path.CGPath;
    }
    return _selectedLayer;
}

- (NSMutableDictionary *)gesture{
    if (!_gesture) {
        _gesture = [NSMutableDictionary dictionary];
    }
    return _gesture;
}
@end


@interface GestureView ()
@property (strong, nonatomic) NSMutableArray *gestures;
@property(nonatomic,assign)CGPoint currentpoint;

@end


@implementation GestureView

#pragma mark -- init

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self layoutTouchView];
    }
    return self;
}

#pragma mark -- layoutTouchView

- (void)layoutTouchView{
    for (NSInteger i = 0; i < 9; i++) {
        
        CGFloat btnW = 74;
        CGFloat btnH = 74;
        
        NSInteger totalColumns = 3;
        NSInteger col = i % totalColumns;
        NSInteger row = i / totalColumns;
        
        CGFloat marginX = (self.frame.size.width - totalColumns * btnW ) / (totalColumns + 1);
        CGFloat marginY = marginX;
        CGFloat btnX = marginX + col * (btnW + marginX);
        CGFloat btnY = row * (btnH + marginY) + marginY;
    
        CircleLayer *layer = [CircleLayer layer];
        [layer setLayerWithFrame:CGRectMake(btnX, btnY, btnW, btnH)];
        
        [layer.gesture setObject:NSStringFromCGPoint(CGPointMake(btnX + btnW/2, btnY + btnH/2)) forKey:@"center"];
        [layer.gesture setObject:[NSNumber numberWithInteger:i+1] forKey:@"index"];
        
        [self.layer addSublayer:layer];
        
    }
}


#pragma mark -- touch Handle
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.touchStart();
    [self getCurrentSelectedOnTouch:[self getTouchPoint:touches]];
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    if (self.gestures.count) {
        [self setNeedsDisplay];
    }
    [self getCurrentSelectedOnTouch:[self getTouchPoint:touches]];
    
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.gestures.count<4) {
        self.errorHanle(@"绘制手势密码不能小于4位");
        [self clearGesture];
        return;
    }
    NSMutableArray *touchIndexs = [NSMutableArray array];
    [self.gestures enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      [touchIndexs addObject:[obj objectForKey:@"index"]];
    }];
    
    self.touchEnd([touchIndexs componentsJoinedByString:@""]);
    [self clearGesture];

}

//手势异常处理
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self clearGesture];
}

//根据触摸点判断返回当前触摸的位置
- (NSInteger)getCurrentSelectedOnTouch:(CGPoint)point
{
    __block NSUInteger selectedIndex = -1;
    WS(weakSelf);
    [self.layer.sublayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CircleLayer *layer = (CircleLayer *)obj;
        
        if (CGRectContainsPoint(layer.frame, point) && !layer.isSelected) {
            [weakSelf.gestures addObject:layer.gesture];
            layer.selected = YES;
            NSNumber *index = [layer.gesture objectForKey:@"index"];
            selectedIndex = index.intValue;
        }
    }];
    
    return selectedIndex;
}

//清除所有手势
- (void)clearGesture{
    [self.layer.sublayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CircleLayer *layer = (CircleLayer *)obj;
        layer.selected = NO;
    }];
    [self.gestures removeAllObjects];
    [self setNeedsDisplay];
    
}
//获得当前触摸点
- (CGPoint)getTouchPoint:(NSSet<UITouch *> *)touches{
    UITouch *touch=[touches anyObject];
    self.currentpoint =[touch locationInView:touch.view];
    return self.currentpoint;
}

#pragma mark -- getter
- (NSMutableArray *)gestures{
    if (!_gestures) {
        _gestures = [NSMutableArray array];
    }
    return _gestures;
}

#pragma mark -- drawReact
- (void)drawRect:(CGRect)rect{
    if (!self.gestures.count) {
        return;
    }
    NSString *startPoint = [[self.gestures firstObject] objectForKey:@"center"];
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [self.gestures enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
            
            [path moveToPoint:CGPointFromString(startPoint)];
        }else {
            
            NSString *nextPoint = [obj objectForKey:@"center"];
            [path addLineToPoint:CGPointFromString(nextPoint)];
        }
    }];
    
    [path addLineToPoint:self.currentpoint];
    path.lineJoinStyle = kCGLineJoinBevel;
    path.lineCapStyle=kCGLineCapRound;
    path.lineWidth = 3.0f;
    [[UIColor greenColor] set];
    [path stroke];
}
@end
