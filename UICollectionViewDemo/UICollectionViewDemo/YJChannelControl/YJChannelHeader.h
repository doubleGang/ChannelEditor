//
//  YJChannelHeader.h
//  UICollectionViewDemo
//
//  Created by GuanDingKeJi on 17/6/6.
//  Copyright © 2017年 YYJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YJChannelHeaderDelegate <NSObject>
- (void)startEditOrFinishEditChannel:(UIButton *)sender;
@end

@interface YJChannelHeader : UICollectionReusableView
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subTitle;
@property (nonatomic, getter=isHiddenButton) BOOL hiddenButton;
@property (nonatomic, weak) id <YJChannelHeaderDelegate>delegate;
@property (nonatomic, assign) BOOL isEditState;
@end
