//
//  JRWaterFallLayout.h
//  Study01
//
//  Created by 小布丁 on 2017/5/10.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JRWaterFallLayoutDelegate;
@interface JRWaterFallLayout : UICollectionViewLayout
@property (nonatomic, weak) id<JRWaterFallLayoutDelegate> delegate;

@end

@protocol JRWaterFallLayoutDelegate <NSObject>

@required
//返回indexPath位置下的item 的高度
- (CGFloat)waterFallLayout:(JRWaterFallLayout *)waterFallLayout heightForItemAtIndex:(NSInteger)index width:(CGFloat)width;

@optional
//返回瀑布流显示的列数
- (NSUInteger)columnCountOfWaterFallLayout:(JRWaterFallLayout *)waterFallLayout;
//返回行间距
- (CGFloat)rowMarginOfWaterFallLayout:(JRWaterFallLayout *)waterFallLayout;
//返回列间距
- (CGFloat)columnMarginOfWaterFallLayout:(JRWaterFallLayout *)waterFallLayout;
//返回边缘间距
- (UIEdgeInsets)edgeInsetsOfWaterFallLayout:(JRWaterFallLayout *)waterFallLayout;
@end
