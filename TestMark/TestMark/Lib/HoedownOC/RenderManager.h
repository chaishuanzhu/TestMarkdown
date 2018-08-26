//
//  RenderManager.h
//  TestMark
//
//  Created by 柴栓柱 on 2018/7/18.
//  Copyright © 2018年 柴栓柱. All rights reserved.
//  https://github.com/zhubinchen/MarkLite

#import <Foundation/Foundation.h>

@interface RenderManager : NSObject

+ (instancetype)shared;

/**
 把markdown文档渲染成html网页

 @param markdown markdown文本
 @return html文本
 */
- (NSString *)render:(NSString *)markdown;

@end
