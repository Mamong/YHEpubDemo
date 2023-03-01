//
//  XDSChapterModel.m
//  XDSReader
//
//  Created by dusheng.xu on 06/07/2017.
//  Copyright © 2017 macos. All rights reserved.
//

#import "XDSChapterModel.h"

@interface XDSCatalogueModel ()
{
    NSString *_source;
    NSString *_anchor;
}

@end

@implementation XDSCatalogueModel

NSString *const kXDSCatalogueModelCatalogIdEncodeKey = @"catalogueId";
NSString *const kXDSCatalogueModelCatalogueNameEncodeKey = @"catalogueName";
NSString *const kXDSCatalogueModelLinkEncodeKey = @"link";
NSString *const kXDSCatalogueModelChapterEncodeKey = @"chapter";
NSString *const kXDSCatalogueModelPageChapterIndexEncodeKey = @"pageChapterIndex";
NSString *const kXDSCatalogueModelPageBookIndexEncodeKey = @"pageBookIndex";
NSString *const kXDSCatalogueModelLevelEncodeKey = @"level";
NSString *const kXDSCatalogueModelChildrenEncodeKey = @"children";
NSString *const kXDSCatalogueModelParentEncodeKey = @"parent";

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.catalogId forKey:kXDSCatalogueModelCatalogIdEncodeKey];
    [aCoder encodeObject:self.catalogueName forKey:kXDSCatalogueModelCatalogueNameEncodeKey];
    [aCoder encodeObject:self.link forKey:kXDSCatalogueModelLinkEncodeKey];
    [aCoder encodeInt:(int)self.chapter forKey:kXDSCatalogueModelChapterEncodeKey];
    [aCoder encodeInt:(int)self.pageChapterIdx forKey:kXDSCatalogueModelPageChapterIndexEncodeKey];
    [aCoder encodeInt:(int)self.pageBookIdx forKey:kXDSCatalogueModelPageBookIndexEncodeKey];
    [aCoder encodeInt:(int)self.level forKey:kXDSCatalogueModelLevelEncodeKey];
    [aCoder encodeObject:self.children forKey:kXDSCatalogueModelChildrenEncodeKey];
    [aCoder encodeObject:self.parent forKey:kXDSCatalogueModelParentEncodeKey];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.catalogId = [aDecoder decodeObjectForKey:kXDSCatalogueModelCatalogIdEncodeKey];
        self.catalogueName = [aDecoder decodeObjectForKey:kXDSCatalogueModelCatalogueNameEncodeKey];
        self.link = [aDecoder decodeObjectForKey:kXDSCatalogueModelLinkEncodeKey];
        self.chapter = [aDecoder decodeIntForKey:kXDSCatalogueModelChapterEncodeKey];
        self.pageChapterIdx = [aDecoder decodeIntForKey:kXDSCatalogueModelPageChapterIndexEncodeKey];
        self.pageBookIdx = [aDecoder decodeIntForKey:kXDSCatalogueModelPageBookIndexEncodeKey];
        self.level = [aDecoder decodeIntForKey:kXDSCatalogueModelLevelEncodeKey];
        self.children = [aDecoder decodeObjectForKey:kXDSCatalogueModelChildrenEncodeKey];
        self.parent = [aDecoder decodeObjectForKey:kXDSCatalogueModelParentEncodeKey];
    }
    return self;
}

- (NSString*)source{
    if(!_source){
        NSArray *components = [self.link componentsSeparatedByString:@"#"];
        _source = components.firstObject;
    }
    return _source;
}

- (NSString*)anchor{
    if(!_anchor){
        NSArray *components = [self.link componentsSeparatedByString:@"#"];
        if(components.count == 2){
            _anchor = components.lastObject;
        }else{
            _anchor = @"";
        }
    }
    return _anchor;
}

- (XDSCatalogueModel*)nextCatalog
{
    XDSCatalogueModel *node = self;
    while (node.level > 0) {
        //下一个节点优先判断第一个孩子
        XDSCatalogueModel *firstChild = node.children.firstObject;
        if(firstChild){
            return firstChild;
        }
        //没有孩子找兄弟
        XDSCatalogueModel *nextSibling = node.nextSibling;
        if(nextSibling){
            return nextSibling;
        }
        //没有兄弟就找父节点的兄弟
        node = self.parent.nextSibling;
    }
    return nil;
}

- (XDSCatalogueModel*)nextSibling
{
    if(self.level > 0){
        XDSCatalogueModel *parent = self.parent;
        NSInteger index = [parent.children indexOfObject:self];
        if(index < parent.children.count-1){
            return parent.children[index+1];
        }
    }
    return nil;
}

@end


@interface XDSChapterModel ()
@property (nonatomic, strong) NSMutableAttributedString *chapterAttributeContent;//全章的富文本
@property (nonatomic, copy) NSString *chapterContent;//全章的纯文本
//@property (nonatomic, copy) NSArray *pageAttributeStrings;//每一页的富文本
@property (nonatomic, copy) NSArray *pageStrings;//每一页的普通文本
@property (nonatomic, copy) NSArray *pageLocations;//每一页在章节中的位置
@property (nonatomic, copy) NSArray *pageRanges;//每一页在章节中的位置

@property (nonatomic, assign) NSInteger pageCount;//章节总页数
@property (nonatomic, copy) NSArray<XDSCatalogueModel *> *catalogueModelArray;//本章所有的目录Model
@property (nonatomic, copy) NSDictionary *locationWithPageIdMapping;//存放对应id的location，用于根据链接跳转到指定页面

@property (nonatomic, copy) NSArray<NSString *> *imageSrcArray;//本章所有图片的链接
@property (nonatomic, copy) NSArray<XDSNoteModel *>*notes;
@property (nonatomic, copy) NSArray<XDSMarkModel *>*marks;

@property (assign, nonatomic) CGRect showBounds;
@end


@implementation XDSChapterModel

NSString *const kXDSChapterModelChapterIndexEncodeKey = @"chapterIndex";
NSString *const kXDSChapterModelPageNumEncodeKey = @"pageNum";
NSString *const kXDSChapterModelChapterNameEncodeKey = @"chapterName";
NSString *const kXDSChapterModelChapterSrcEncodeKey = @"chapterSrc";
NSString *const kXDSChapterModelOriginContentEncodeKey = @"originContent";
NSString *const kXDSChapterModelCatalogueModelArrayEncodeKey = @"catalogueModelArray";
NSString *const kXDSChapterModelLocationWithPageIdEncodeKey = @"locationWithPageIdMapping";
NSString *const kXDSChapterModelImageSrcArrayEncodeKey = @"imageSrcArray";
NSString *const kXDSChapterModelNotesEncodeKey = @"notes";
NSString *const kXDSChapterModelMarksEncodeKey = @"marks";

- (void)setCatalogueModelArray:(NSArray<XDSCatalogueModel *> *)catalogueModelArray {
    _catalogueModelArray = catalogueModelArray;
}

-(void)paginateEpubWithBounds:(CGRect)bounds{
    @autoreleasepool {
        //        bounds.size.height = bounds.size.height - 20;
        self.showBounds = bounds;
        // Load HTML data
        NSAttributedString *chapterAttributeContentRaw = [self attributedStringForSnippet];
        NSMutableAttributedString *chapterAttributeContent = [[NSMutableAttributedString alloc] initWithAttributedString:chapterAttributeContentRaw];

        self.chapterAttributeContent = chapterAttributeContent;
        self.chapterContent = chapterAttributeContent.string;

        [self addLineForNotes];
        
        //NSMutableArray *pageAttributeStrings = [NSMutableArray arrayWithCapacity:0];//每一页的富文本
        NSMutableArray *pageStrings = [NSMutableArray arrayWithCapacity:0];//每一页的普通文本
        NSMutableArray *pageLocations = [NSMutableArray arrayWithCapacity:0];//每一页在章节中的位置
        NSMutableArray *pageRanges = [NSMutableArray array];
        
        DTCoreTextLayouter *layouter = [[DTCoreTextLayouter alloc] initWithAttributedString:chapterAttributeContent];
        NSRange visibleStringRang;
        DTCoreTextLayoutFrame *visibleframe;
        NSInteger rangeOffset = 0;
        do {
            visibleframe = [layouter layoutFrameWithRect:bounds range:NSMakeRange(rangeOffset, 0)];
            //visibleframe.lineBreakMode = NSLineBreakByCharWrapping;
            visibleStringRang = [visibleframe visibleStringRange];
            //NSAttributedString *subAttStr = [chapterAttributeContent attributedSubstringFromRange:NSMakeRange(visibleStringRang.location, visibleStringRang.length)];
            //NSMutableAttributedString *mutableAttStr = [[NSMutableAttributedString alloc] initWithAttributedString:subAttStr];

            //[pageAttributeStrings addObject:mutableAttStr];

            NSString *string = [self.chapterContent substringWithRange:visibleStringRang];
            [pageStrings addObject:string];
            [pageLocations addObject:@(visibleStringRang.location)];
            [pageRanges addObject:[NSValue valueWithRange:visibleStringRang]];
            rangeOffset += visibleStringRang.length;

        } while (visibleStringRang.location + visibleStringRang.length < chapterAttributeContent.string.length);

        
        visibleframe = nil;
        layouter = nil;
        
        //self.pageAttributeStrings = pageAttributeStrings;
        self.pageStrings = pageStrings;
        self.pageLocations = pageLocations;
        self.pageRanges = pageRanges;
        self.pageCount = self.pageLocations.count;

        //生成页码
        for (XDSCatalogueModel *catalog in self.catalogueModelArray) {
            catalog.pageChapterIdx = [self getPageForCatalog:catalog];
        }
        //排序
        if(self.catalogueModelArray.count >= 2){
            NSMutableArray *arr = [NSMutableArray arrayWithArray:self.catalogueModelArray];
            [arr sortUsingComparator:^NSComparisonResult(XDSCatalogueModel  *obj1, XDSCatalogueModel  *obj2) {
                return [self getCatalogLocation:obj1] < [self getCatalogLocation:obj2] ? NSOrderedAscending: NSOrderedDescending;
            }];
            [self setCatalogueModelArray:arr];
        }
    }
}

//TODO:add underline for notes 为笔记添加下划虚线
- (void)addLineForNotes{

    for (XDSNoteModel *noteModel in _notes) {
        NSRange range = NSMakeRange(noteModel.locationInChapterContent, noteModel.content.length);
        NSMutableDictionary *attibutes = [NSMutableDictionary dictionary];
        //虚线
        //[attibutes setObject:@(NSUnderlinePatternDot|NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
        [attibutes setObject:@(NSUnderlinePatternSolid|NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
        [attibutes setObject:[UIColor redColor] forKey:NSUnderlineColorAttributeName];
        
        [attibutes setObject:[noteModel getNoteURL] forKey:NSLinkAttributeName];
        
        [self.chapterAttributeContent addAttributes:attibutes range:range];
    }
}

/**
 加载 html 数据
 
 图片异常不渲染问题,注释掉如下 code,放开权限
 
 @return 处理结果集
 */
- (NSAttributedString *)attributedStringForSnippet{
    NSLog(@"====%@", self.chapterName);
    NSString *html = @"";
    NSString *readmePath = @"";
    if (self.chapterSrc.length) {
        //load epub
        NSString *OEBPSUrl = self.book.bookBasicInfo.OEBPSUrl;
        OEBPSUrl = [APP_SANDBOX_DOCUMENT_PATH stringByAppendingString:OEBPSUrl];
        NSString *fileName = [NSString stringWithFormat:@"%@/%@", OEBPSUrl, self.chapterSrc];
        //    // Load HTML data
        readmePath = fileName;

        html = [NSString stringWithContentsOfFile:readmePath encoding:NSUTF8StringEncoding error:NULL];

        html = [html stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
        html = [html stringByReplacingOccurrencesOfString:@"\n" withString:@"<p></p>"];
        // 图片异常不渲染问题,注释掉如下 code,放开权限
        //        NSString *imagePath = [@"src=\"" stringByAppendingString:OEBPSUrl];
        //        html = [html stringByReplacingOccurrencesOfString:@"src=\".." withString:imagePath];
        html = [html stringByReplacingOccurrencesOfString:@"<p></p>" withString:@""];
        
    }
    else if (self.originContent.length) {
        //load txt content
        html = self.originContent;
        html = [@"<p>" stringByAppendingString:html];
        html = [html stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
        html = [html stringByReplacingOccurrencesOfString:@"\n" withString:@"</p><p>"];
        html = [html stringByAppendingString:@"</p>"];
        html = [html stringByReplacingOccurrencesOfString:@"<p></p>" withString:@""];
    }
    
    //get image resources
    [self separatePicturesFromHtml:html];
    
    [self insertMarkForIdAttributeFromHtml:&html];
    
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
    // Create attributed string from HTML
    // example for setting a willFlushCallback, that gets called before elements are written to the generated attributed string
    void (^callBackBlock)(DTHTMLElement *element) = ^(DTHTMLElement *element) {
        
        // the block is being called for an entire paragraph, so we check the individual elements
        
        for (DTHTMLElement *oneChildElement in element.childNodes) {
            // if an element is larger than twice the font size put it in it's own block
            if (oneChildElement.displayStyle == DTHTMLElementDisplayStyleInline && oneChildElement.textAttachment.displaySize.height > 2.0 * oneChildElement.fontDescriptor.pointSize)
            {
                oneChildElement.displayStyle = DTHTMLElementDisplayStyleBlock;
                oneChildElement.paragraphStyle.minimumLineHeight = element.textAttachment.displaySize.height;
                oneChildElement.paragraphStyle.maximumLineHeight = element.textAttachment.displaySize.height;
            }
        }
    };
    
    
    [self isReadConfigChanged];
    XDSReadConfig *config = self.currentConfig;
    CGFloat fontSize = (config.currentFontSize > 1)?config.currentFontSize:config.cachefontSize;
    UIColor *textColor = config.currentTextColor?config.currentTextColor:config.cacheTextColor;
    NSString *fontName = config.currentFontName?config.currentFontName:config.cacheFontName;
    
    //    NSString *header = @"你好";
    //    CGRect headerFrame = [header boundingRectWithSize:CGSizeMake(100, 100)
    //                                              options:NSStringDrawingUsesLineFragmentOrigin
    //                                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}
    //                                              context:nil];
    //    CGFloat headIndent = CGRectGetWidth(headerFrame);
    // image布局后不会正好在开始位置，需要去掉段前段后空白
    CGSize maxImageSize = CGSizeMake(_showBounds.size.width - 20, _showBounds.size.height - 20-20);
    
    NSDictionary *dic = @{NSTextSizeMultiplierDocumentOption:@(fontSize/11.0),
                          DTDefaultLineHeightMultiplier:@1.5,
                          DTMaxImageSize:[NSValue valueWithCGSize:maxImageSize],
                          DTDefaultLinkColor:@"purple",
                          DTDefaultLinkHighlightColor:@"red",
                          DTDefaultTextColor:textColor,
                          DTDefaultFontName:fontName,
                          //                          DTWillFlushBlockCallBack:callBackBlock,
                          DTDefaultTextAlignment:@(NSTextAlignmentJustified),
    };
    
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:dic];
    if (readmePath.length) {
        [options setObject:[NSURL fileURLWithPath:readmePath] forKey:NSBaseURLDocumentOption];
    }
    NSAttributedString *attString = [[NSAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];
    [self getIdMarkLocationAndReplaceIt:&attString];
    return attString;
}

- (void)getIdMarkLocationAndReplaceIt:(NSAttributedString **)attString {
    NSMutableString *mutableStr = [NSMutableString stringWithString:(*attString).string];
    NSMutableAttributedString *mutableAttString = [*attString mutableCopy];
    NSMutableDictionary *locationWithPageIdMapping = [@{} mutableCopy];
    
    NSString *idMarkRegex = @"(\\$\\{id=)([^\\}]+)(\\})";
    NSRange range = NSMakeRange(0, mutableStr.length);
    range = [mutableStr rangeOfString:idMarkRegex options:NSRegularExpressionSearch range:range];
    while (range.location != NSNotFound) {
        NSString *idMark = [mutableStr substringWithRange:range];
        locationWithPageIdMapping[idMark] = @(range.location);
        [mutableStr deleteCharactersInRange:range];
        [mutableAttString deleteCharactersInRange:range];
        range.length = mutableStr.length - range.location;
        range = [mutableStr rangeOfString:idMarkRegex options:NSRegularExpressionSearch range:range];
    }
    
    self.locationWithPageIdMapping = locationWithPageIdMapping;

    *attString = mutableAttString;
}

- (void)insertMarkForIdAttributeFromHtml:(NSString **)html {
    NSMutableString *mutableHtml = [*html mutableCopy];
    NSString *idNodeRegex = @"(<)([^>]*)(id=)([^>]+)>";
    NSRange range = NSMakeRange(0, mutableHtml.length);
    range = [mutableHtml rangeOfString:idNodeRegex options:NSRegularExpressionSearch range:range];
    while (range.location != NSNotFound){
        @autoreleasepool {
            
            NSString *idNoteString = [mutableHtml substringWithRange:range];
            NSString *idAttibuteRext = @"(id=)(['\"])([^'\"]+)(['\"])";
            NSRange idRange = [idNoteString rangeOfString:idAttibuteRext options:NSRegularExpressionSearch];
            if (idRange.location != NSNotFound) {
                NSString *idString = [idNoteString substringWithRange:idRange];
                idString = [idString stringByReplacingOccurrencesOfString:@"'" withString:@""];
                idString = [idString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                NSLog(@"id = %@", idString);
                NSString *idMark = [NSString stringWithFormat:@"${%@}", idString];
                [mutableHtml insertString:idMark atIndex:(range.location + range.length)];
            }
            range.location = range.location + range.length;
            range.length = mutableHtml.length - range.location;
            range = [mutableHtml rangeOfString:idNodeRegex options:NSRegularExpressionSearch range:range];
        }
    }
    *html = mutableHtml;
}

//TODO:Separate pictures from html 从html中分离出图片
- (void)separatePicturesFromHtml:(NSString *)html {
    NSMutableArray *picSrcArray = [NSMutableArray arrayWithCapacity:0];
    NSString *regex = @"(<img)([^>]+)";
    NSRange range = NSMakeRange(0, html.length);
    range = [html rangeOfString:regex options:NSRegularExpressionSearch range:range];
    
    while (range.location != NSNotFound){
        
        @autoreleasepool {
            
            NSString *imgDoc = [html substringWithRange:range];
            NSString *srcRegex = @"(src=)('|\")([^'\"]+)(['\"])";
            NSRange srcRange = [imgDoc rangeOfString:srcRegex options:NSRegularExpressionSearch];
            NSString *srcString = [imgDoc substringWithRange:srcRange];
            
            NSString *picSrc = [srcString componentsSeparatedByString:@"="].lastObject;
            picSrc = [picSrc stringByReplacingOccurrencesOfString:@"'" withString:@""];
            picSrc = [picSrc stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            picSrc = picSrc.lastPathComponent;
            
            //            NSLog(@"picSrc = %@",picSrc);
            if (picSrc.length) {
                [picSrcArray addObject:picSrc];
            }
            range.location = range.location + range.length;
            range.length = html.length - range.location;
            range = [html rangeOfString:regex options:NSRegularExpressionSearch range:range];
        }
    }
    
    self.imageSrcArray = picSrcArray;
}

//TODO:insert a book note into chapter 向该章节中插入一条笔记
- (void)addNote:(XDSNoteModel *)noteModel{
    NSMutableArray *notes = [NSMutableArray arrayWithCapacity:0];
    if (self.notes) {
        [notes addObjectsFromArray:self.notes];
    }
    [notes addObject:noteModel];
    self.notes = notes;
}

- (void)delNote:(XDSNoteModel *)noteModel
{
    NSMutableArray *notes = [NSMutableArray arrayWithCapacity:0];
    if (self.notes) {
        [notes addObjectsFromArray:self.notes];
    }
    [notes removeObject:noteModel];
    self.notes = notes;
}



//TODO: insert a bookmark into chapter 向该章节中插入一条书签
- (void)addOrDeleteABookmark:(XDSMarkModel *)markModel {
    NSMutableArray *marks = [NSMutableArray arrayWithCapacity:0];
    if (self.marks) {
        [marks addObjectsFromArray:self.marks];
    }
    
    if ([self isMarkAtPage:markModel.page]) { //contains mark 如果存在，移除书签信息
        for (XDSMarkModel *mark in marks) {
            if (mark.page == markModel.page) {
                [marks removeObject:mark];
                break;
            }
        }
    }else{// doesn't contain mark 记录书签信息
        [marks addObject:markModel];
    }
    self.marks = marks;
}


//TODO: does this page contains a bookMark?
- (BOOL)isMarkAtPage:(NSInteger)page{
    if (page >= self.pageCount) {
        return NO;
    }
    for (XDSMarkModel *mark in self.marks) {
        if (mark.page == page) {
            return YES;
        }
    }
    return NO;
}

- (NSInteger)getPageWithLocationInChapter:(NSInteger)locationInChapter{
    NSInteger page = 0;
    for (int i = 0; i < self.pageLocations.count; i ++) {
        NSInteger location = [self.pageLocations[i] integerValue];
        if (locationInChapter >= location) {
            page = i;
        }
    }
    return page;
}

- (NSInteger)getCatalogLocation:(XDSCatalogueModel*)catalog
{
    if(self.locationWithPageIdMapping){
        NSString *idKey = [NSString stringWithFormat:@"${id=%@}", catalog.anchor];
        NSNumber *location = self.locationWithPageIdMapping[idKey];
        if(location){
            return [location integerValue];
        }
    }
    return 0;
}

- (NSInteger)getPageForCatalog:(XDSCatalogueModel*)catalog
{
    NSInteger location = [self getCatalogLocation:catalog];
    return [self getPageWithLocationInChapter:location];
}

- (XDSCatalogueModel *)getCatalogueModelInChapter:(NSInteger)locationInChapter {
    if (self.catalogueModelArray.count && self.locationWithPageIdMapping) {
        XDSCatalogueModel *targetCatalogue = self.catalogueModelArray.firstObject;
        for (XDSCatalogueModel *aCatalogue in self.catalogueModelArray) {
            NSString *idKey = [NSString stringWithFormat:@"${id=%@}", aCatalogue.anchor];
            NSInteger location = [self.locationWithPageIdMapping[idKey] integerValue];
            if (locationInChapter > location) {
                targetCatalogue = aCatalogue;
            }
        }
        return targetCatalogue;
    }
    return nil;
}

//获取的是开始内容的章节
- (XDSCatalogueModel *)getCatalogueModelForPage:(NSInteger)page {
    if(page < self.pageRanges.count){
        NSRange range = [self.pageRanges[page] rangeValue];
        NSInteger location = range.location;
        return [self getCatalogueModelInChapter:location];
    }
    return nil;
}

- (NSArray *)notesAtPage:(NSInteger)page {
    NSInteger location = [_pageLocations[page] integerValue];
    NSInteger length = [_pageStrings[page] length];
    
    NSMutableArray *notes = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < _notes.count; i ++) {
        XDSNoteModel *noteModel = _notes[i];
        NSInteger noteLocation = noteModel.locationInChapterContent;
        NSInteger noteLenght = noteModel.content.length;
        if (noteLocation >= location && noteLocation < location + length) {
            //note location 在page内部
            [notes addObject:noteModel];
            
        }else if (noteLocation < location && noteLocation + noteLenght > location){
            //note location 在page之前
            [notes addObject:noteModel];
        }
    }
    
    return notes;
}

- (BOOL)isReadConfigChanged {
    XDSReadConfig *shareConfig = [XDSReadConfig shareInstance];
    BOOL isReadConfigChanged = ![_currentConfig isEqual:shareConfig];
    if (isReadConfigChanged) {
        //[shareConfig isReadConfigChanged];
        self.currentConfig = shareConfig;
    }
    return isReadConfigChanged;
}

- (XDSReadConfig *)currentConfig {
    if (_currentConfig == nil) {
        [self isReadConfigChanged];
    }
    return _currentConfig;
}

-(id)copyWithZone:(NSZone *)zone{
    XDSChapterModel *model = [[XDSChapterModel allocWithZone:zone] init];
    model.chapterIndex = self.chapterIndex;
    model.pageNum = self.pageNum;
    model.chapterName = self.chapterName;
    model.chapterSrc = self.chapterSrc;
    model.originContent = self.originContent;
    model.chapterAttributeContent = self.chapterAttributeContent;
    model.chapterContent = self.chapterContent;
    //model.pageAttributeStrings = self.pageAttributeStrings;
    model.pageStrings = self.pageStrings;
    model.pageLocations = self.pageLocations;
    model.pageCount = self.pageCount;
    model.catalogueModelArray = self.catalogueModelArray;
    model.locationWithPageIdMapping = self.locationWithPageIdMapping;
    model.imageSrcArray = self.imageSrcArray;
    model.notes = self.notes;
    model.marks = self.marks;
    return model;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInt64:self.chapterIndex forKey:kXDSChapterModelChapterIndexEncodeKey];
    [aCoder encodeInt64:self.pageNum forKey:kXDSChapterModelPageNumEncodeKey];
    [aCoder encodeObject:self.chapterName forKey:kXDSChapterModelChapterNameEncodeKey];
    [aCoder encodeObject:self.chapterSrc forKey:kXDSChapterModelChapterSrcEncodeKey];
    [aCoder encodeObject:self.originContent forKey:kXDSChapterModelOriginContentEncodeKey];
    [aCoder encodeObject:self.catalogueModelArray forKey:kXDSChapterModelCatalogueModelArrayEncodeKey];
    [aCoder encodeObject:self.locationWithPageIdMapping forKey:kXDSChapterModelLocationWithPageIdEncodeKey];
    [aCoder encodeObject:self.imageSrcArray forKey:kXDSChapterModelImageSrcArrayEncodeKey];
    [aCoder encodeObject:self.notes forKey:kXDSChapterModelNotesEncodeKey];
    [aCoder encodeObject:self.marks forKey:kXDSChapterModelMarksEncodeKey];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.chapterIndex = [aDecoder decodeInt64ForKey:kXDSChapterModelChapterIndexEncodeKey];
        self.pageNum = [aDecoder decodeInt64ForKey:kXDSChapterModelPageNumEncodeKey];
        self.chapterName = [aDecoder decodeObjectForKey:kXDSChapterModelChapterNameEncodeKey];
        self.chapterSrc = [aDecoder decodeObjectForKey:kXDSChapterModelChapterSrcEncodeKey];
        self.originContent = [aDecoder decodeObjectForKey:kXDSChapterModelOriginContentEncodeKey];
        self.catalogueModelArray = [aDecoder decodeObjectForKey:kXDSChapterModelCatalogueModelArrayEncodeKey];
        self.locationWithPageIdMapping = [aDecoder decodeObjectForKey:kXDSChapterModelLocationWithPageIdEncodeKey];
        self.imageSrcArray = [aDecoder decodeObjectForKey:kXDSChapterModelImageSrcArrayEncodeKey];
        self.notes = [aDecoder decodeObjectForKey:kXDSChapterModelNotesEncodeKey];
        self.marks = [aDecoder decodeObjectForKey:kXDSChapterModelMarksEncodeKey];
        
    }
    return self;
}

@end

/**



 //NSString *lastString = pageStrings.lastObject;
 //                if(lastString && !([lastString hasSuffix:@"\n"] || [subAttStr.string hasPrefix:@"\n"])){
 //                    NSAttributedString *lastAttr = pageAttributeStrings.lastObject;
 //                    NSRange range = NSMakeRange(0, lastString.length);
 //                    CTParagraphStyleRef paraStyle = (__bridge CTParagraphStyleRef)[lastAttr attribute:NSParagraphStyleAttributeName atIndex:lastString.length-1 longestEffectiveRange:NULL inRange:range];
 //                    DTCoreTextParagraphStyle *paragraphStyle = [DTCoreTextParagraphStyle paragraphStyleWithCTParagraphStyle:paraStyle];
 //                    paragraphStyle.firstLineHeadIndent = paragraphStyle.headIndent;
 //                    NSParagraphStyle *noIndentStyle = [paragraphStyle NSParagraphStyle];
 //                    [mutableAttStr addAttribute:NSParagraphStyleAttributeName value:noIndentStyle range:NSMakeRange(0, 1)];
 //                }
 */
