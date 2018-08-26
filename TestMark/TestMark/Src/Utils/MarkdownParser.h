//
//  MarkdownParser.h
//  TestMark
//
//  Created by 柴栓柱 on 2018/7/20.
//  Copyright © 2018年 柴栓柱. All rights reserved.
//

#import <YYTextParser.h>

@interface MarkdownParser : NSObject <YYTextParser>
@property (nonatomic) CGFloat fontSize;         ///< default is 14
@property (nonatomic) CGFloat headerFontSize;   ///< default is 20

@property (nullable, nonatomic, strong) UIColor *textColor;
@property (nullable, nonatomic, strong) UIColor *controlTextColor;
@property (nullable, nonatomic, strong) UIColor *headerTextColor;
@property (nullable, nonatomic, strong) UIColor *inlineTextColor;
@property (nullable, nonatomic, strong) UIColor *codeTextColor;
@property (nullable, nonatomic, strong) UIColor *linkTextColor;

- (void)setColorWithDefaultTheme;

@end
