//
//  HoedownWrapper.m
//  Marboo
//
//  Created by amoblin on 14/7/18.
//  Copyright (c) 2014年 amoblin. All rights reserved.
//

#import "HoedownWrapper.h"
#import "hoedown_html_patch.h"
#include "buffer.h"

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static const int kNestingLevel = 15;
static const size_t kBufferUnit = 64;

@interface HoedownWrapper ()
@property (nonatomic, strong) NSData *markdownData;
@end


@implementation HoedownWrapper

- (instancetype)initWithData:(NSData *)data
{
    if ((self = [super init])) {
        _markdownData = data;
    }
    return self;
}


- (instancetype)initWithString:(NSString *)string
{
    return [self initWithData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSString *)HTML;
{
    NSString *html = [self bodyHTML];
    NSRange range = [html rangeOfString:@"[TOC]" options:NSCaseInsensitiveSearch];
    if (range.location == NSNotFound) {
        return html;
    }
    return [html stringByReplacingOccurrencesOfString:@"[TOC]" withString:[self tableOfContentsHTML] options:NSCaseInsensitiveSearch range:range];
}

- (NSString *)bodyHTML;
{
    if ([self.markdownData length] == 0) {
        return nil;
    }
    hoedown_renderer *renderer = hoedown_html_renderer_new((hoedown_html_flags)self.renderOptions, kNestingLevel);
    renderer->listitem = hoedown_patch_render_listitem;
//    renderer->blockcode = hoedown_patch_render_blockcode;
    NSString *output = render(renderer, self);
    hoedown_html_renderer_free(renderer);

    return output;
}

- (NSString *)tableOfContentsHTML;
{
    if ([self.markdownData length] == 0) {
        return nil;
    }

    hoedown_renderer *renderer = hoedown_html_toc_renderer_new(kNestingLevel);
    NSString *output = render(renderer, self);
    hoedown_html_renderer_free(renderer);

    return output;
}


#pragma mark Internal methods

static inline NSString* render(const hoedown_renderer *renderer, HoedownWrapper *self)
{
    hoedown_document *document = hoedown_document_new(renderer, self.hoedownExtentions, kNestingLevel);

    hoedown_buffer *outputBuffer = hoedown_buffer_new(kBufferUnit);
    hoedown_buffer *sourceBuffer = hoedown_buffer_new(kBufferUnit);

    if (self.isSmartyPantsEnabled) {
        hoedown_html_smartypants(sourceBuffer, [self.markdownData bytes], [self.markdownData length]);
    } else {
        hoedown_buffer_put(sourceBuffer, [self.markdownData bytes], [self.markdownData length]);
    }

    hoedown_document_render(document, outputBuffer, sourceBuffer->data, sourceBuffer->size);
    NSString *output = @(hoedown_buffer_cstr(outputBuffer));

    hoedown_document_free(document);
    hoedown_buffer_free(outputBuffer);

    return output;
}

@end
