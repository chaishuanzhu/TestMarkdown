//
//  AssistBar.m
//  TestMark
//
//  Created by 柴栓柱 on 2018/7/18.
//  Copyright © 2018年 柴栓柱. All rights reserved.
//

#import "AssistBar.h"
#import "UIViewController+showAlert.h"
#import "MenuView.h"
#import <CLImageEditor.h>
#import <AFNetworking.h>
#import "MBProgressHUD+Add.h"

@interface AssistBar ()<CLImageEditorDelegate, CLImageEditorTransitionDelegate, CLImageEditorThemeDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIStackView *stackView;
- (IBAction)hidekeyboard:(UIButton *)sender;
- (IBAction)tapImage:(UIButton *)sender;
- (IBAction)tapLink:(UIButton *)sender;
- (IBAction)tapHeader:(UIButton *)sender;
- (IBAction)tapBold:(UIButton *)sender;
- (IBAction)tapItalic:(UIButton *)sender;
- (IBAction)tapDeletion:(UIButton *)sender;
- (IBAction)tapQuote:(UIButton *)sender;
- (IBAction)tapCode:(UIButton *)sender;
- (IBAction)tapChar:(UIButton *)sender;

@property (nonatomic, strong) UITextField *textField;
@end

@implementation AssistBar

- (void)awakeFromNib {
    [super awakeFromNib];
    for (UIButton *button in [_stackView subviews]) {
        //  使用TintColor渲染Image
        UIImage *image = button.imageView.image;
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [button setImage:image forState:UIControlStateNormal];
        button.tintColor = [UIColor grayColor];
        button.titleLabel.font = [UIFont systemFontOfSize:18 weight:1.5];
    }
    
    UIButton *endButton = [self viewWithTag:666];
    //  使用TintColor渲染Image
    UIImage *image = endButton.imageView.image;
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [endButton setImage:image forState:UIControlStateNormal];
    endButton.tintColor = [UIColor grayColor];
}

- (IBAction)hidekeyboard:(UIButton *)sender {
    [_textView resignFirstResponder];
}

- (IBAction)tapImage:(UIButton *)sender {
    
    [_viewController showActionSheet:nil message:@"选择图片" actionTitles:@[@"相机", @"相册"] actionHandler:^(int index) {
        
        UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypePhotoLibrary;
        
        if([UIImagePickerController isSourceTypeAvailable:type]){
            if(index==0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                type = UIImagePickerControllerSourceTypeCamera;
            }
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.allowsEditing = NO;
            picker.delegate   = self;
            picker.sourceType = type;
            
            [self->_viewController presentViewController:picker animated:YES completion:nil];
        }
    }];
}

- (IBAction)tapLink:(UIButton *)sender {
    
    [_viewController showAlert:@"添加链接" message:@"" actionTitles:@[@"取消",@"确定"] textFieldconfigurationHandler:^(UITextField *textField) {
        textField.text = @"http://example.com";
        textField.font = [UIFont systemFontOfSize:13];
        self.textField = textField;
    } actionHandler:^(int index) {
        if (index == 1) {
            [self insertLink];
        }
    }];
}

- (IBAction)tapHeader:(UIButton *)sender {
    
    CGPoint position = [sender convertPoint:sender.center toView:sender.window];
    
    MenuView *menuView = [[MenuView alloc]init:@[@"一级标题",@"二级标题",@"三级标题",@"四级标题"] position:CGPointMake(position.x - 100, position.y - 190) textAlignment:NSTextAlignmentLeft selectedChanged:^(NSInteger index) {
        NSRange currentRange = self.textView.selectedRange;
        NSString *insertText = @"标题";
        [self.textView insertText:[NSString stringWithFormat:@"\n%@ %@",[@"#####" substringToIndex:index + 1], insertText]];
        self.textView.selectedRange = NSMakeRange(currentRange.location + index + 3, insertText.length);
    }];
    [menuView show];
}

- (IBAction)tapBold:(UIButton *)sender {
    [self insertText:@"加粗文本" formatter:@"**%@**" location:2];
}

- (IBAction)tapItalic:(UIButton *)sender {
    [self insertText:@"强调文本" formatter:@"*%@*" location:1];
}

- (IBAction)tapDeletion:(UIButton *)sender {
    [self insertText:@"要删除的文本" formatter:@"~~%@~~" location:2];
}

- (IBAction)tapQuote:(UIButton *)sender {
    [self insertText:@"引用" formatter:@"\n> %@\n" location:3];
}

- (IBAction)tapCode:(UIButton *)sender {
    [self insertText:@"代码" formatter:@"`%@`" location:1];
}

- (IBAction)tapChar:(UIButton *)sender {
    NSString *text = sender.titleLabel.text;
    [_textView insertText:text];
}

- (void)insertLink {
    NSString *link = _textField.text;
    NSRange currentRange = _textView.selectedRange;
    NSString *insertText = @"在这里输入链接描述";
    [_textView insertText:[NSString stringWithFormat:@"[%@](%@)", insertText, link]];
    _textView.selectedRange = NSMakeRange(currentRange.location + 1, insertText.length);
}


/**
 插入文本

 @param tempInsertText 占位符
 @param formatter 格式化文本
 @param location 位置偏移量
 */
- (void)insertText:(NSString *)tempInsertText formatter:(NSString *)formatter location:(NSInteger)location {
    NSRange currentRange = _textView.selectedRange;
    NSString *text = [_textView.text substringWithRange:currentRange];
    BOOL isEmpty = text.length == 0;
    NSString *insertText = isEmpty ? tempInsertText : text;
    [_textView insertText:[NSString stringWithFormat:formatter, insertText]];
    if (isEmpty) {
        _textView.selectedRange = NSMakeRange(currentRange.location + location, insertText.length);
    }
}


#pragma mark- ImagePicker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:image];
    editor.delegate = self;
    
    [picker pushViewController:editor animated:YES];
}

#pragma mark- CLImageEditor delegate

- (void)imageEditor:(CLImageEditor *)editor didFinishEditingWithImage:(UIImage *)image {
    [editor dismissViewControllerAnimated:YES completion:nil];
    
    //。 图片压缩 && 上传。仅供参考
    NSData *data = UIImageJPEGRepresentation(image, 0.9);
    if (data.length > 3000000) {
        data = UIImageJPEGRepresentation(image, 0.7);
    }
    
    [MBProgressHUD showActivity];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:@"https://sm.ms/api/upload" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:@"smfile" fileName:@"temp" mimeType:@"image/jpg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"%f", uploadProgress.fractionCompleted);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showSuccess:@"上传成功！" completion:nil];
        if ([responseObject[@"code"] isEqualToString:@"success"]) {
            NSString *url = responseObject[@"data"][@"url"];
            NSString *insertText = @"在这里输入图片名";
            [self.textView insertText:[NSString stringWithFormat:@"![%@](%@)", insertText, url]];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"上传失败！" completion:nil];
    }];
}

//  取消
- (void)imageEditor:(CLImageEditor *)editor willDismissWithImageView:(UIImageView *)imageView canceled:(BOOL)canceled {

}

@end
