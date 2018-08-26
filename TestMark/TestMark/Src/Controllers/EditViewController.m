//
//  EditViewController.m
//  TestMark
//
//  Created by 柴栓柱 on 2018/7/18.
//  Copyright © 2018年 柴栓柱. All rights reserved.
//

#import "EditViewController.h"
#import "TextViewController.h"
#import "WebViewController.h"
#import "MenuView.h"

@interface EditViewController ()<UIScrollViewDelegate>

@property (nonatomic, weak) TextViewController *textVC;
@property (nonatomic, weak) WebViewController *webVC;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"预览" style:UIBarButtonItemStyleDone target:self action:@selector(preview)];
    //  初始化赋值
    self.webVC.text = [NSString stringWithContentsOfFile:kCurrentFile encoding:NSUTF8StringEncoding error:nil];
    
    //  文本改变时重新赋值
    self.textVC.textChangedHandler = ^(NSString *text) {
        self.webVC.text = text;
    };
    // Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.webVC.view.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height - 64);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[TextViewController class]]) {
        self.textVC = segue.destinationViewController;
    } else if ([segue.destinationViewController isKindOfClass:[WebViewController class]]) {
        self.webVC = segue.destinationViewController;
    }
}

#pragma mark -UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x > kScreen_Width - 10) {
        [self showExport:YES];
    } else {
        [self showExport:NO];
    }
}

- (void)showExport:(BOOL)show {
    [self.textVC.textView resignFirstResponder];
    if (show) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(shouldBack)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"export"] style:UIBarButtonItemStyleDone target:self action:@selector(showExportMenu)];
        
    } else{
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"预览" style:UIBarButtonItemStyleDone target:self action:@selector(preview)];
    }
}

- (void)preview {
    [_scrollView setContentOffset:CGPointMake(kScreen_Width, 0) animated:YES];
}

- (void)showExportMenu {
    
    NSArray *items = @[@"PDF",@"Image",@"Markdown",@"HTML"];
    CGPoint position = CGPointMake(kScreen_Width - 140, 65);
    
    MenuView *menuView = [[MenuView alloc]init:items position:position textAlignment:NSTextAlignmentCenter selectedChanged:^(NSInteger index) {
        NSURL *url = [self.webVC url:index];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:@[url] applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    }];
    [menuView show];
}

- (void)shouldBack {
    if (_scrollView.contentOffset.x > 10) {
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

@end
