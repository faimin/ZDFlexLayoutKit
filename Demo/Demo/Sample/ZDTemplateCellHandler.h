//
//  ZDTemplateCellHandler.h
//  ZDOpenSourceOCDemo
//
//  Created by Zero.D.Saber on 2017/12/12.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZDTemplateCellHandler : NSObject

- (CGFloat)cellHeightWithTableView:(UITableView *)tableView
                   reuseIdentifier:(NSString *)reuseCellId
                         indexPath:(NSIndexPath *)indexPath
                     configuration:(void(^)(UITableViewCell *templateCell))configurationBlock;

@end

NS_ASSUME_NONNULL_END
