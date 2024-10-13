//
//  ZDTemplateCellHandler.m
//  ZDOpenSourceOCDemo
//
//  Created by Zero.D.Saber on 2017/12/12.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import "ZDTemplateCellHandler.h"
#import "UIView+ZDFlexLayout.h"

static NSString *ZD_IndexPathKey(NSIndexPath *indexPath) {
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.item;
    NSString *ret = [NSString stringWithFormat:@"%zd_%zd", section, row];
    return ret;
}

@interface ZDTemplateCellHandler()
@property (nonatomic, strong) NSMutableDictionary<NSString *, UITableViewCell *> *templateCellCache;
@property (nonatomic, strong) NSCache<NSString *, NSNumber *> *cellHeightCache;
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
    if (!(tableView && reuseCellId && indexPath)) {
        return 0.f;
    }
    
    CGFloat cellHeight = 0.f;
    NSString *indexPathKey = ZD_IndexPathKey(indexPath);
    NSNumber *cachedHeightNum = [self.cellHeightCache objectForKey:indexPathKey];
    if (cachedHeightNum) {
        cellHeight = cachedHeightNum.floatValue;
    } else {
        UITableViewCell *cell = [self templateCellWithTableView:tableView reuseIdentifier:reuseCellId];
        
        [cell prepareForReuse];
        
        if (configurationBlock) {
            configurationBlock(cell);
        }
        
        CGFloat realHeight = ceil(CGRectGetHeight(cell.contentView.frame));
        [self.cellHeightCache setObject:@(realHeight) forKey:indexPathKey];
        
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

- (NSCache<NSString *, NSNumber *> *)cellHeightCache {
    if (!_cellHeightCache) {
        _cellHeightCache = [[NSCache alloc] init];
        _cellHeightCache.name = @"ZDFlexLayoutCellHeightCache";
    }
    return _cellHeightCache;
}

@end
