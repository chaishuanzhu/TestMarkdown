//
//  UIAlertController+Extension.h
//  TestMark
//
//  Created by 柴栓柱 on 2018/7/23.
//  Copyright © 2018年 柴栓柱. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Extension)

+ (UIAlertController *)showAlert:(NSString *)title
                         message:(NSString *)message
                    actionTitles:(NSArray *)titles
   textFieldconfigurationHandler:(void (^)(UITextField *textField))textFieldHandler
                   actionHandler:(void (^)(int index))actionHandler;

+ (UIAlertController *)showActionSheet:(NSString *)title
                               message:(NSString *)message
                          actionTitles:(NSArray *)titles
                         actionHandler:(void (^)(int index))actionHandler;

@end
