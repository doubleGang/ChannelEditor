//
//  YJChannelView.h
//  UICollectionViewDemo
//
//  Created by GuanDingKeJi on 17/6/6.
//  Copyright © 2017年 YYJ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^EditChannelCompleteBlock)(NSArray *inUseChannels, NSArray *unUseChannels);

@protocol YJChannelViewDelegate <NSObject>
- (void)notEditStateSelctedChannel:(NSString *)channel; // 非编辑状态选中的频道
@end

@interface YJChannelView : UIView

@property (nonatomic, weak) id<YJChannelViewDelegate>delegate;

/**
 *  显示频道编辑视图
 *
 *  @param inUseChannels  在使用的频道
 *  @param unUseChannels  未使用的频道
 *  @param editComplete   编辑完成
 */
- (void)showChannelViewWithInUseChannels:(NSArray<NSString *>*)inUseChannels
                           unUseChannels:(NSArray<NSString *>*)unUseChannels
                            editComplete:(EditChannelCompleteBlock)editComplete;

- (void)reloadData;
@end
