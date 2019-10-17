//
//  YJChannelCCell.h
//  UICollectionViewDemo
//
//  Created by GuanDingKeJi on 17/6/6.
//  Copyright © 2017年 YYJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YJChannelCCell : UICollectionViewCell
@property (nonatomic, copy) NSString *title; // 标题
@property (nonatomic, assign) BOOL hiddenDelBtn; // 隐藏删除按钮
@property (nonatomic, assign) BOOL isMoving; // 是否正在移动状态
@property (nonatomic, assign) BOOL isFixed;  // 是否被固定
@end
