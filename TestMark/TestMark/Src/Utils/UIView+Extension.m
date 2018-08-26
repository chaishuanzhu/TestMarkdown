//
//  UIView+Extension.m
//  TestMark
//
//  Created by 柴栓柱 on 2018/7/19.
//  Copyright © 2018年 柴栓柱. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)

- (instancetype)init:(UIView *)superView padding:(CGFloat)padding {
    self = [self initWithFrame:CGRectMake(superView.frame.origin.x + padding, superView.frame.origin.y + padding, superView.frame.size.width - padding * 2, superView.frame.size.height - padding * 2)];
    return self;
}

@end
