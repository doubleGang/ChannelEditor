//
//  ViewController.m
//  UICollectionViewDemo
//
//  Created by GuanDingKeJi on 17/6/5.
//  Copyright © 2017年 YYJ. All rights reserved.
//

#import "ViewController.h"
#import "YJChannelView.h"

@interface ViewController ()<YJChannelViewDelegate>
@property (nonatomic, strong) YJChannelView *channelView;
@end

@implementation ViewController

#pragma mark -- left cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
}


#pragma mark -- delegate
- (void)notEditStateSelctedChannel:(NSString *)channel {
    NSLog(@"非编辑状态点击了: %@", channel);
    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakself.channelView.alpha = 0;
        CGRect frame = weakself.channelView.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height;
        weakself.channelView.frame = frame;
    } completion:^(BOOL finished) {
        [weakself.channelView removeFromSuperview];
        weakself.channelView = nil;
    }];
}



#pragma mark -- events responder
- (IBAction)showChannelView:(id)sender {
    NSArray *inUseChannels = @[@"推荐", @"电影", @"段子", @"健康", @"视频", @"军事", @"科技", @"北京", @"科学", @"社会", @"美图", @"美女", @"汽车", @"国际", @"趣图"];
    NSArray *unUseChannels = @[/*@"娱乐", @"直播", @"热点", @"财经", @"养生", @"体育", @"问答", @"孕产", @"特美", @"图片", @"家居", */@"正能量", @"房产", @"美食", @"小说", @"时尚", @"历史", @"育儿", @"搞笑", @"数码", @"手机", @"旅游", @"宠物", @"情感", @"教育", @"三农", @"文化", @"游戏", @"股票", @"动漫", @"故事", @"收藏", @"精选", @"语录", @"星座", @"政务", @"中国新唱将", @"火山直播", @"彩票", @"快乐男声", @"辟谣"];
    
    self.channelView = [[YJChannelView alloc] initWithFrame:self.view.bounds];
    _channelView.delegate = self;
    [_channelView showChannelViewWithInUseChannels:inUseChannels unUseChannels:unUseChannels editComplete:^(NSArray *inUseChannels, NSArray *unUseChannels) {
        // 编辑完成后的回调 ...
    }];
}
@end





























