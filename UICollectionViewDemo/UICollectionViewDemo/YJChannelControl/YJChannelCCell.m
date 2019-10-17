//
//  YJChannelCCell.m
//  UICollectionViewDemo
//
//  Created by GuanDingKeJi on 17/6/6.
//  Copyright © 2017年 YYJ. All rights reserved.
//

#import "YJChannelCCell.h"


@interface YJChannelCCell ()
{
    UILabel *_textLabel;
    UIButton *_delButton;
    CAShapeLayer *_borderLayer;
}
@end

@implementation YJChannelCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.userInteractionEnabled = YES;
    self.layer.cornerRadius = 5.0f;
    self.backgroundColor = [self backgroundColor];
    
    _textLabel = [UILabel new];
    _textLabel.frame = self.bounds;
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.textColor = [self textColor];
    _textLabel.adjustsFontSizeToFitWidth = YES;
    _textLabel.userInteractionEnabled = YES;
    [self addSubview:_textLabel];

    _delButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_delButton setBackgroundColor:[UIColor redColor]];
    [_delButton setFrame:CGRectMake(self.bounds.size.width-8, -8, 16, 16)];
    [self addSubview:_delButton];
    [_delButton setHidden:YES];
    
    [self addBorderLayer];
}

// 移动时有个模糊边框
- (void)addBorderLayer {
    _borderLayer = [CAShapeLayer layer];
    _borderLayer.bounds = self.bounds;
    _borderLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _borderLayer.path = [UIBezierPath bezierPathWithRoundedRect:_borderLayer.bounds cornerRadius:self.layer.cornerRadius].CGPath;
    _borderLayer.lineWidth = 1;
    _borderLayer.lineDashPattern = @[@5, @3];
    _borderLayer.fillColor = [UIColor clearColor].CGColor;
    _borderLayer.strokeColor = [self backgroundColor].CGColor;
    [self.layer addSublayer:_borderLayer];
    _borderLayer.hidden = true;
    self.hiddenDelBtn = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _textLabel.frame = self.bounds;
}

#pragma mark -
#pragma mark 配置方法

- (UIColor*)backgroundColor {
    return [UIColor colorWithRed:241/255.0f green:241/255.0f blue:241/255.0f alpha:1];
}
- (UIColor*)textColor {
    return [UIColor colorWithRed:40/255.0f green:40/255.0f blue:40/255.0f alpha:1];
}
- (UIColor*)lightTextColor {
    return [UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1];
}


#pragma mark Setter And Getter
- (void)setTitle:(NSString *)title {
    _title = title;
    _textLabel.text = title;
}
- (void)setIsMoving:(BOOL)isMoving {
    _isMoving = isMoving;
    if (_isMoving) {
        self.backgroundColor = [UIColor clearColor];
        _borderLayer.hidden = false;
    } else {
        self.backgroundColor = [self backgroundColor];
        _borderLayer.hidden = true;
    }
}

- (void)setIsFixed:(BOOL)isFixed {
    _isFixed = isFixed;
    if (isFixed) {
        _textLabel.textColor = [self lightTextColor];
    } else {
        _textLabel.textColor = [self textColor];
    }
}
- (void)setHiddenDelBtn:(BOOL)hiddenDelBtn {
    [_delButton setHidden:hiddenDelBtn];
}


@end

































