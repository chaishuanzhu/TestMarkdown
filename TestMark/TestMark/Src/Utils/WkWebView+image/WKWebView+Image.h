//
//  WKWebView+Image.h
//  NiuduFinance
//
//  Created by 123 on 2018/2/5.
//  Copyright © 2018年 liuyong. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WKWebView (Image)

/*
 *通过js获取htlm中图片url
 */
- (NSArray *)getImageUrlByJS:(WKWebView *)wkWebView;

//显示大图
- (BOOL)showBigImage:(NSURLRequest *)request;

@end
