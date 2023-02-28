//
//  XDSMenuTopView.m
//  XDSReader
//
//  Created by dusheng.xu on 2017/6/20.
//  Copyright © 2017年 macos. All rights reserved.
//

#import "XDSMenuTopView.h"
#import <Masonry/Masonry.h>

@interface XDSMenuTopView ()

@property (strong, nonatomic) UIButton *backButton;// 返回按钮
@property (strong, nonatomic) UIButton *markButton;// 书签
@property (strong, nonatomic) UIButton *voiceButton;// 书签



@end

@implementation XDSMenuTopView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self dataInit];
        [self createUI];
    }
    return self;
}

//MARK: -  override super method

//MARK: - ABOUT UI UI相关
- (void)createUI{
    CGFloat buttonW = 28;
    // 返回
    self.backButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, kStatusBarHeight, buttonW, CGRectGetHeight(self.frame) - kStatusBarHeight);
        [button setImage:[UIImage imageNamed:@"G_Back_0"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        button;
    });
    
    // 书签
    self.markButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(CGRectGetWidth(self.frame) - buttonW, kStatusBarHeight, buttonW, CGRectGetHeight(self.frame) - kStatusBarHeight);
        [button setImage:[UIImage imageNamed:@"RM_17"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"RM_18"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(markButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        button;
    });
    
    self.voiceButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(CGRectGetWidth(self.frame) - buttonW *2 -10, kStatusBarHeight, buttonW, CGRectGetHeight(self.frame) - kStatusBarHeight);
        [button setImage:[UIImage imageNamed:@"RM_19"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(voiceButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        button;
    });
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_safeAreaLayoutGuideTop).offset(8);
        make.left.mas_equalTo(8);
        make.bottom.mas_equalTo(-8);
        make.size.mas_equalTo(CGSizeMake(buttonW, buttonW));
    }];
    
    [self.voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_safeAreaLayoutGuideTop).offset(8);
        make.right.mas_equalTo(self.markButton.mas_left).offset(-10);
        make.bottom.mas_equalTo(-8);
        make.size.mas_equalTo(CGSizeMake(buttonW, buttonW));
    }];

    [self.markButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_safeAreaLayoutGuideTop).offset(8);
        make.right.mas_equalTo(-12);
        make.bottom.mas_equalTo(-8);
        make.size.mas_equalTo(CGSizeMake(buttonW, buttonW));
    }];
    
}
//MARK: - DELEGATE METHODS 代理方法

//MARK: - ABOUT REQUEST 网络请求

//MARK: - ABOUT EVENTS 事件响应
- (void)closeButtonClick:(UIButton *)button{
    [[XDSReadManager sharedManager] closeReadView];
}

- (void)markButtonClick:(UIButton *)button{
    [[XDSReadManager sharedManager] addBookMark];
    [self updateMarkButtonState];
}

- (void)voiceButtonClick:(UIButton *)button{
    
    [[XDSReadManager sharedManager] begainSpeech];
    if ([self.delegate respondsToSelector:@selector(startSpeech)]) {
        [self.delegate startSpeech];
    }
}


//MARK: - OTHER PRIVATE METHODS 私有方法
- (void)updateMarkButtonState{
    self.markButton.selected = [CURRENT_RECORD.chapterModel isMarkAtPage:CURRENT_RECORD.currentPage];
}
//MARK: - ABOUT MEMERY 内存管理
- (void)dataInit{
    
}

@end
