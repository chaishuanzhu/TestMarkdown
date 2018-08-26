//
//  WebViewController.h
//  TestMark
//
//  Created by 柴栓柱 on 2018/7/18.
//  Copyright © 2018年 柴栓柱. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ExportTypePDF,
    ExportTypeImage,
    ExportTypeMarkdown,
    ExportTypeHTML
} ExportType;

@interface WebViewController : UIViewController

/**
 要渲染的markdown文本
 */
@property (nonatomic, copy) NSString *text;

- (NSURL *)url:(ExportType)type;

@end
