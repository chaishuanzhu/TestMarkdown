//
//  MenuView.m
//  TestMark
//
//  Created by 柴栓柱 on 2018/7/19.
//  Copyright © 2018年 柴栓柱. All rights reserved.
//

#import "MenuView.h"
#import "UIView+Extension.h"

@interface MenuView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) CGFloat cellHeight;

@property (nonatomic, copy) void (^ selectedChanged)(NSInteger index);

@property (nonatomic) NSTextAlignment textAlignment;

@property (nonatomic, strong) NSArray *items;

@end

@implementation MenuView

#pragma mark -Lazy Load

- (CGFloat)cellHeight {
    return 40.0;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = YES;
        [self addSubview:_tableView];
    }
    return _tableView;
}

- (instancetype)init:(NSArray *)items position:(CGPoint)position textAlignment:(NSTextAlignment)textAlignment selectedChanged:(void (^)(NSInteger))selectedChanged {
    
    self = [super initWithFrame:CGRectMake(position.x, position.y, 130, items.count * self.cellHeight - 1)];
    if (self) {
        self.items = items;
        self.textAlignment = textAlignment;
        self.selectedChanged = selectedChanged;
        self.tableView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)show{
    UIView *superView = [UIApplication sharedApplication].keyWindow;
    UIControl *control = [[UIControl alloc]init:superView padding:0];
    control.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    [control addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchDown];
    [control addSubview:self];
    
    [superView addSubview:control];
    superView.userInteractionEnabled = YES;
    
    [self.tableView reloadData];
}

- (void)dismiss {
    [self.superview removeFromSuperview];
}

#pragma mark -TableViewDelegate && DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    cell.separatorInset = UIEdgeInsetsMake(0, 5, 0, 5);
    cell.textLabel.text = _items[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedChanged(indexPath.row);
    [self dismiss];
}

@end
