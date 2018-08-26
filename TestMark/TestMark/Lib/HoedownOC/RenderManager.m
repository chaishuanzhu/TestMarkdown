//
//  RenderManager.m
//  TestMark
//
//  Created by 柴栓柱 on 2018/7/18.
//  Copyright © 2018年 柴栓柱. All rights reserved.
//

#import "RenderManager.h"
#import "HoedownWrapper.h"

@interface RenderManager ()

@property (nonatomic, copy) NSString *htmlFormat;

@property (nonatomic, copy) NSString *htmlStyleURL;

@property (nonatomic, copy) NSString *highlightStyleURL;

@property (nonatomic, copy) NSString *highlightjs1URL;

@property (nonatomic, copy) NSString *highlightjs2URL;

@end

@implementation RenderManager


+ (instancetype)shared {
    static RenderManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (NSString *)htmlFormat {
    if (!_htmlFormat) {
        _htmlFormat = @"<!DOCTYPE html><html><head><meta charset=\"utf-8\"><link rel=\"stylesheet\" href=\"%@\"/><link rel=\"stylesheet\" href=\"%@\"/><script src=\"%@\"></script><script src=\"%@\"></script><script>hljs.initHighlightingOnLoad();</script></head><body>%@</body></html>";
    }
    return _htmlFormat;
}

- (NSString *)htmlStyleURL {
    if (!_htmlStyleURL) {
        _htmlStyleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"GitHub-style.css" ofType:nil]].absoluteString;
    }
    return _htmlStyleURL;
}

- (NSString *)highlightStyleURL {
    if (!_highlightStyleURL) {
        _highlightStyleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"github.css" ofType:nil]].absoluteString;
    }
    return _highlightStyleURL;
}

- (NSString *)highlightjs1URL {
    if (!_highlightjs1URL) {
        _highlightjs1URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"highlight.min.js" ofType:nil]].absoluteString;
    }
    return _highlightjs1URL;
}

- (NSString *)highlightjs2URL {
    if (!_highlightjs2URL) {
        _highlightjs2URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"swift.min.js" ofType:nil]].absoluteString;
    }
    return _highlightjs2URL;
}

- (NSString *)render:(NSString *)markdown {
    
    HoedownWrapper *wrapper = [[HoedownWrapper alloc] initWithString:markdown];
    wrapper.renderOptions = HOEDOWN_HTML_HARD_WRAP | HOEDOWN_HTML_USE_TASK_LIST | HOEDOWN_HTML_BLOCKCODE_LINE_NUMBERS;
    wrapper.hoedownExtentions = HOEDOWN_EXT_MATH // 9
    | HOEDOWN_EXT_MATH_EXPLICIT // 13
    | HOEDOWN_EXT_FOOTNOTES // 2
    | HOEDOWN_LI_BLOCK // 1
    | HOEDOWN_EXT_FENCED_CODE // 1
    | HOEDOWN_EXT_HIGHLIGHT // 6
    | HOEDOWN_EXT_TABLES; // 0
    NSString *body = [wrapper HTML];
    
    return [NSString stringWithFormat:self.htmlFormat,self.htmlStyleURL,self.highlightStyleURL,self.highlightjs1URL,self.highlightjs2URL,body];
}

@end
