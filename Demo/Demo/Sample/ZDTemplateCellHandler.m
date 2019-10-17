//
//  ZDTemplateCellHandler.m
//  ZDOpenSourceOCDemo
//
//  Created by Zero.D.Saber on 2017/12/12.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import "ZDTemplateCellHandler.h"
#import "UIView+ZDFlexLayout.h"

@interface ZDTemplateCellHandler()
@property (nonatomic, strong) NSMutableDictionary<NSString *, UITableViewCell *> *templateCellCache;
@property (nonatomic, strong) NSMutableDictionary<NSIndexPath *, NSNumber *> *cellHeightCache;
@end

@implementation ZDTemplateCellHandler

#pragma mark - Template Cell

- (__kindof UITableViewCell *)templateCellWithTableView:(UITableView *)tableView reuseIdentifier:(NSString *)cellId {
    if (!cellId) return nil;
    
    UITableViewCell *cell = self.templateCellCache[cellId];
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        self.templateCellCache[cellId] = cell;
    }
    return cell;
}

#pragma mark - Height

- (CGFloat)cellHeightWithTableView:(UITableView *)tableView
                   reuseIdentifier:(NSString *)reuseCellId
                         indexPath:(NSIndexPath *)indexPath
                     configuration:(void(^)(UITableViewCell *))configurationBlock {
    if (!(tableView && reuseCellId && indexPath)) return 0.f;
    
    CGFloat cellHeight = 0.f;
    if (self.cellHeightCache[indexPath]) {
        cellHeight = self.cellHeightCache[indexPath].floatValue;
    } else {
        UITableViewCell *cell = [self templateCellWithTableView:tableView reuseIdentifier:reuseCellId];
        [cell prepareForReuse];
        if (configurationBlock) configurationBlock(cell);
        
        // Perform layout calculation
        // 一旦在布局代码完成之后，就要在 根视图 的属性 yoga 对象上调用这个方法，应用布局到 根视图 和 子视图
        // 为什么在cell里执行计算没问题，而在这里计算会有问题？？？？
        //[cell.contentView.yoga applyLayoutPreservingOrigin:NO dimensionFlexibility:YGDimensionFlexibilityFlexibleHeigth];
        
        // 下面2种方式皆可
        CGSize size = cell.contentView.frame.size;
        //CGSize intrinsicSize = [cell.contentView.yoga intrinsicSize];
        CGFloat realHeight = ceil(size.height);
        //NSLog(@"%s, cell Height = %f", __PRETTY_FUNCTION__, realHeight);
        self.cellHeightCache[indexPath] = @(realHeight);
        cellHeight = realHeight;
    }
    
    return cellHeight;
}

#pragma mark - Property

- (NSMutableDictionary<NSString *, UITableViewCell *> *)templateCellCache {
    if (!_templateCellCache) {
        _templateCellCache = @{}.mutableCopy;
    }
    return _templateCellCache;
}

- (NSMutableDictionary<NSIndexPath *,NSNumber *> *)cellHeightCache {
    if (!_cellHeightCache) {
        _cellHeightCache = @{}.mutableCopy;
    }
    return _cellHeightCache;
}

@end
