//
//  MenuView.h
//  TestMark
//
//  Created by 柴栓柱 on 2018/7/19.
//  Copyright © 2018年 柴栓柱. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuView : UIView

- (instancetype)init:(NSArray *)items
             position:(CGPoint)position
       textAlignment:(NSTextAlignment)textAlignment
     selectedChanged:(void (^)(NSInteger index))selectedChanged;

- (void)show;

@end
