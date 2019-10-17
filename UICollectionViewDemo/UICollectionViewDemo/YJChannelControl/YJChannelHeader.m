//
//  YJChannelHeader.m
//  UICollectionViewDemo
//
//  Created by GuanDingKeJi on 17/6/6.
//  Copyright © 2017年 YYJ. All rights reserved.
//

#import "YJChannelHeader.h"

@interface YJChannelHeader ()
{
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    UIButton *_editButton;
}
@end

@implementation YJChannelHeader

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {

    CGFloat marginX = 15.0f;
    
    CGSize labelSize = [self sizeWithFont:[UIFont systemFontOfSize:17] maxSize:[UIScreen mainScreen].bounds.size withLineBreakMode:NSLineBreakByWordWrapping content:@"我的频道"];
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(marginX, 0, labelSize.width, self.bounds.size.height)];
    _titleLabel.textColor = [UIColor blackColor];
    [self addSubview:_titleLabel];
    
    _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelSize.width + marginX*2, 0, labelSize.width*1.5, self.bounds.size.height)];
    _subtitleLabel.textColor = [UIColor lightGrayColor];
    _subtitleLabel.textAlignment = NSTextAlignmentLeft;
    _subtitleLabel.font = [UIFont systemFontOfSize:15.0f];
    [self addSubview:_subtitleLabel];
    
    _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_editButton setFrame:CGRectMake(self.bounds.size.width - 60, 0, 50, 25)];
    [_editButton setCenter:CGPointMake(_editButton.center.x, _titleLabel.center.y)];
    [_editButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [_editButton setTitle:@"完成" forState:UIControlStateSelected];    
    _editButton.titleLabel.font = [UIFont systemFontOfSize:13];
    _editButton.layer.cornerRadius = _editButton.frame.size.height/2;
    _editButton.layer.borderColor = [UIColor redColor].CGColor;
    _editButton.layer.borderWidth = 1;
    [_editButton addTarget:self action:@selector(startEditOrFinishEdit:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_editButton];
}


#pragma mark -- event responder 
- (void)startEditOrFinishEdit:(UIButton *)sender {
    if (sender.selected) {
        self.subTitle = @"点击进入频道";
    } else {
        self.subTitle = @"拖拽可以排序";
    }
    if ([self.delegate respondsToSelector:@selector(startEditOrFinishEditChannel:)]) {
        [self.delegate startEditOrFinishEditChannel:sender];
    }
}



#pragma mark -- settter and getter
- (void)setIsEditState:(BOOL)isEditState {
    if (isEditState) {
        self.subTitle = @"拖拽可以排序";
        _editButton.selected = YES;
    } else {
        self.subTitle = @"点击进入频道";
        _editButton.selected = NO;
    }    
}
- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setSubTitle:(NSString *)subTitle {
    _subTitle = subTitle;
    _subtitleLabel.text = subTitle;
}
- (void)setHiddenButton:(BOOL)hiddenButton {
    [_editButton setHidden:hiddenButton];
}
-(CGSize)sizeWithFont:(UIFont *)font
              maxSize:(CGSize)maxSize
    withLineBreakMode:(NSLineBreakMode)lineBreakMode
              content:(NSString *)content
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = lineBreakMode;
    NSDictionary *attribute = @{NSFontAttributeName:font,NSParagraphStyleAttributeName:style};
    return [content boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
}


@end
