//
//  MarkdownParser.m
//  TestMark
//
//  Created by 柴栓柱 on 2018/7/20.
//  Copyright © 2018年 柴栓柱. All rights reserved.
//

#import "MarkdownParser.h"
#import <YYCGUtilities.h>
#import <YYTextUtilities.h>
#import <YYTextAttribute.h>
#import <NSAttributedString+YYText.h>
#import <NSParagraphStyle+YYText.h>
#import <UIFont+YYAdd.h>

#pragma mark - Markdown Parser

@implementation MarkdownParser {
    UIFont *_font;
    NSMutableArray *_headerFonts; ///< h1~h6
    UIFont *_boldFont;
    UIFont *_italicFont;
    UIFont *_boldItalicFont;
    UIFont *_monospaceFont;
    YYTextBorder *_border;
    
    NSRegularExpression *_regexEscape;          ///< escape
    NSRegularExpression *_regexHeader;          ///< #header
    NSRegularExpression *_regexH1;              ///< header\n====
    NSRegularExpression *_regexH2;              ///< header\n----
    NSRegularExpression *_regexBreakline;       ///< ******
    NSRegularExpression *_regexEmphasis;        ///< *text*  _text_
    NSRegularExpression *_regexStrong;          ///< **text**
    NSRegularExpression *_regexStrongEmphasis;  ///< ***text*** ___text___
    NSRegularExpression *_regexUnderline;       ///< __text__
    NSRegularExpression *_regexStrikethrough;   ///< ~~text~~
    NSRegularExpression *_regexInlineCode;      ///< `text`
    NSRegularExpression *_regexLink;            ///< [name](link)
    NSRegularExpression *_regexLinkRefer;       ///< [ref]:
    NSRegularExpression *_regexList;            ///< 1.text 2.text 3.text
    NSRegularExpression *_regexBlockQuote;      ///< > quote
    NSRegularExpression *_regexCodeBlock;       ///< \tcode \tcode
    NSRegularExpression *_regexNotEmptyLine;
}

- (void)initRegex {
#define regexp(reg, option) [NSRegularExpression regularExpressionWithPattern : @reg options : option error : NULL]
    _regexEscape = regexp("(\\\\\\\\|\\\\\\`|\\\\\\*|\\\\\\_|\\\\\\(|\\\\\\)|\\\\\\[|\\\\\\]|\\\\#|\\\\\\+|\\\\\\-|\\\\\\!)", 0);
    _regexHeader = regexp("^((\\#{1,6}[^#].*)|(\\#{6}.+))$", NSRegularExpressionAnchorsMatchLines);
    _regexH1 = regexp("^[^=\\n][^\\n]*\\n=+$", NSRegularExpressionAnchorsMatchLines);
    _regexH2 = regexp("^[^-\\n][^\\n]*\\n-+$", NSRegularExpressionAnchorsMatchLines);
    _regexBreakline = regexp("^[ \\t]*([*-])[ \\t]*((\\1)[ \\t]*){2,}[ \\t]*$", NSRegularExpressionAnchorsMatchLines);
    _regexEmphasis = regexp("((?<!\\*)\\*(?=[^ \\t*])(.+?)(?<=[^ \\t*])\\*(?!\\*)|(?<!_)_(?=[^ \\t_])(.+?)(?<=[^ \\t_])_(?!_))", 0);
    _regexStrong = regexp("(?<!\\*)\\*{2}(?=[^ \\t*])(.+?)(?<=[^ \\t*])\\*{2}(?!\\*)", 0);
    _regexStrongEmphasis =  regexp("((?<!\\*)\\*{3}(?=[^ \\t*])(.+?)(?<=[^ \\t*])\\*{3}(?!\\*)|(?<!_)_{3}(?=[^ \\t_])(.+?)(?<=[^ \\t_])_{3}(?!_))", 0);
    _regexUnderline = regexp("(?<!_)__(?=[^ \\t_])(.+?)(?<=[^ \\t_])\\__(?!_)", 0);
    _regexStrikethrough = regexp("(?<!~)~~(?=[^ \\t~])(.+?)(?<=[^ \\t~])\\~~(?!~)", 0);
    _regexInlineCode = regexp("(?<!`)(`{1,3})([^`\n]+?)\\1(?!`)", 0);
    _regexLink = regexp("!?\\[([^\\[\\]]+)\\](\\(([^\\(\\)]+)\\)|\\[([^\\[\\]]+)\\])", 0);
    _regexLinkRefer = regexp("^[ \\t]*\\[[^\\[\\]]\\]:", NSRegularExpressionAnchorsMatchLines);
    _regexList = regexp("^[ \\t]*([*+-]|\\d+[.])[ \\t]+", NSRegularExpressionAnchorsMatchLines);
    _regexBlockQuote = regexp("^[ \\t]*>[ \\t>]*", NSRegularExpressionAnchorsMatchLines);
    _regexCodeBlock = regexp("(^\\s*$\\n)((( {4}|\\t).*(\\n|\\z))|(^\\s*$\\n))+", NSRegularExpressionAnchorsMatchLines);
    _regexNotEmptyLine = regexp("^[ \\t]*[^ \\t]+[ \\t]*$", NSRegularExpressionAnchorsMatchLines);
#undef regexp
}

- (instancetype)init {
    self = [super init];
    _fontSize = 14;
    _headerFontSize = 20;
    [self _updateFonts];
    [self setColorWithBrightTheme];
    [self initRegex];
    return self;
}

- (void)setFontSize:(CGFloat)fontSize {
    if (fontSize < 1) fontSize = 12;
    _fontSize = fontSize;
    [self _updateFonts];
}

- (void)setHeaderFontSize:(CGFloat)headerFontSize {
    if (headerFontSize < 1) headerFontSize = 20;
    _headerFontSize = headerFontSize;
    [self _updateFonts];
}

- (void)_updateFonts {
    _font = [UIFont systemFontOfSize:_fontSize];
    _headerFonts = [NSMutableArray new];
    for (int i = 0; i < 6; i++) {
        CGFloat size = _headerFontSize - (_headerFontSize - _fontSize) / 5.0 * i;
        [_headerFonts addObject:[UIFont systemFontOfSize:size]];
    }
    _boldFont = [_font fontWithBold];
    _italicFont = [_font fontWithItalic];
    _boldItalicFont = [_font fontWithBoldItalic];
    _monospaceFont = [UIFont fontWithName:@"Menlo" size:_fontSize]; // Since iOS 7
    if (!_monospaceFont) _monospaceFont = [UIFont fontWithName:@"Courier" size:_fontSize]; // Since iOS 3
}

- (void)setColorWithBrightTheme {
    _textColor = [UIColor blackColor];
    _controlTextColor = [UIColor colorWithWhite:0.749 alpha:1.000];
    _headerTextColor = [UIColor colorWithRed:1.000 green:0.502 blue:0.000 alpha:1.000];
    _inlineTextColor = [UIColor colorWithWhite:0.150 alpha:1.000];
    _codeTextColor = [UIColor colorWithWhite:0.150 alpha:1.000];
    _linkTextColor = [UIColor colorWithRed:0.000 green:0.478 blue:0.962 alpha:1.000];
    
    _border = [YYTextBorder new];
    _border.lineStyle = YYTextLineStyleSingle;
    _border.fillColor = [UIColor colorWithWhite:0.184 alpha:0.090];
    _border.strokeColor = [UIColor colorWithWhite:0.546 alpha:0.650];
    _border.insets = UIEdgeInsetsMake(-1, 0, -1, 0);
    _border.cornerRadius = 2;
    _border.strokeWidth = CGFloatFromPixel(1);
}

- (void)setColorWithDarkTheme {
    _textColor = [UIColor whiteColor];
    _controlTextColor = [UIColor colorWithWhite:0.604 alpha:1.000];
    _headerTextColor = [UIColor colorWithRed:0.558 green:1.000 blue:0.502 alpha:1.000];
    _inlineTextColor = [UIColor colorWithRed:1.000 green:0.862 blue:0.387 alpha:1.000];
    _codeTextColor = [UIColor colorWithWhite:0.906 alpha:1.000];
    _linkTextColor = [UIColor colorWithRed:0.000 green:0.646 blue:1.000 alpha:1.000];
    
    _border = [YYTextBorder new];
    _border.lineStyle = YYTextLineStyleSingle;
    _border.fillColor = [UIColor colorWithWhite:0.820 alpha:0.130];
    _border.strokeColor = [UIColor colorWithWhite:1.000 alpha:0.280];
    _border.insets = UIEdgeInsetsMake(-1, 0, -1, 0);
    _border.cornerRadius = 2;
    _border.strokeWidth = CGFloatFromPixel(1);
}

- (void)setColorWithDefaultTheme {
    _textColor = [UIColor colorWithRed:0.11 green:0.13 blue:0.15 alpha:1.00];
    _controlTextColor = [UIColor colorWithRed:0.24 green:0.25 blue:0.68 alpha:1.00];
    _headerTextColor = [UIColor colorWithRed:0.24 green:0.25 blue:0.68 alpha:1.00];
    _inlineTextColor = [UIColor colorWithRed:0.05 green:0.23 blue:0.27 alpha:1.00];
    _codeTextColor = [UIColor colorWithRed:0.05 green:0.22 blue:0.27 alpha:1.00];
    _linkTextColor = [UIColor colorWithRed:0.22 green:0.35 blue:0.61 alpha:1.00];
    
    _border = [YYTextBorder new];
    _border.lineStyle = YYTextLineStyleSingle;
    _border.fillColor = [UIColor colorWithWhite:0.820 alpha:0.130];
    _border.strokeColor = [UIColor colorWithWhite:1.000 alpha:0.280];
    _border.insets = UIEdgeInsetsMake(-1, 0, -1, 0);
    _border.cornerRadius = 2;
    _border.strokeWidth = CGFloatFromPixel(1);
}

- (NSUInteger)lenghOfBeginWhiteInString:(NSString *)str withRange:(NSRange)range{
    for (NSUInteger i = 0; i < range.length; i++) {
        unichar c = [str characterAtIndex:i + range.location];
        if (c != ' ' && c != '\t' && c != '\n') return i;
    }
    return str.length;
}

- (NSUInteger)lenghOfEndWhiteInString:(NSString *)str withRange:(NSRange)range{
    for (NSInteger i = range.length - 1; i >= 0; i--) {
        unichar c = [str characterAtIndex:i + range.location];
        if (c != ' ' && c != '\t' && c != '\n') return range.length - i;
    }
    return str.length;
}

- (NSUInteger)lenghOfBeginChar:(unichar)c inString:(NSString *)str withRange:(NSRange)range{
    for (NSUInteger i = 0; i < range.length; i++) {
        if ([str characterAtIndex:i + range.location] != c) return i;
    }
    return str.length;
}

- (BOOL)parseText:(NSMutableAttributedString *)text selectedRange:(NSRangePointer)range {
    if (text.length == 0) return NO;
    [text removeAttributesInRange:NSMakeRange(0, text.length)];
    text.font = _font;
    text.color = _textColor;
    
    NSMutableString *str = text.string.mutableCopy;
    [_regexEscape replaceMatchesInString:str options:kNilOptions range:NSMakeRange(0, str.length) withTemplate:@"@@"];
    
    [_regexHeader enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        NSUInteger whiteLen = [self lenghOfBeginWhiteInString:str withRange:r];
        NSUInteger sharpLen = [self lenghOfBeginChar:'#' inString:str withRange:NSMakeRange(r.location + whiteLen, r.length - whiteLen)];
        if (sharpLen > 6) sharpLen = 6;
        [text setColor:self->_controlTextColor range:NSMakeRange(r.location, whiteLen + sharpLen)];
        [text setColor:self->_headerTextColor range:NSMakeRange(r.location + whiteLen + sharpLen, r.length - whiteLen - sharpLen)];
        [text setFont:self->_headerFonts[sharpLen - 1] range:result.range];
    }];
    
    [_regexH1 enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        NSRange linebreak = [str rangeOfString:@"\n" options:0 range:result.range locale:nil];
        if (linebreak.location != NSNotFound) {
            [text setColor:self->_headerTextColor range:NSMakeRange(r.location, linebreak.location - r.location)];
            [text setFont:self->_headerFonts[0] range:NSMakeRange(r.location, linebreak.location - r.location + 1)];
            [text setColor:self->_controlTextColor range:NSMakeRange(linebreak.location + linebreak.length, r.location + r.length - linebreak.location - linebreak.length)];
        }
    }];
    
    [_regexH2 enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        NSRange linebreak = [str rangeOfString:@"\n" options:0 range:result.range locale:nil];
        if (linebreak.location != NSNotFound) {
            [text setColor:self->_headerTextColor range:NSMakeRange(r.location, linebreak.location - r.location)];
            [text setFont:self->_headerFonts[1] range:NSMakeRange(r.location, linebreak.location - r.location + 1)];
            [text setColor:self->_controlTextColor range:NSMakeRange(linebreak.location + linebreak.length, r.location + r.length - linebreak.location - linebreak.length)];
        }
    }];
    
    [_regexBreakline enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [text setColor:self->_controlTextColor range:result.range];
    }];
    
    [_regexEmphasis enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        [text setColor:self->_controlTextColor range:NSMakeRange(r.location, 1)];
        [text setColor:self->_controlTextColor range:NSMakeRange(r.location + r.length - 1, 1)];
        [text setFont:self->_italicFont range:NSMakeRange(r.location + 1, r.length - 2)];
    }];
    
    [_regexStrong enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        [text setColor:self->_controlTextColor range:NSMakeRange(r.location, 2)];
        [text setColor:self->_controlTextColor range:NSMakeRange(r.location + r.length - 2, 2)];
        [text setFont:self->_boldFont range:NSMakeRange(r.location + 2, r.length - 4)];
    }];
    
    [_regexStrongEmphasis enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        [text setColor:self->_controlTextColor range:NSMakeRange(r.location, 3)];
        [text setColor:self->_controlTextColor range:NSMakeRange(r.location + r.length - 3, 3)];
        [text setFont:self->_boldItalicFont range:NSMakeRange(r.location + 3, r.length - 6)];
    }];
    
    [_regexUnderline enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        [text setColor:self->_controlTextColor range:NSMakeRange(r.location, 2)];
        [text setColor:self->_controlTextColor range:NSMakeRange(r.location + r.length - 2, 2)];
        [text setTextUnderline:[YYTextDecoration decorationWithStyle:YYTextLineStyleSingle width:@1 color:nil] range:NSMakeRange(r.location + 2, r.length - 4)];
    }];
    
    [_regexStrikethrough enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        [text setColor:self->_controlTextColor range:NSMakeRange(r.location, 2)];
        [text setColor:self->_controlTextColor range:NSMakeRange(r.location + r.length - 2, 2)];
        [text setTextStrikethrough:[YYTextDecoration decorationWithStyle:YYTextLineStyleSingle width:@1 color:nil] range:NSMakeRange(r.location + 2, r.length - 4)];
    }];
    
    [_regexInlineCode enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        NSUInteger len = [self lenghOfBeginChar:'`' inString:str withRange:r];
        [text setColor:self->_controlTextColor range:NSMakeRange(r.location, len)];
        [text setColor:self->_controlTextColor range:NSMakeRange(r.location + r.length - len, len)];
        [text setColor:self->_inlineTextColor range:NSMakeRange(r.location + len, r.length - 2 * len)];
        [text setFont:self->_monospaceFont range:r];
        [text setTextBorder:self->_border.copy range:r];
    }];
    
    [_regexLink enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        [text setColor:self->_linkTextColor range:r];
    }];
    
    [_regexLinkRefer enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        [text setColor:self->_controlTextColor range:r];
    }];
    
    [_regexList enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        [text setColor:self->_controlTextColor range:r];
    }];
    
    [_regexBlockQuote enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        [text setColor:self->_controlTextColor range:r];
    }];
    
    [_regexCodeBlock enumerateMatchesInString:str options:0 range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange r = result.range;
        NSRange firstLineRange = [self->_regexNotEmptyLine rangeOfFirstMatchInString:str options:kNilOptions range:r];
        NSUInteger lenStart = (firstLineRange.location != NSNotFound) ? firstLineRange.location - r.location : 0;
        NSUInteger lenEnd = [self lenghOfEndWhiteInString:str withRange:r];
        if (lenStart + lenEnd < r.length) {
            NSRange codeR = NSMakeRange(r.location + lenStart, r.length - lenStart - lenEnd);
            [text setColor:self->_codeTextColor range:codeR];
            [text setFont:self->_monospaceFont range:codeR];
            YYTextBorder *border = [YYTextBorder new];
            border.lineStyle = YYTextLineStyleSingle;
            border.fillColor = [UIColor colorWithWhite:0.184 alpha:0.090];
            border.strokeColor = [UIColor colorWithWhite:0.200 alpha:0.300];
            border.insets = UIEdgeInsetsMake(-1, 0, -1, 0);
            border.cornerRadius = 3;
            border.strokeWidth = CGFloatFromPixel(2);
            [text setTextBlockBorder:self->_border.copy range:codeR];
        }
    }];
    
    return YES;
}

@end
