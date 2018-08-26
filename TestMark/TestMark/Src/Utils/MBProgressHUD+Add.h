//
//  MBProgressHUD+Add.h
//  p2p
//
//  Created by 柴栓柱 on 2018/6/21.
//  Copyright © 2018年 柴栓柱. All rights reserved.
//

#import <MBProgressHUD.h>

/**  < 最小显示时间 >  */
UIKIT_EXTERN NSTimeInterval const kMinShowTime;
/**  < 显示几秒后消失 >  */
UIKIT_EXTERN NSTimeInterval const KHideAfterDelayTime;
/**  < 菊花最少显示时间 >  */
UIKIT_EXTERN NSTimeInterval const kActivityMinDismissTime;

@interface MBProgressHUD (Add)

#pragma mark ------ < Mask Layer > ------
#pragma mark
/** << 设置是否显示蒙层 > */
+ (void)maskLayerEnabled:(BOOL)enabled;

#pragma mark --------  Basic Method  --------
#pragma mark
/**
 *  快速创建提示框 有菊花
 *
 *  @param message 提示信息
 *  @param view 显示视图
 *  @return hud
 */
+ (MBProgressHUD *)showActivityMessage:(NSString *)message
                                   toView:(UIView *)view;
/**
 *  显示提示文字
 *
 *  @param message 提示信息
 *  @param view 显示的视图
 */
+ (void)showMessage:(NSString *)message
                toView:(UIView *)view
            completion:(MBProgressHUDCompletionBlock)completion;
/**
 *  自定义成功提示
 *
 *  @param success 提示文字
 *  @param view 显示视图
 */
+ (void)showSuccess:(NSString *)success
                toView:(UIView *)view
            completion:(MBProgressHUDCompletionBlock)completion;
/**
 *  自定义失败提示
 *
 *  @param error 提示文字
 *  @param view 显示视图
 */
+ (void)showError:(NSString *)error
              toView:(UIView *)view
          completion:(MBProgressHUDCompletionBlock)completion;
/**
 *  自定义提示信息
 *
 *  @param info 提示信息
 *  @param view 示视图
 */
+ (void)showInfo:(NSString *)info
             toView:(UIView *)view
         completion:(MBProgressHUDCompletionBlock)completion;

/**
 *  自定义警告提示
 *
 *  @param warning 提示信息
 *  @param view 示视图
 */
+ (void)showWarning:(NSString *)warning
                toView:(UIView *)view
            completion:(MBProgressHUDCompletionBlock)completion;

/**
 *  自定义提示框
 *
 *  @param text 提示文字
 *  @param icon 图片名称
 *  @param view 展示视图
 */
+ (void)show:(NSString *)text
           icon:(NSString *)icon
           view:(UIView *)view
     completion:(MBProgressHUDCompletionBlock)completion;

#pragma mark --------  Activity && Text  --------
#pragma mark
/**  < 只显示菊花 >  */
+ (MBProgressHUD *)showActivity;
/**  < 菊花带有文字 >  */
+ (MBProgressHUD *)showActivityMessage:(NSString *)message;

#pragma mark --------  Text && Image  --------
#pragma mark

/**
 文字提示
 @param message 提示文字
 @param completion 完成回调
 */
+ (void)showMessage:(NSString *)message
            completion:(MBProgressHUDCompletionBlock)completion;

/**
 成功提示
 @param success 提示文字
 @param completion 完成回调
 */
+ (void)showSuccess:(NSString *)success
            completion:(MBProgressHUDCompletionBlock)completion;

/**
 错误提示
 @param error 提示文字
 @param completion 完成回调
 */
+ (void)showError:(NSString *)error
          completion:(MBProgressHUDCompletionBlock)completion;

/**
 信息提示
 @param info 提示文字
 @param completion 完成回调
 */
+ (void)showInfo:(NSString *)info
         completion:(MBProgressHUDCompletionBlock)completion;

/**
 警告提示
 @param warning 提示文字
 @param completion 完成回调
 */
+ (void)showWarning:(NSString *)warning
            completion:(MBProgressHUDCompletionBlock)completion;

#pragma mark --------  Hide  --------
#pragma mark
+ (void)hideHUD;
+ (void)hideHUDForView:(UIView *)view;

@end
