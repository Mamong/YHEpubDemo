//
//  XDSReadViewController.m
//  XDSReader
//
//  Created by dusheng.xu on 07/07/2017.
//  Copyright © 2017 macos. All rights reserved.
//

#import "XDSReadViewController.h"
#import "XDSReadView.h"
#import <Masonry/Masonry.h>

@interface XDSReadViewController ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *pageNumLabel;

@end

@implementation XDSReadViewController
- (instancetype)initWithChapterNumber:(NSInteger)chapterNum
                           pageNumber:(NSInteger)pageNum
                            canScroll:(BOOL)canScroll
{
    if (self = [super init]) {
        self.chapterNum = chapterNum;
        self.pageNum = pageNum;
        self.canScroll = canScroll;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetView:) name:@"speechParagraph" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(speechDidStop) name:@"speechDidStop" object:nil];
    
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [XDSReadConfig shareInstance].currentTheme?[XDSReadConfig shareInstance].currentTheme:[XDSReadConfig shareInstance].cacheTheme;

    CGRect frame = [XDSReadManager sharedManager].readViewBounds;
    self.readView = [[XDSReadView alloc] initWithFrame:frame chapterNum:self.chapterNum pageNum:self.pageNum canScroll:self.canScroll];
    self.readView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:self.readView];

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 52, 0, 0)];
    self.titleLabel.textColor = [UIColor lightGrayColor];
    self.titleLabel.text = [self.chapterModel getCatalogueModelForPage:self.pageNum].catalogueName;
    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(8);
    }];

    self.pageNumLabel = [[UILabel alloc] init];
    self.pageNumLabel.textColor = [UIColor lightGrayColor];
    self.pageNumLabel.text = @(self.chapterModel.pageNum+self.pageNum).stringValue;
    [self.view addSubview:self.pageNumLabel];
    [self.pageNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
}

- (void)speechDidStop
{
    [self.readView removeAttributed];
}


- (void)resetView:(NSNotification *)notification
{
    [self.readView highlightTextWith:notification.object];
}

- (void)dealloc{
    NSLog(@"XDSReadViewController dealloc");
}

@end
