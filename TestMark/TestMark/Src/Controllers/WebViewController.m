//
//  WebViewController.m
//  TestMark
//
//  Created by 柴栓柱 on 2018/7/18.
//  Copyright © 2018年 柴栓柱. All rights reserved.
//

#import "WebViewController.h"
#import "RenderManager.h"
#import <WebKit/WebKit.h>
#import "WKWebView+Image.h"

@interface WebViewController ()<WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet WKWebView *webView;

@property (nonatomic, copy) NSString *htmlString;

@end

@implementation WebViewController

- (void)setText:(NSString *)text {
    self.htmlString = [[RenderManager shared]render:text];
}

- (void)setHtmlString:(NSString *)htmlString {
    [self.webView loadHTMLString:htmlString baseURL:[[NSBundle mainBundle] bundleURL]];
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.chaisz.xyz/articles/%E6%9C%8D%E5%8A%A1%E5%99%A8/5/linux-kai-qi-samba-fu-wu"]]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.scrollView.bounces = NO;
    self.webView.navigationDelegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSURL *)url:(ExportType)type {
    if (type == ExportTypePDF) {
        
    } else if (type == ExportTypeImage) {
        
    } else if (type == ExportTypeMarkdown) {
        
    } else if (type == ExportTypeHTML) {
        
    }
    return nil;
}

#pragma mark -WKWebViewDelegate
// 类似 UIWebView 的 －webViewDidFinishLoad:
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    //通过js获取htlm中图片url
    [webView getImageUrlByJS:webView];
}

// 类似 UIWebView 的 -webView: shouldStartLoadWithRequest: navigationType:

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    [webView showBigImage:navigationAction.request];
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
