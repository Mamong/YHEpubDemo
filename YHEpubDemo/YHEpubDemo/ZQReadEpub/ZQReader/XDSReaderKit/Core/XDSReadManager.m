//
//  XDSReadManager.m
//  XDSReader
//
//  Created by dusheng.xu on 2017/6/16.
//  Copyright © 2017年 macos. All rights reserved.
//

#import "XDSReadManager.h"
#import "ZQAVSpeechTool.h"


@implementation XDSReadManager

static XDSReadManager *readManager;

+ (XDSReadManager *)sharedManager{
    if (readManager == nil) {
        readManager = [[self alloc] init];
        
    } 
    return readManager;
} 

+ (id)allocWithZone:(NSZone *)zone{
    static dispatch_once_t onceToken; 
    dispatch_once(&onceToken, ^{ 
        readManager = [super allocWithZone:zone];
    }); 
    return readManager;
}
// FIXME: 修复线程问题
- (void)updateReadRect{
    CGFloat topPadding = 20;
    CGFloat bottomPadding = 20;
    CGFloat navHeight = 44;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        topPadding = window.safeAreaInsets.top;
        bottomPadding = window.safeAreaInsets.bottom + 20;
    }
    CGFloat topSafePadding = topPadding + navHeight;
    CGRect bounds = CGRectMake(kReadViewMarginLeft,
                               topSafePadding,
                               DEVICE_MAIN_SCREEN_WIDTH_XDSR-kReadViewMarginLeft-kReadViewMarginRight,
                               DEVICE_MAIN_SCREEN_HEIGHT_XDSR-topSafePadding-bottomPadding);
    _readViewBounds = bounds;
}

#pragma mark - 获取对于章节页码的 radViewController
- (XDSReadViewController *)readViewWithChapter:(NSInteger *)chapter
                                          page:(NSInteger *)page
                                       pageUrl:(NSString *)pageUrl
                                        canScroll:(BOOL)canScroll
{
    
    XDSChapterModel *currentChapterModel = _bookModel.chapters[*chapter];
    if (currentChapterModel.isReadConfigChanged) {
        [CURRENT_BOOK_MODEL loadContentInChapter:currentChapterModel];
        if (currentChapterModel == CURRENT_RECORD.chapterModel) {
            *page = CURRENT_RECORD.currentPage;
        }
    }
    
    if (*page < 0){
        *page = currentChapterModel.pageCount - 1;
    }
    
    XDSReadViewController *readView = [[XDSReadViewController alloc] init];
    readView.chapterNum = *chapter;
    readView.pageNum = *page;
    readView.pageUrl = pageUrl;
    readView.chapterModel = currentChapterModel;
    readView.canScroll = canScroll;
    return readView;
}

- (void)loadContentInChapter:(NSInteger)chapter{
    XDSChapterModel *chapterModel = _bookModel.chapters[chapter];
    if (!chapterModel.chapterAttributeContent) {
        [CURRENT_BOOK_MODEL loadContentInChapter:chapterModel];
    }
}
//MARK: - 跳转到指定章节（上一章，下一章，slider，目录）
- (void)readViewJumpToChapter:(NSInteger)chapter page:(NSInteger)page{
    //跳转到指定章节
    if (self.rmDelegate && [self.rmDelegate respondsToSelector:@selector(readViewJumpToChapter:page:)]) {
        [self.rmDelegate readViewJumpToChapter:chapter page:page];
    }
    //更新阅读记录
    [self updateReadModelWithChapter:chapter page:page];
}
//MARK: - 跳转到指定笔记，因为是笔记是基于位置查找的，使用page查找可能出错
- (void)readViewJumpToNote:(XDSNoteModel *)note{
    XDSChapterModel *currentChapterModel = _bookModel.chapters[note.chapter];
    if (currentChapterModel.isReadConfigChanged) {
        [CURRENT_BOOK_MODEL loadContentInChapter:currentChapterModel];
    }
    [self readViewJumpToChapter:note.chapter page:note.page];
}

//MARK: - 跳转到指定书签，因为是书签是基于位置查找的，使用page查找可能出错
- (void)readViewJumpToMark:(XDSMarkModel *)mark{
    
    XDSChapterModel *currentChapterModel = _bookModel.chapters[mark.chapter];
    if (currentChapterModel.isReadConfigChanged) {
        [CURRENT_BOOK_MODEL loadContentInChapter:currentChapterModel];
    }
    
    [self readViewJumpToChapter:mark.chapter page:mark.page];
}
//MARK: - 设置字体
- (void)configReadFontSize:(BOOL)plus{
    if ([XDSReadConfig shareInstance].currentFontSize < 1) {
        [XDSReadConfig shareInstance].currentFontSize = [XDSReadConfig shareInstance].cachefontSize;
    }
    if (plus) {
        [XDSReadConfig shareInstance].currentFontSize++;
        if (floor([XDSReadConfig shareInstance].currentFontSize) >= floor(kXDSReadViewMaxFontSize)) {
            [XDSReadConfig shareInstance].currentFontSize = kXDSReadViewMaxFontSize;
        }
    }else{
        [XDSReadConfig shareInstance].currentFontSize--;
        if (floor([XDSReadConfig shareInstance].currentFontSize) <= floor(kXDSReadViewMinFontSize)){
            [XDSReadConfig shareInstance].currentFontSize = kXDSReadViewMinFontSize;
        }
    }
    
//    if (CURRENT_RECORD.chapterModel.isReadConfigChanged) {
//        [CURRENT_BOOK_MODEL loadContentInChapter:CURRENT_RECORD.chapterModel];
//    }

    if ([[XDSReadConfig shareInstance] isReadConfigChanged]) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [CURRENT_BOOK_MODEL loadContentForAllChapters];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.rmDelegate && [self.rmDelegate respondsToSelector:@selector(readViewFontDidChanged)]) {
                    [self.rmDelegate readViewFontDidChanged];
                }
            });
        });
    }
}

- (void)configReadFontName:(NSString *)fontName{
    
    //更新字体信息
    [[XDSReadConfig shareInstance] setCurrentFontName:fontName];
    
    //重新加载章节内容
    XDSChapterModel *currentChapterModel = CURRENT_RECORD.chapterModel;
    [CURRENT_BOOK_MODEL loadContentInChapter:currentChapterModel];
    
    if (self.rmDelegate && [self.rmDelegate respondsToSelector:@selector(readViewFontDidChanged)]) {
        [self.rmDelegate readViewFontDidChanged];
    }
}

- (void)configReadTheme:(UIColor *)theme{
    [XDSReadConfig shareInstance].currentTheme = theme;
    
    XDSChapterModel *currentChapterModel = CURRENT_RECORD.chapterModel;
    [CURRENT_BOOK_MODEL loadContentInChapter:currentChapterModel];
    
    if (self.rmDelegate && [self.rmDelegate respondsToSelector:@selector(readViewThemeDidChanged)]) {
        [self.rmDelegate readViewThemeDidChanged];
    }
}

- (void)configReadEffect:(NSInteger)effect{

    [XDSReadConfig shareInstance].currentEffect = effect;

    if (self.rmDelegate && [self.rmDelegate respondsToSelector:@selector(readViewEffectDidChanged)]) {
        [self.rmDelegate readViewEffectDidChanged];
    }
}
//MARK: - 更新阅读记录
-(void)updateReadModelWithChapter:(NSInteger)chapter page:(NSInteger)page{
    if (chapter < 0) {
        chapter = 0;
    }
    if (page < 0) {
        page = 0;
    }
    _bookModel.record.chapterModel = _bookModel.chapters[chapter];
    NSRange pageRange = [_bookModel.record.chapterModel.pageRanges[page] rangeValue];
    _bookModel.record.location = pageRange.location + pageRange.length - 1;
    _bookModel.record.currentChapter = chapter;
    [XDSBookModel updateLocalModel:_bookModel url:_resourceURL];
    
    if (self.rmDelegate && [self.rmDelegate respondsToSelector:@selector(readViewDidUpdateReadRecord)]) {
        [self.rmDelegate readViewDidUpdateReadRecord];
    }
}


//MARK: - 关闭阅读器
- (void)closeReadView{
    
    //release memery 释放内存
    self.bookModel = nil;
    self.resourceURL = nil;
    
    if (self.rmDelegate && [self.rmDelegate respondsToSelector:@selector(readViewDidClickCloseButton)]) {
        [self.rmDelegate readViewDidClickCloseButton];
    }
}

//MARK: - 添加或删除书签
- (void)addBookMark{
    XDSMarkModel *markModel = [[XDSMarkModel alloc] init];
    XDSChapterModel *currentChapterModel = _bookModel.record.chapterModel;
    NSInteger currentPage = _bookModel.record.currentPage;
    NSInteger currentChapter = _bookModel.record.currentChapter;
    markModel.date = [NSDate date];
    markModel.content = currentChapterModel.pageStrings[currentPage];
    markModel.chapter = currentChapter;
    markModel.chapterName = currentChapterModel.chapterName;
    markModel.locationInChapterContent = [currentChapterModel.pageLocations[currentPage] integerValue];
    [CURRENT_BOOK_MODEL addMark:markModel];
}

//开始语音阅读
- (void)begainSpeech
{
    //取出当前页文字内容
    XDSChapterModel *currentChapterModel = _bookModel.record.chapterModel;
    NSInteger currentPage = _bookModel.record.currentPage;
    NSString *content = currentChapterModel.pageStrings[currentPage];
    //开始朗读本页文字
    [[ZQAVSpeechTool shareSpeechTool] speechTextWith:content];
    self.speeching = YES;
    
}


//MARK: - 添加或删除书签
- (void)delBookMark:(XDSMarkModel *)markModel{
    
    [CURRENT_BOOK_MODEL addMark:markModel];
}

- (void)addNoteModel:(XDSNoteModel *)noteModel{
    noteModel.chapter = CURRENT_RECORD.currentChapter;
    [CURRENT_BOOK_MODEL addNote:noteModel];

//    //绘制笔记下划线
//    [CURRENT_BOOK_MODEL loadContentInChapter:_bookModel.record.chapterModel];

//    if (self.rmDelegate && [self.rmDelegate respondsToSelector:@selector(readViewDidAddNoteSuccess)]) {
//        [self.rmDelegate readViewDidAddNoteSuccess];
//    }
}

- (void)delNoteModel:(XDSNoteModel *)noteModel{
    noteModel.chapter = CURRENT_RECORD.currentChapter;
    [CURRENT_BOOK_MODEL deleteNote:noteModel];
    
    //    //绘制笔记下划线
    //    [CURRENT_BOOK_MODEL loadContentInChapter:_bookModel.record.chapterModel];
    
    //    if (self.rmDelegate && [self.rmDelegate respondsToSelector:@selector(readViewDidAddNoteSuccess)]) {
    //        [self.rmDelegate readViewDidAddNoteSuccess];
    //    }
}



@end
