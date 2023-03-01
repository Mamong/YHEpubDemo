//
//  XDSChapterModel.h
//  XDSReader
//
//  Created by dusheng.xu on 06/07/2017.
//  Copyright © 2017 macos. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XDSBookModel;

@interface XDSCatalogueModel : NSObject <NSCoding>

@property (nonatomic, copy) NSString *catalogId;
@property (nonatomic, copy) NSString *catalogueName;
@property (nonatomic, copy) NSString *link;

@property (nonatomic, readonly) NSString *source;
@property (nonatomic, readonly) NSString *anchor;//if the id is nil, it means the catalogue is the first level catalogue 如果id为空，则为一级目录
@property (nonatomic, assign) NSInteger chapter;//章节
@property (nonatomic, assign) NSInteger level;

//@property (nonatomic, assign) NSInteger location;//章节中的位置

@property (nonatomic, assign) NSInteger pageChapterIdx;//页码
@property (nonatomic, assign) NSInteger pageBookIdx;//页码

@property (nonatomic, assign, getter=isExpand) BOOL expand;


@property (nonatomic, strong) NSArray *children;
@property (nonatomic, weak) XDSCatalogueModel *parent;

- (XDSCatalogueModel*)nextCatalog;
- (XDSCatalogueModel*)nextSibling;
@end

typedef  NS_ENUM(NSInteger,LPPEBookType){
    LPPEBookTypeTxt,
    LPPEBookTypeEpub,
};

@interface XDSChapterModel : NSObject <NSCopying,NSCoding>

@property (nonatomic, weak) XDSBookModel *book;

@property (nonatomic, copy) XDSReadConfig *currentConfig;

@property (nonatomic, copy) NSString *chapterName;//章节名称

@property (nonatomic, assign) NSInteger chapterIndex;//章节序号

@property (nonatomic, assign) NSInteger pageNum;//页脚

@property (nonatomic, copy) NSString *chapterSrc;//epub章节路径，加载epub内容时使用该字段

@property (nonatomic, copy) NSString *originContent;//txt原始内容，加载txt内容时使用该字段

@property (nonatomic, readonly) NSMutableAttributedString *chapterAttributeContent;//全章的富文本
@property (nonatomic, readonly) NSString *chapterContent;//全章的out文本
//@property (nonatomic, readonly) NSArray *pageAttributeStrings;//每一页的富文本
@property (nonatomic, readonly) NSArray *pageStrings;//每一页的普通文本
@property (nonatomic, readonly) NSArray *pageLocations;//每一页在章节中的位置
@property (nonatomic, readonly) NSArray *pageRanges;//每一页在章节中的位置
@property (nonatomic, readonly) NSInteger pageCount;//章节总页数

//@property (nonatomic, strong) XDSCatalogueModel *catalog;//章节目录

//- (void)generateCatalogueModelArray;

- (void)setCatalogueModelArray:(NSArray<XDSCatalogueModel *> *)catalogueModelArray;
@property (nonatomic, readonly) NSArray<XDSCatalogueModel *> *catalogueModelArray;//本章所有二级目录的Model

@property (nonatomic, readonly) NSDictionary *locationWithPageIdMapping;//存放对应id的location，用于根据链接跳转到指定页面   @{NSString:NSNumber}

@property (nonatomic, readonly) NSArray<NSString *> *imageSrcArray;//本章所有图片的链接
@property (nonatomic, readonly) NSArray<XDSNoteModel *>*notes;
@property (nonatomic, readonly) NSArray<XDSMarkModel *>*marks;

- (void)paginateEpubWithBounds:(CGRect)bounds;

- (void)addNote:(XDSNoteModel *)noteModel;//insert a book note into chapter 向该章节中插入一条笔记

- (void)delNote:(XDSNoteModel *)noteModel;//insert a book note into chapter 向该章节中删除一条笔记


- (void)addOrDeleteABookmark:(XDSMarkModel *)markModel;//insert a bookmark into chapter 向该章节中插入一条书签

- (NSInteger)getCatalogLocation:(XDSCatalogueModel*)catalog;

- (NSInteger)getPageWithLocationInChapter:(NSInteger)locationInChapter;

- (XDSCatalogueModel *)getCatalogueModelForPage:(NSInteger)page;

- (XDSCatalogueModel *)getCatalogueModelInChapter:(NSInteger)locationInChapter;

- (BOOL)isMarkAtPage:(NSInteger)page;
- (NSArray *)notesAtPage:(NSInteger)page;

- (BOOL)isReadConfigChanged;


@end
