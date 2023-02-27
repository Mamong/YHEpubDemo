//
//  XDSCatalogCell.h
//  YHEpubDemo
//
//  Created by tryao on 2023/2/27.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class XDSCatalogueModel;

@interface XDSCatalogCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *moreButtn;
@property (nonatomic, strong) UILabel *numLabel;

@property (nonatomic, copy) void(^tapMoreBlock)(void);


- (void)reloadData:(XDSCatalogueModel*)model;
@end

NS_ASSUME_NONNULL_END
