//
//  TextViewController.h
//  TestMark
//
//  Created by 柴栓柱 on 2018/7/18.
//  Copyright © 2018年 柴栓柱. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYTextView.h>
@interface TextViewController : UIViewController

@property (weak, nonatomic) IBOutlet YYTextView *textView;

@property (nonatomic, copy) void (^textChangedHandler)(NSString *text);

@end
