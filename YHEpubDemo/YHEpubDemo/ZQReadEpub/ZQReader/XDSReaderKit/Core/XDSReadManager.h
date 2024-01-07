//
//  XDSReadManager.h
//  XDSReader
//
//  Created by dusheng.xu on 2017/6/16.
//  Copyright © 2017年 macos. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 当前阅读模型*/
#define CURRENT_BOOK_MODEL [XDSReadManager sharedManager].bookModel
/** 当前阅读进度*/
#define CURRENT_RECORD [XDSReadManager sharedManager].bookModel.record

@protocol XDSReadManagerDelegate;

@interface XDSReadManager : NSObject

+ (XDSReadManager *)sharedManager;

@property (nonatomic,strong) NSURL *resourceURL;
@property (nonatomic,strong) XDSBookModel *bookModel;
@property (nonatomic,weak) id<XDSReadManagerDelegate> rmDelegate;
@property (nonatomic,assign,readonly) CGRect readViewBounds;

- (void)updateReadRect;

/** 获取对于章节页码的radViewController*/
- (XDSReadViewController *)readViewWithChapter:(NSInteger *)chapter
                                          page:(NSInteger *)page
                                       pageUrl:(NSString *)pageUrl
                                        canScroll:(BOOL)canScroll;

/** 跳转到指定章节（上一章，下一章，slider，目录）*/
- (void)readViewJumpToChapter:(NSInteger)chapter page:(NSInteger)page;
/** 跳转到指定笔记，因为是笔记是基于位置查找的，使用page查找可能出错*/
- (void)readViewJumpToNote:(XDSNoteModel *)note;
/** 跳转到指定书签，因为是书签是基于位置查找的，使用page查找可能出错*/
- (void)readViewJumpToMark:(XDSMarkModel *)mark;
/** 设置字体大小*/
- (void)configReadFontSize:(BOOL)plus;
/** 设置字体*/
- (void)configReadFontName:(NSString *)fontName;

- (void)configReadEffect:(NSInteger)effect;

- (void)configReadTheme:(UIColor *)theme;//设置阅读背景
- (void)updateReadModelWithChapter:(NSInteger)chapter page:(NSInteger)page;//更新阅读记录
- (void)closeReadView;//关闭阅读器
- (void)addBookMark;//添加书签

- (void)addNoteModel:(XDSNoteModel *)noteModel;//添加笔记
- (void)delNoteModel:(XDSNoteModel *)noteModel;//删除笔记

- (void)begainSpeech;

@property (nonatomic ,assign)BOOL speeching;


@end


@protocol XDSReadManagerDelegate <NSObject>
@optional
- (void)readViewDidClickCloseButton;//点击关闭按钮
- (void)readViewFontDidChanged;//字体改变
- (void)readViewThemeDidChanged;//主题改变
- (void)readViewEffectDidChanged;//翻页效果改变
- (void)readViewDidAddNoteSuccess;//添加笔记
- (void)readViewJumpToChapter:(NSInteger)chapter page:(NSInteger)page;//跳转到章节
- (void)readViewDidUpdateReadRecord;//更新阅读进度
@end
