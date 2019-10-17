
//
//  YJChannelView.m
//  UICollectionViewDemo
//
//  Created by GuanDingKeJi on 17/6/6.
//  Copyright © 2017年 YYJ. All rights reserved.
//

#import "YJChannelView.h"
#import "YJChannelCCell.h"
#import "YJChannelHeader.h"

//菜单列数
static NSInteger ColumnNumber = 4;
//横向和纵向的间距
static CGFloat CellMarginX = 15.0f;
static CGFloat CellMarginY = 10.0f;
static CGFloat statusBarHeight = 20.0f;
static CGFloat animationDuration = 0.25;


// 标识符
static NSString *YJChannelCCellID = @"YJChannelCCellID";
static NSString *YJChannelHeaderID = @"YJChannelHeaderID";

@interface YJChannelView ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UIGestureRecognizerDelegate,
YJChannelHeaderDelegate
>

@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *cellAttributesArray; // 存储cell位置信息
@property (nonatomic, strong) NSMutableArray *inUseChannels; // 在使用的频道
@property (nonatomic, strong) NSMutableArray *unUseChannels; // 未使用的频道
@property (nonatomic, assign) BOOL isEditState;  // 编辑状态
@property (nonatomic, assign) BOOL isCanSort;  //是否支持排序功能
@property (nonatomic, assign) BOOL isSorting; // 是否正在移动（点击时）
@property (nonatomic, assign) BOOL sectionOneIsSort; // 第一组在排序
@property (nonatomic, assign) BOOL sectionTwoIsSort; // 第二组在排序
@property (nonatomic, assign) CGRect beganFrame; // 拖动开始时的frame
@property (nonatomic, weak) EditChannelCompleteBlock editCompleteBlock; // 编辑完成回调
@end



@implementation YJChannelView

#pragma mark -- 1、left cycle
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.isEditState = NO;
        self.isCanSort = YES;
        [self addSubview:self.collectionView];
    }
    return self;
}


#pragma mark -- 2、public method
- (void)showChannelViewWithInUseChannels:(NSArray<NSString *> *)inUseChannels
                           unUseChannels:(NSArray<NSString *> *)unUseChannels
                            editComplete:(EditChannelCompleteBlock)editComplete {
    
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureUsedForCloseChannelView:)];
    panGes.delegate = self;
    [self addGestureRecognizer:panGes];
    
    
    _editCompleteBlock = editComplete;
    self.inUseChannels = [NSMutableArray arrayWithArray:inUseChannels];
    self.unUseChannels = [NSMutableArray arrayWithArray:unUseChannels];
    [self reloadData];
    
    CGRect frame = self.frame;
    frame.size.height -= statusBarHeight;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height;
    self.frame = frame;
    self.alpha = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:self];

    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:animationDuration animations:^{
        weakself.alpha = 1;
        CGRect frame = weakself.frame;
        frame.origin.y = statusBarHeight;
        weakself.frame = frame;
    }];
}
- (void)reloadData {
    [self.collectionView reloadData];
}


#pragma mark -- 3、delegate
#pragma mark -- UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return section == 0 ? self.inUseChannels.count : self.unUseChannels.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    YJChannelCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:YJChannelCCellID forIndexPath:indexPath];
    cell.hidden = NO;
    for (UIGestureRecognizer *gesture in cell.gestureRecognizers) {
        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
            [cell removeGestureRecognizer:gesture];
        }
    }
    if (indexPath.section == 0) {
        cell.title = self.inUseChannels[indexPath.row];
        if (_sectionOneIsSort && indexPath.row + 1 == self.inUseChannels.count) {
            cell.hidden = YES;
        }
        // 第0个 推荐不用显示编辑状态
        indexPath.row > 0 ? [cell setHiddenDelBtn:!_isEditState] : [cell setHiddenDelBtn:YES];
        if (_isEditState) {
            UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureUsedForSorting:)];
            [cell addGestureRecognizer:panGes];
        }
    } else {
        cell.title = [NSString stringWithFormat:@"+ %@",self.unUseChannels[indexPath.row]];
        if (_sectionTwoIsSort && indexPath.row + 1 == self.unUseChannels.count) {
            cell.hidden = YES;
        }
        [cell setHiddenDelBtn:YES];
    }
    cell.isFixed = indexPath.section == 0 && indexPath.row == 0;
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        YJChannelHeader *channelHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:YJChannelHeaderID forIndexPath:indexPath];
        channelHeader.backgroundColor = [UIColor whiteColor];
        if (indexPath.section == 0) {
            channelHeader.title = @"我的频道";
            channelHeader.isEditState = _isEditState;
            channelHeader.delegate = self;
            channelHeader.hiddenButton = NO;
        } else {
            channelHeader.title = @"频道推荐";
            channelHeader.subTitle = @"点击添加频道";
            channelHeader.hiddenButton = YES;
        }
        return channelHeader;
    }
    return nil;
}

#pragma mark -- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_isCanSort) {
        if ((indexPath.section == 0 && _isEditState && indexPath.row != 0) || indexPath.section == 1) {
            [self startMoveClickedCellAtIndexpath:indexPath];
        } else if (_isEditState && indexPath.section == 0 && indexPath.row == 0) {
            NSLog(@"编辑状态点击了“推荐”"); // 不做处理
        } else {            
            if ([self.delegate respondsToSelector:@selector(notEditStateSelctedChannel:)]) {
                [self.delegate notEditStateSelctedChannel:self.inUseChannels[indexPath.row]];
            }
        }
        return;
    }
}

#pragma mark -- UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer; {
    return YES; // 多个手势可同时识别
}

#pragma mark -- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint contentOffset = [self.collectionView contentOffset];
    // 下滑到超出顶部时 或 self向下移动时 self.collectionView停止滑动；
    if (contentOffset.y < 0 || self.frame.origin.y > statusBarHeight) {
        [self.collectionView setContentOffset:CGPointMake(0, 0)];
        _lineView.hidden = YES;
    } else if (contentOffset.y > 0) {
        _lineView.hidden = NO;
    }
}

#pragma mark -- YJChannelHeaderDelegate
- (void)startEditOrFinishEditChannel:(UIButton *)sender {
    sender.selected = !sender.selected;
    _isEditState = sender.selected;
    if (_isEditState) { // 进入编辑状态，将拖动手势移除
        for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
            if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
                [self removeGestureRecognizer:gesture];
            }
        }
    } else {  // 非编辑状态，添加拖动手势
        UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureUsedForCloseChannelView:)];
        panGes.delegate = self;
        [self addGestureRecognizer:panGes];
    }
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}



#pragma mark -- 4、events responder
// 拖动排序
- (void)panGestureUsedForSorting:(UIPanGestureRecognizer *)sender {
    if (!_isCanSort) {
        return;
    }
    // 获取选中的cell和cellIndexPath
    YJChannelCCell *cell = (YJChannelCCell *)sender.view;
    [self.collectionView bringSubviewToFront:cell];
    NSIndexPath *cellIndexPath = [self.collectionView indexPathForCell:cell];
    [self.collectionView bringSubviewToFront:cell];
    if (cellIndexPath.section == 0 && cellIndexPath.row == 0) {
        return;
    }
    BOOL isChanged = NO;
    if (sender.state == UIGestureRecognizerStateBegan) {
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        
        // 获取移动中每个cell位置信息
        [self.cellAttributesArray removeAllObjects];
        for (int i = 0; i < self.inUseChannels.count; i++) {
            [self.cellAttributesArray addObject:[self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]]];
        }
        for (int i = 0; i < self.unUseChannels.count; i++) {
            [self.cellAttributesArray addObject:[self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:1]]];
        }

        // locationInView: 获取到的是手指点击屏幕实时的坐标点
        cell.center = [sender locationInView:self.collectionView];
        
        for (UICollectionViewLayoutAttributes *attributes in self.cellAttributesArray) {
            
            // 当选中的cell的indexpath改变时
            if (CGRectContainsPoint(attributes.frame, cell.center) &&
                cellIndexPath != attributes.indexPath) {

                // 如果将cell移到了“推荐”位置，则无效
                if (attributes.indexPath.section == 0 &&
                    attributes.indexPath.row == 0) {
                    return;
                }
                isChanged = YES;
                // 对数组中存放的元素重新排序
                if (cellIndexPath.section == attributes.indexPath.section) {
                    if (cellIndexPath.section == 0) {
                        NSString *imageStr = self.inUseChannels[cellIndexPath.row];
                        [self.inUseChannels removeObjectAtIndex:cellIndexPath.row];
                        [self.inUseChannels insertObject:imageStr atIndex:attributes.indexPath.row];
                        
                    } else {
                        NSString *imageStr = self.unUseChannels[cellIndexPath.row];
                        [self.unUseChannels removeObjectAtIndex:cellIndexPath.row];
                        [self.unUseChannels insertObject:imageStr atIndex:attributes.indexPath.row];
                    }
                    [self.collectionView moveItemAtIndexPath:cellIndexPath toIndexPath:attributes.indexPath];
                } else {
                    if (cellIndexPath.section == 0) { //一区移动到二区
                        NSString *imageStr = self.inUseChannels[cellIndexPath.row];
                        [self.inUseChannels removeObjectAtIndex:cellIndexPath.row];
                        [self.unUseChannels insertObject:imageStr atIndex:attributes.indexPath.row];
                        
                    } else { //二区移动到一区
                        NSString *imageStr = self.unUseChannels[cellIndexPath.row];
                        [self.unUseChannels removeObjectAtIndex:cellIndexPath.row];
                        [self.inUseChannels insertObject:imageStr atIndex:attributes.indexPath.row];
                        
                    }
                    [self.collectionView moveItemAtIndexPath:cellIndexPath toIndexPath:attributes.indexPath];
                }
            }
        }
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        
        if (!isChanged) {
            cell.center = [self.collectionView layoutAttributesForItemAtIndexPath:cellIndexPath].center;
        }
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
        NSLog(@"排序后---%lu--%lu",(unsigned long)self.inUseChannels.count,(unsigned long)self.unUseChannels.count);
    }
}
// 点击时排序(编辑状态)
- (void)startMoveClickedCellAtIndexpath:(NSIndexPath *)indexPath {
    if (_isSorting) return;
    _isSorting = YES;
    // 获取点击的cell
    YJChannelCCell *movedCell = (YJChannelCCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    UICollectionViewLayoutAttributes *endAttributes = nil;
    NSIndexPath *endIndexPath = nil;
    
    if (indexPath.section == 0) {       // 第一组
        
        _sectionOneIsSort = NO;
        _sectionTwoIsSort = YES;
        
        // 将选中的数据，添加到数据源2中
        [self.unUseChannels insertObject:[self.inUseChannels objectAtIndex:indexPath.row] atIndex:0];
        // 获取将要添加到section1中的Cell的indexPath
        endIndexPath = [NSIndexPath indexPathForItem:self.unUseChannels.count - 1 inSection:1];
        // 添加cell，刷新(刷新section的同时，也会刷新section->header);
        [self.collectionView insertItemsAtIndexPaths:@[endIndexPath]];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
        // 获取目标cell和cell的位置信息
        endAttributes = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
        
    } else {                            // 第二组
        
        _sectionOneIsSort = YES;
        _sectionTwoIsSort = NO;
        // 将选中的数据，添加到数据源2中
        [self.inUseChannels addObject:[self.unUseChannels objectAtIndex:indexPath.row]];
        // 获取将要添加到section0中的Cell的indexPath
        endIndexPath = [NSIndexPath indexPathForItem:self.inUseChannels.count - 1 inSection:0];
        // 刷新section的同时，也会刷新section->header，所以这里刷新0section中所有row;
        [self.collectionView insertItemsAtIndexPaths:@[endIndexPath]];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        // 获取目标cell和cell的位置信息
        endAttributes = [self.collectionView layoutAttributesForItemAtIndexPath:endIndexPath];
    }
    
    YJChannelCCell __weak *endCell = (YJChannelCCell *)[self.collectionView cellForItemAtIndexPath:endIndexPath];
    typeof(self) __weak weakSelf = self;
    // 将cell移动到对应的位置
    [UIView animateWithDuration:animationDuration animations:^{
        movedCell.center = endAttributes.center;
    } completion:^(BOOL finished) {
        endCell.hidden = NO;  // 显示移动后的cell
        movedCell.hidden = YES; // 隐藏选中位置的cell
        weakSelf.sectionOneIsSort = NO;
        weakSelf.sectionTwoIsSort = NO;
        // 删除选中的cell
        if (indexPath.section == 0) {
            [weakSelf.inUseChannels removeObjectAtIndex:indexPath.row];
            [weakSelf.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        } else {
            [weakSelf.unUseChannels removeObjectAtIndex:indexPath.row];
            [weakSelf.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        }
        weakSelf.isSorting = NO;
    }];
}
// 长按进入编辑状态
- (void)longPressMethod:(UILongPressGestureRecognizer*)gesture {
    if (_isEditState) return;
    _isEditState = YES;
    // 进入编辑状态，将拖动手势移除
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
            [self removeGestureRecognizer:gesture];
        }
    }
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}
// 关闭视图
- (void)closeChannelView:(UIButton *)sender {
    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:animationDuration animations:^{
        weakself.alpha = 0;
        CGRect frame = weakself.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height;
        weakself.frame = frame;
    } completion:^(BOOL finished) {        
        [weakself removeFromSuperview];
    }];
    _editCompleteBlock(self.inUseChannels,self.unUseChannels);
}
// 拖动关闭视图
- (void)panGestureUsedForCloseChannelView:(UIPanGestureRecognizer *)panGes {
    
    // 如果self.collectionView是向上偏移状态，则拖动手势不执行，直接返回
    if ([self.collectionView contentOffset].y > 0) {
        // 这种状态 [panGes translationInView:panGes.view] 也是变化的，所以需要归零
        [panGes setTranslation:CGPointZero inView:self.superview];
        return;
    }
    
    CGPoint translation = CGPointZero;
    if (panGes.state == UIGestureRecognizerStateBegan) {
        // 记录开始时的frame，用于复位
        _beganFrame = self.frame;
    } else if (panGes.state == UIGestureRecognizerStateChanged) {

        // 随手势的移动而移动
        translation = [panGes translationInView:panGes.view];
        CGRect selfFrame = self.frame;
        selfFrame.origin.y += translation.y;
        // 如果self.frame覆盖了statusBar，则更正self.frame
        if (selfFrame.origin.y < statusBarHeight) {
            selfFrame.origin.y = statusBarHeight;
        }
        self.frame = selfFrame;
        [panGes setTranslation:CGPointZero inView:self.superview];
        
    } else if (panGes.state == UIGestureRecognizerStateEnded) {
        
        __weak typeof(self) weakself = self;
        // 获取滑动速度
        CGPoint velocity  = [panGes velocityInView:panGes.view];
        // 速度大于1000直接移除
        if (velocity.y > 1000) {
            [self closeChannelView:nil];
        } else {
            
            // 移动的距离小于 self.height/3，则回归本位
            if (self.frame.origin.y < self.frame.size.height / 3 + statusBarHeight) {
                [UIView animateWithDuration:animationDuration animations:^{
                    weakself.frame = weakself.beganFrame;
                }];
            } else {
                // 大于 self.height/3，则关闭self
                [self closeChannelView:nil];
            }
        }
    }
}

#pragma mark -- 5、getter and setter
- (NSMutableArray *)cellAttributesArray {
    if (!_cellAttributesArray) {
        _cellAttributesArray = [NSMutableArray array];
    }
    return _cellAttributesArray;
}
- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        
        UIView *headerBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
        headerBgView.backgroundColor = [UIColor whiteColor];
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setFrame:CGRectMake(0, 0, 64, 44)];
        [closeBtn setTitle:@"close" forState:UIControlStateNormal];
        [closeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(closeChannelView:) forControlEvents:UIControlEventTouchUpInside];
        [headerBgView addSubview:closeBtn];

        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(headerBgView.frame)-0.5, CGRectGetWidth(headerBgView.frame), 0.5)];
        _lineView.backgroundColor = [UIColor grayColor];
        [headerBgView addSubview:_lineView];
        _lineView.hidden = YES;
        [self addSubview:headerBgView];
        
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat cellWidth = (self.bounds.size.width - (ColumnNumber + 1) * CellMarginX)/ColumnNumber;
        flowLayout.itemSize = CGSizeMake(cellWidth,cellWidth/2.0f);
        flowLayout.sectionInset = UIEdgeInsetsMake(CellMarginY, CellMarginX, CellMarginY, CellMarginX);
        flowLayout.minimumLineSpacing = CellMarginY;
        flowLayout.minimumInteritemSpacing = CellMarginX;
        flowLayout.headerReferenceSize = CGSizeMake(self.bounds.size.width, 40);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerBgView.frame), self.frame.size.width, CGRectGetHeight(self.frame) - CGRectGetMaxY(headerBgView.frame)) collectionViewLayout:flowLayout];
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[YJChannelCCell class] forCellWithReuseIdentifier:YJChannelCCellID];
        [_collectionView registerClass:[YJChannelHeader class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:YJChannelHeaderID];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressMethod:)];
        longPress.minimumPressDuration = 0.25f;
        [_collectionView addGestureRecognizer:longPress];
    }
    return _collectionView;
}



@end
































