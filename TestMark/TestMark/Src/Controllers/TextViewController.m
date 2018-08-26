//
//  TextViewController.m
//  TestMark
//
//  Created by 柴栓柱 on 2018/7/18.
//  Copyright © 2018年 柴栓柱. All rights reserved.
//

#import "TextViewController.h"
#import <YYTextView.h>
#import "MarkdownParser.h"
#import "AssistBar.h"

@interface TextViewController () <YYTextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet UIButton *redoButton;
- (IBAction)undoAction:(UIButton *)sender;
- (IBAction)redoAction:(UIButton *)sender;
@end

@implementation TextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *text = [NSString stringWithContentsOfFile:kCurrentFile encoding:NSUTF8StringEncoding error:nil];
    
    MarkdownParser *parser = [MarkdownParser new];
    [parser setColorWithDefaultTheme];
    
    _textView.text = text;
    _textView.font = [UIFont systemFontOfSize:14];
    _textView.textParser = parser;
    _textView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    _textView.delegate = self;
    _textView.allowsUndoAndRedo = YES; /// Undo and Redo
    _textView.maximumUndoLevel = 10; /// Undo level
    _textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    _textView.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.00];
    _textView.scrollIndicatorInsets = _textView.contentInset;
    _textView.selectedRange = NSMakeRange(text.length, 0);
    
    AssistBar *assistBar = [[NSBundle mainBundle]loadNibNamed:@"AssistBar" owner:self options:nil].firstObject;
    assistBar.textView = self.textView;
    assistBar.viewController = self;
    self.textView.inputAccessoryView = assistBar;

    _countLabel.text = [NSString stringWithFormat:@"%ld 字",_textView.text.length];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationWillTerminate) name:@"UIApplicationWillTerminate" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self saveFile];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)textViewDidChange:(YYTextView *)textView {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.redoButton.enabled = textView.undoManager.canRedo ? YES : NO;
        self.undoButton.enabled = textView.undoManager.canUndo ? YES : NO;
    });

    if (_textChangedHandler) {
        _textChangedHandler(textView.text);
    }
    
    _countLabel.text = [NSString stringWithFormat:@"%ld 字",textView.text.length];
}

- (void)textViewDidEndEditing:(YYTextView *)textView {
    [self saveFile];
}

- (void)applicationWillTerminate {
    [self saveFile];
}

- (void)saveFile {
    NSString *text = _textView.text;
    [text writeToFile:kCurrentFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
}


- (IBAction)undoAction:(UIButton *)sender {
    [_textView.undoManager undo];
}

- (IBAction)redoAction:(UIButton *)sender {
    [_textView.undoManager redo];
}

@end
