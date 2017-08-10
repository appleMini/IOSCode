//
//  JRWaterFallLayout.m
//  Study01
//
//  Created by 小布丁 on 2017/5/10.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "JRWaterFallLayout.h"
/** 默认参数 */
static const CGFloat JRDefaultColumnCount = 3; // 列数
static const CGFloat JRDefaultRowMargin = 10; // 行间距
static const CGFloat JRDefaultColumnMargin = 10; // 列间距
static const UIEdgeInsets JRDefaultEdgeInsets = {10, 10, 10, 10}; // edgeInsets

//每次都这样判断显然效率很低, 我们可以在prepareLayout方法中进行一次性判断，然后用一个flags结构体存储起来，那么下次我们在调用的时候直接对flag进行判断即可
struct { // 记录代理是否响应选择子
    BOOL didRespondColumnCount : 1; // 这里的1是用1个字节存储
    BOOL didRespondColumnMargin : 1;
    BOOL didRespondRowMargin : 1;
    BOOL didRespondEdgeInsets : 1;
} _delegateFlags;

@interface JRWaterFallLayout()
{
    
}

//这里本人一共需要用到2个可变数组和一个assign属性， 一个用来记录每列的高度，一个用来记录所有itemAttributes. assign用来记录高度最大的列的高度
/** itemAttributes数组 */
@property (nonatomic, strong) NSMutableArray *attrsArray;
/** 每列的高度数组 */
@property (nonatomic, strong) NSMutableArray *columnHeights;
/** 最大Y值 */
@property (nonatomic, assign) CGFloat maxY;

@end

@implementation JRWaterFallLayout

#pragma mark - 懒加载

- (NSMutableArray *)columnHeights
{
    if (_columnHeights == nil) {
        _columnHeights = [NSMutableArray array];
    }
    return _columnHeights;
}

- (NSMutableArray *)attrsArray
{
    if (_attrsArray == nil) {
        _attrsArray = [NSMutableArray array];
    }
    return _attrsArray;
}

#pragma mark - layout方法
/**
 *  准备布局
 */
//collectionView 第一次布局和布局失效的时候会调用该方法，需要注意的是子类记得调用super
- (void)prepareLayout {
    [super prepareLayout];
    
    // 设置代理方法的标志
    [self setupDelegateFlags];
    
    // 初始化列最大高度数组
    [self setupColumnHeightsArray];
    
    // 初始化item布局属性数组
    [self setupAttrsArray];
    
    // 计算最大的Y值
    self.maxY = [self maxYWithColumnHeightsArray:self.columnHeights];
    
}

///因为layoutAttributesForElementsInRect方法调用十分频繁, 所以布局属性的数组应该只计算一次保存起来而不是每次调用该方法的时候重新计算
//返回rect 范围内所有元素的布局属性的数组
- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attrsArray;
}

//整个瀑布流layout最重要的是找到item摆放的位置. 正是layoutAttributesForItemAtIndexPath方法要做的是.
//接下里要处理的就是layoutAttributesForItemAtIndexPath方法中每个item该怎么布局了，思路很简单
//
//1.创建一个UICollectionViewLayoutAttributes对象
//2.根据collectionView的width及行间距等几个参数，计算出item的宽度
//3.找到最短列的列号
//4.根据列号计算item的x值、y值, 询问代理拿到item的高度
//5.设置UICollectionViewLayoutAttributes对象的frame属性
//6.返回UICollectionViewLayoutAttributes对象
//7.返回indexpath位置的上元素上的布局属性
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    int columnIndex = (int)indexPath.item % [self columnCount];
    
    CGFloat itemWidth = (self.collectionView.frame.size.width - ([self edgeInsets].left + [self edgeInsets].right) - ([self columnCount]-1)* [self columnMargin]) / [self columnCount];
    
    CGFloat x = [self edgeInsets].left + columnIndex * (itemWidth + [self columnMargin]);
    
    CGFloat y = [self.columnHeights[columnIndex] doubleValue];
    
    CGFloat itemHeight = [self.delegate waterFallLayout:self heightForItemAtIndex:indexPath.item width:itemWidth];
    
    CGRect frame = CGRectMake(x, y, itemWidth, itemHeight);
    
    attribute.frame = frame;
    
    self.columnHeights[columnIndex] = @(y + itemHeight + [self rowMargin]);
    
    return attribute;
}

//返回collectionView 滚动的范围
- (CGSize)collectionViewContentSize {
    return CGSizeMake(0, self.maxY + [self edgeInsets].bottom);
}

#pragma mark - 私有方法
- (void)setupColumnHeightsArray {
    [self.columnHeights removeAllObjects];
    
    for (int i=0; i< [self columnCount]; i++) {
        [self.columnHeights addObject:@([self edgeInsets].top)];
    }
}

- (CGFloat)maxYWithColumnHeightsArray:(NSArray *)columnHeights {
    __block  CGFloat maxY = 0;
    [columnHeights enumerateObjectsUsingBlock:^(NSNumber *_Nonnull yNumber, NSUInteger idx, BOOL * _Nonnull stop) {
        if (maxY < [yNumber doubleValue]) {
            maxY = [yNumber doubleValue];
        }
    }];
    
    return maxY;
}

- (void)setupAttrsArray {
    [self.attrsArray removeAllObjects];
    
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (int i = 0; i < count; i++) {
        @autoreleasepool { // 如果item数目过大容易造成内存峰值提高
            UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
            
            [self.attrsArray addObject:attrs];
        }
    }
}

- (void)setupDelegateFlags
{
    _delegateFlags.didRespondColumnCount = [self.delegate respondsToSelector:@selector(columnCountOfWaterFallLayout:)];
    _delegateFlags.didRespondColumnMargin = [self.delegate respondsToSelector:@selector(columnMarginOfWaterFallLayout:)];
    _delegateFlags.didRespondRowMargin = [self.delegate respondsToSelector:@selector(rowMarginOfWaterFallLayout:)];
    _delegateFlags.didRespondEdgeInsets = [self.delegate respondsToSelector:@selector(edgeInsetsOfWaterFallLayout:)];
}

#pragma mark - 根据情况返回参数
- (NSUInteger)columnCount
{
    return _delegateFlags.didRespondColumnCount ? [self.delegate columnCountOfWaterFallLayout:self] : JRDefaultColumnCount;
}

- (CGFloat)columnMargin
{
    return _delegateFlags.didRespondColumnMargin ? [self.delegate columnMarginOfWaterFallLayout:self] : JRDefaultColumnMargin;
}

- (CGFloat)rowMargin
{
    return _delegateFlags.didRespondRowMargin ? [self.delegate rowMarginOfWaterFallLayout:self] : JRDefaultRowMargin;
}

- (UIEdgeInsets)edgeInsets
{
    return _delegateFlags.didRespondEdgeInsets ? [self.delegate edgeInsetsOfWaterFallLayout:self] : JRDefaultEdgeInsets;
}
@end
