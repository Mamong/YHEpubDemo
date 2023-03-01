//
//  XDSCatalogCell.m
//  YHEpubDemo
//
//  Created by tryao on 2023/2/27.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import "XDSCatalogCell.h"
#import <Masonry/Masonry.h>
#import "XDSReadViewConst.h"


@interface XDSCatalogCell ()
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) MASConstraint *titleConstraint;
@end

@implementation XDSCatalogCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self.contentView addSubview:self.moreButtn];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.numLabel];
        [self.contentView addSubview:self.lineView];

        [self.moreButtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(8);
            make.size.mas_equalTo(CGSizeMake(26, 26));
            make.centerY.mas_equalTo(self.contentView);
        }];

        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            self.titleConstraint = make.left.mas_equalTo(40);
            make.right.mas_lessThanOrEqualTo(self.numLabel.mas_left).offset(-8);
            make.centerY.mas_equalTo(self.contentView);
        }];

        [self.numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-12);
            make.centerY.mas_equalTo(self.contentView);
        }];

        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.height.mas_equalTo(0.5);
        }];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)reloadData:(XDSCatalogueModel*)model
{
    NSString *title = model.catalogueName;
    self.titleLabel.text = title;
    self.titleLabel.textColor = [UIColor darkGrayColor];
    self.numLabel.text = @(model.pageBookIdx).stringValue;
    if (CURRENT_RECORD.chapterModel.chapterIndex == model.chapter) {
        if([CURRENT_RECORD.chapterModel getCatalogueModelInChapter:CURRENT_RECORD.location] == model){
            self.titleLabel.textColor = TEXT_COLOR_XDS_2;
        }
    }
    self.moreButtn.selected = model.isExpand;
    self.moreButtn.hidden = model.children.count == 0;
    self.titleConstraint.offset = 40 + model.level * 10;
    [self.contentView setNeedsUpdateConstraints];
}

-(void)handleTap:(UIButton*)button{
    if(self.tapMoreBlock){
        self.tapMoreBlock();
    }
}

- (UIButton*)moreButtn
{
    if(!_moreButtn){
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(12, 10, 24, 24)];
        [btn addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:[UIImage imageNamed:@"icon_nav_forward"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"icon_arrow_down"] forState:UIControlStateSelected];

        _moreButtn = btn;
    }
    return _moreButtn;
}


- (UILabel*)titleLabel
{
    if(!_titleLabel){
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:14];
        _titleLabel = label;
    }
    return _titleLabel;
}

- (UILabel*)numLabel
{
    if(!_numLabel){
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor lightGrayColor];
        _numLabel = label;
    }
    return _numLabel;
}

- (UIView*)lineView
{
    if(!_lineView){
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor lightGrayColor];
        _lineView = view;
    }
    return _lineView;
}
@end
