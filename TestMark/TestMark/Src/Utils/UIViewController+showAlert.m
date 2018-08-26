//
//  UIViewController+showAlert.m
//  TestMark
//
//  Created by 柴栓柱 on 2018/7/19.
//  Copyright © 2018年 柴栓柱. All rights reserved.
//

#import "UIViewController+showAlert.h"

@implementation UIViewController (showAlert)

- (UIAlertController *)showAlert:(NSString *)title message:(NSString *)message actionTitles:(NSArray *)titles textFieldconfigurationHandler:(void (^)(UITextField *))textFieldHandler actionHandler:(void (^)(int))actionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    for (int i = 0; i < titles.count; i++) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:titles[i] style:i==0?UIAlertActionStyleCancel:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            actionHandler(i);
        }];
        [alertController addAction:alertAction];
    }
    if (!titles) {
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:okAction];
    }
    if (textFieldHandler) {
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textFieldHandler(textField);
        }];
    }
    [self presentViewController:alertController animated:YES completion:nil];
    return alertController;
}

- (UIAlertController *)showActionSheet:(NSString *)title message:(NSString *)message actionTitles:(NSArray *)titles actionHandler:(void (^)(int))actionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (int i = 0; i < titles.count; i++) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:titles[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            actionHandler(i);
        }];
        [alertController addAction:alertAction];
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    return alertController;
}

@end
