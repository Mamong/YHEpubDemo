//
//  XDSReadOperation.m
//  XDSReader
//
//  Created by dusheng.xu on 2017/6/15.
//  Copyright © 2017年 macos. All rights reserved.
//

#import "XDSReadOperation.h"
#import "TouchXML.h"
#import <SSZipArchive.h>

@implementation XDSReadOperation

+ (void)separateChapter:(NSMutableArray **)chapters content:(NSString *)content {

    [*chapters removeAllObjects];
    NSString *regPattern = @"第[0-9一二三四五六七八九十百千]*[章回].*";
    NSError* error = NULL;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:regPattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray* match = [reg matchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, [content length])];
    
    if (NO && match.count != 0){
        __block NSRange lastRange = NSMakeRange(0, 0);
        [match enumerateObjectsUsingBlock:^(NSTextCheckingResult *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = [obj range];
            NSInteger local = range.location;
            
            XDSChapterModel *model = [[XDSChapterModel alloc] init];

            if (idx == 0) {
                model.chapterName = @"开始";
                NSUInteger len = local;
                model.originContent = [content substringWithRange:NSMakeRange(0, len)];
                
            }
            if (idx > 0 ) {
                model.chapterName = [content substringWithRange:lastRange];
                NSUInteger len = local-lastRange.location;
                model.originContent = [content substringWithRange:NSMakeRange(lastRange.location, len)];                
            }
            if (idx == match.count-1) {
                model.chapterName = [content substringWithRange:range];
                model.originContent = [content substringWithRange:NSMakeRange(local, content.length-local)];
            }

            XDSCatalogueModel *catalogueModel = [[XDSCatalogueModel alloc] init];
            catalogueModel.catalogueName = model.chapterName;
            catalogueModel.link = @"";
            //catalogueModel.anchor = @"";
            catalogueModel.chapter = (*chapters).count;
            model.catalogueModelArray = @[catalogueModel];
            
            [*chapters addObject:model];
            lastRange = range;
        }];
    }else{
        XDSChapterModel *model = [[XDSChapterModel alloc] init];
        model.originContent = content;
        [*chapters addObject:model];
    }
    
}

+ (UIButton *)commonButtonSEL:(SEL)sel target:(id)target{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [button setTintColor:[UIColor whiteColor]];
    [button addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (UIViewController *)getCurrentVC{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

#pragma mark - ePub处理
/**
 * ePub格式处理
 * 获取 EPub 文件压缩并解析 OPF 文件,提取文件中数据
 *
 * 返回章节信息数组
 */
+ (NSArray *)ePubFileHandle:(NSString *)path bookInfoModel:(LPPBookInfoModel *)bookInfoModel catalogs:(NSArray**)catalogs{
    // 解压epub文件并返回解压文件夹的相对路径(根路径为document路径)
    NSString *ePubPath = [self unZip:path];// epub 文件解压缩 & 解析
    if (!ePubPath) {
        return nil;
    }
    
    // 获取opf文件的相对路径
    NSString *OPFPath = [self OPFPath:ePubPath];
    bookInfoModel.rootDocumentUrl = ePubPath;
    bookInfoModel.OEBPSUrl = [OPFPath stringByDeletingLastPathComponent];
    
    return [self parseOPF:OPFPath bookInfoModel:bookInfoModel catalogs:catalogs];// 解析 OPF 文件,从 ncx 读取书籍目录
}

#pragma mark - 解压文件路径(相对路径)
/**
 EPub 解压缩获取文件包内容

 @param path 文件路径 EPub
 @return 结果文件
 */
+ (NSString *)unZip:(NSString *)path{
    NSString *zipFile_relativePath = [[path stringByDeletingPathExtension] lastPathComponent];
    zipFile_relativePath = [EPUB_EXTRACTION_FOLDER stringByAppendingString:zipFile_relativePath];
    zipFile_relativePath = [@"/" stringByAppendingString:zipFile_relativePath];
    /** 文件解压后存储路径*/
    NSString *destinationPath = [APP_SANDBOX_DOCUMENT_PATH stringByAppendingString:zipFile_relativePath];
    
#pragma mark - SDK 中新逻辑
    /*
     SSZipArchive *zipArchive = [[SSZipArchive alloc] initWithPath:path];
     BOOL success = [zipArchive open];
     */
    NSError *error;
    if ([SSZipArchive unzipFileAtPath:path toDestination:destinationPath overwrite:YES password:nil error:&error]) {
        NSLog(@"Zip EPub file success(%@): %@", path.lastPathComponent, destinationPath);
        
        return zipFile_relativePath;
    }
    else {
        NSLog(@"Zip EPub file error: %@", error);
        return  nil;
    }
    
#pragma mark - SDK 中旧逻辑
//    ZipArchive *zip = [[ZipArchive alloc] init];
//    
//    if ([zip UnzipOpenFile:path]) {
//        //相对路径
//        NSString *zipFile_relativePath = [[path stringByDeletingPathExtension] lastPathComponent];
//        zipFile_relativePath = [EPUB_EXTRACTION_FOLDER stringByAppendingString:zipFile_relativePath];
//        zipFile_relativePath = [@"/" stringByAppendingString:zipFile_relativePath];
//        //完整路径
//        NSString *zipPath_fullPath = [APP_SANDBOX_DOCUMENT_PATH stringByAppendingString:zipFile_relativePath];
//        NSFileManager *filemanager=[[NSFileManager alloc] init];
//        if ([filemanager fileExistsAtPath:zipPath_fullPath]) {
//            NSError *error;
//            [filemanager removeItemAtPath:zipPath_fullPath error:&error];
//        }
//        if ([zip UnzipFileTo:[NSString stringWithFormat:@"%@/",zipPath_fullPath] overWrite:YES]) {
//            return zipFile_relativePath;
//        }
//    }
//    return nil;
}

#pragma mark - OPF文件路径
/**
 获取 EPub 中 OPF 文件路径
 
 @param epubPath EPub 文件路径
 @return OPF 文件路径
 */
+ (NSString *)OPFPath:(NSString *)epubPath{
    NSString *epubExtractionFolderFullPath = [APP_SANDBOX_DOCUMENT_PATH stringByAppendingString:epubPath];
    NSString *containerPath = [epubExtractionFolderFullPath stringByAppendingString:@"/META-INF/container.xml"];
    //container.xml文件路径 通过container.xml获取到opf文件的路径
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if ([fileManager fileExistsAtPath:containerPath]) {
        CXMLDocument* document = [[CXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:containerPath] options:0 error:nil];
        CXMLNode* opfPath = [document nodeForXPath:@"//@full-path" error:nil];
        // xml文件中获取full-path属性的节点  full-path的属性值就是opf文件的绝对路径
        NSString *path = [NSString stringWithFormat:@"%@/%@",epubPath,[opfPath stringValue]];
        return path;
    } else {
        NSLog(@"ERROR: ePub not Valid");
        return nil;
    }
    
}

#pragma mark - 解析OPF文件
/**
 解析 OPF 文件,从 ncx 读取书籍目录
 
 https://blog.csdn.net/kavensu/article/details/7758288
 https://blog.csdn.net/Jeaner007/article/details/70901216
 
 @param opfRelativePath 文件相对路径
 @param bookInfoModel 数据填充模型
 @return 结果集
 */
+ (NSArray *)parseOPF:(NSString *)opfRelativePath bookInfoModel:(LPPBookInfoModel *)bookInfoModel catalogs:(NSArray**)catalogs{
    NSString *opfPath = [APP_SANDBOX_DOCUMENT_PATH stringByAppendingString:opfRelativePath];
    CXMLDocument *opfDocument = [[CXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:opfPath] options:0 error:nil];

    /*
     <title>:题名
     <creator>：责任者
     <subject>：主题词或关键词
     <description>：内容描述
     <contributor>：贡献者或其它次要责任者
     <date>：日期
     <type>：类型
     <format>：格式
     <identifier>：标识符
     <source>：来源
     <language>：语种
     <relation>：相关信息
     <coverage>：履盖范围
     <rights>：权限描述
     */
    NSString *title = [self readDCValueFromOPFForKey:@"title" document:opfDocument];
    NSString *creator = [self readDCValueFromOPFForKey:@"creator" document:opfDocument];
    NSString *subject = [self readDCValueFromOPFForKey:@"subject" document:opfDocument];
    NSString *descrip = [self readDCValueFromOPFForKey:@"description" document:opfDocument];
    NSString *date = [self readDCValueFromOPFForKey:@"date" document:opfDocument];
    NSString *type = [self readDCValueFromOPFForKey:@"type" document:opfDocument];
    NSString *format = [self readDCValueFromOPFForKey:@"format" document:opfDocument];
    NSString *identifier = [self readDCValueFromOPFForKey:@"identifier" document:opfDocument];
    NSString *source = [self readDCValueFromOPFForKey:@"source" document:opfDocument];
    NSString *relation = [self readDCValueFromOPFForKey:@"relation" document:opfDocument];
    NSString *coverage = [self readDCValueFromOPFForKey:@"coverage" document:opfDocument];
    NSString *rights = [self readDCValueFromOPFForKey:@"rights" document:opfDocument];
    
    NSString *cover = [self readCoverImage:opfDocument];
    
    /** 书籍数据资源*/
    NSDictionary *bookInfo = NSDictionaryOfVariableBindings(title, creator, subject, descrip, date, type, format, identifier, source, relation, coverage, rights, cover);
    [bookInfoModel setValuesForKeysWithDictionary:bookInfo];// 数据模型填充
    
    CXMLElement *element = (CXMLElement *)[opfDocument nodeForXPath:@"//opf:item[@media-type='application/x-dtbncx+xml']" namespaceMappings:[NSDictionary dictionaryWithObject:@"http://www.idpf.org/2007/opf" forKey:@"opf"] error:nil];
    // opf文件的命名空间 xmlns="http://www.idpf.org/2007/opf" 需要取到某个节点设置命名空间的键为 opf 用 opf: 节点来获取节点
    NSString *ncxFile;
    if (element) {
        ncxFile = [[element attributeForName:@"href"] stringValue];// 获取ncx文件名称 根据ncx获取书的目录
    }
    
    /** OPF 绝对路径*/
    NSString *absolutePath = [opfPath stringByDeletingLastPathComponent];
    
    NSError *error;
    /** 获取文件路径*/
    NSURL *XMLPath = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", absolutePath,ncxFile]];
    // 通过文件路径生成 CXMLDocument 对象
    CXMLDocument *ncxDoc = [[CXMLDocument alloc] initWithContentsOfURL:XMLPath options:0 error:&error];
    if (error) {
        NSLog(@"解析OPF文件(异常): %@", error);
    }

    *catalogs = [self readCatalogFromNCX:ncxDoc];
    
    return [self readChapterFromOPF:opfDocument ncxDoc:ncxDoc];
    
    //read carologue from ncx file 从ncx读取书籍目录（需优化，需要处理章节内链接问题）
//    return [self readCarologueFromNCX:ncxDoc];
}

/**
 从opf中读取章节
 */
+ (NSArray *)readChapterFromOPF:(CXMLDocument *)opfDoc ncxDoc:(CXMLDocument *)ncxDoc{
    NSArray *itemsArray = [opfDoc nodesForXPath:@"//opf:item" namespaceMappings:[NSDictionary dictionaryWithObject:@"http://www.idpf.org/2007/opf" forKey:@"opf"] error:nil];
    NSMutableDictionary* itemDictionary = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *titleDictionary = [[NSMutableDictionary alloc] init];
    for (CXMLElement* element in itemsArray) {
        [itemDictionary setValue:[[element attributeForName:@"href"] stringValue] forKey:[[element attributeForName:@"id"] stringValue]];

        NSString *href = [[element attributeForName:@"href"] stringValue];

        
        NSString *xpath = [NSString stringWithFormat:@"//ncx:content[@src='%@']/../ncx:navLabel/ncx:text", href];
        //根据opf文件的href获取到ncx文件中的中对应的目录名称
        NSArray* navPoints = [ncxDoc nodesForXPath:xpath namespaceMappings:[NSDictionary dictionaryWithObject:@"http://www.daisy.org/z3986/2005/ncx/" forKey:@"ncx"] error:nil];
        
        if([navPoints count] != 0){
            NSString *title = [navPoints.firstObject stringValue];
            [titleDictionary setValue:title forKey:href];
        }
    }

    //章节
    NSArray *itemRefsArray = [opfDoc nodesForXPath:@"//opf:itemref" namespaceMappings:[NSDictionary dictionaryWithObject:@"http://www.idpf.org/2007/opf" forKey:@"opf"] error:nil];
    NSMutableArray *chapters = [NSMutableArray array];
    for (CXMLElement* element in itemRefsArray){
        NSString *idref = [[element attributeForName:@"idref"] stringValue];
        NSString* chapHref = [itemDictionary valueForKey:idref];
        NSString *chapterName = @"";
        if(chapHref.length > 0){
            chapterName = titleDictionary[chapHref];
        }
        if(chapterName.length == 0){
            chapterName = idref;
        }

        XDSChapterModel *chapter = [[XDSChapterModel alloc] init];
        chapter.chapterName = chapterName;
        chapter.chapterSrc = chapHref;
        //chapter.idref = idref;
        [chapters addObject:chapter];
    }
    return chapters;
}

/**
 读取 NCX 文件，提供目录

 @param ncxDoc 文件
 @return 数据结果集
 */

+ (NSArray *)readCatalogFromNCX:(CXMLDocument *)ncxDoc{
    NSString *xpath = @"//ncx:navMap";

    NSError *error;
    // 根据opf文件的href获取到ncx文件中的中对应的目录名称
    //NSArray *navPoints = [ncxDoc nodesForXPath:xpath namespaceMappings:[NSDictionary dictionaryWithObject:@"http://www.daisy.org/z3986/2005/ncx/" forKey:@"ncx"] error:nil];

    CXMLElement *navMap = (CXMLElement*)[ncxDoc nodeForXPath:xpath namespaceMappings:[NSDictionary dictionaryWithObject:@"http://www.daisy.org/z3986/2005/ncx/" forKey:@"ncx"] error:nil];
    NSArray *navPoints = [navMap elementsForName:@"navPoint"];
    if (error) {
        NSLog(@"阅读 NCX 文件(异常): %@", error);
    }
    NSMutableArray *catalogs = [NSMutableArray array];
    for (int i = 0; i < navPoints.count; i ++) {
        CXMLElement *element = navPoints[i];
        XDSCatalogueModel *model = [self getCatalogChildrenFromElem:element level:0];
        if(model){
            [catalogs addObject:model];
        }
    }
    return catalogs;
}

//+ (NSArray *)readCarologueFromNCX:(CXMLDocument *)ncxDoc{
//    NSString *xpath = @"//ncx:content[@src]/../ncx:navLabel/ncx:text";
//    xpath = @"//ncx:navPoint";
//
//    NSError *error;
//    // 根据opf文件的href获取到ncx文件中的中对应的目录名称
//    NSArray *navPoints = [ncxDoc nodesForXPath:xpath namespaceMappings:[NSDictionary dictionaryWithObject:@"http://www.daisy.org/z3986/2005/ncx/" forKey:@"ncx"] error:nil];
//    if (error) {
//        NSLog(@"阅读 NCX 文件(异常): %@", error);
//    }
//
//    /** 章节*/
//    NSMutableArray *chapters = [NSMutableArray arrayWithCapacity:0];
//    XDSChapterModel *chapter;
//    NSMutableArray *catalogueModelArrayInChapter;
//
//    for (int i = 0; i < navPoints.count; i ++) {
//        CXMLElement *element = navPoints[i];
//
//        /** 导航标签*/
//        NSArray *navLabels = [element elementsForName:@"navLabel"];
//        /** 内容*/
//        NSArray *contents = [element elementsForName:@"content"];
//
//        /** 子目录*/
//        NSArray *subNavPoints = [element elementsForName:@"navPoint"];
//
//        if (!navLabels.count || !contents) {
//            continue;
//        }
//        CXMLElement *navLabel = navLabels.firstObject;;
//        CXMLElement *content = contents.firstObject;
//
//        /** 文本*/
//        NSArray *texts = [navLabel elementsForName:@"text"];
//        if (!texts.count) {
//            continue;
//        }
//        CXMLElement *text = texts.firstObject;
//
//        NSString *chapterName = text.stringValue;//章节名称
//        NSString *chapterSrc = [content attributeForName:@"src"].stringValue;//章节路径
//        NSLog(@"阅读 NCX 文件: 章节名称(%@) = 章节路径(%@)", chapterName, chapterSrc);
//
//        XDSCatalogueModel *catalogueModel = [[XDSCatalogueModel alloc] init];
//        catalogueModel.catalogueName = chapterName;
//        catalogueModel.link = chapterSrc;
//
//        NSArray *links = [chapterSrc componentsSeparatedByString:@"#"];
//        if (links.count == 1) {
//            catalogueModel.anchor = @"";
//            catalogueModelArrayInChapter = [NSMutableArray arrayWithCapacity:0];
//            chapter = [[XDSChapterModel alloc] init];
//            chapter.chapterName = chapterName;
//            chapter.chapterSrc = chapterSrc;
//            [chapter setCatalogueModelArray:catalogueModelArrayInChapter];
//            [chapters addObject:chapter];
//
//        }
//        else {
//
//            XDSChapterModel *lastChapter = [chapters lastObject];
//            if ([lastChapter.chapterSrc isEqualToString:links.firstObject]) {
//                catalogueModel.anchor = links.lastObject;
//            }
//            else {
//                catalogueModel.anchor = @"";
//                catalogueModelArrayInChapter = [NSMutableArray arrayWithCapacity:0];
//                chapter = [[XDSChapterModel alloc] init];
//                chapter.chapterName = chapterName;
//                chapter.chapterSrc = links.firstObject;
//                [chapter setCatalogueModelArray:catalogueModelArrayInChapter];
//                [chapters addObject:chapter];
//            }
//
//        }
//
//        catalogueModel.chapter = chapters.count - 1;
//
//        [catalogueModelArrayInChapter addObject:catalogueModel];
//
//    }
//    return chapters;
//}

+ (XDSCatalogueModel*)getCatalogChildrenFromElem:(CXMLElement*)element level:(NSUInteger)level
{
    //章节id
    NSString *catalogId = [element attributeForName:@"id"].stringValue;//章节路径

    /** 导航标签*/
    NSArray *navLabels = [element elementsForName:@"navLabel"];
    /** 内容*/
    NSArray *contents = [element elementsForName:@"content"];

    /** 子目录*/
    NSArray *subNavPoints = [element elementsForName:@"navPoint"];

    if (!navLabels.count || !contents) {
        return nil;;
    }
    CXMLElement *navLabel = navLabels.firstObject;;
    CXMLElement *content = contents.firstObject;

    /** 文本*/
    NSArray *texts = [navLabel elementsForName:@"text"];
    NSString *chapterName = @"";
    if (texts.count > 0) {
        CXMLElement *text = texts.firstObject;
        chapterName = text.stringValue;//章节名称
    }
    NSString *chapterSrc = [content attributeForName:@"src"].stringValue;//章节路径
    NSLog(@"阅读 NCX 文件: 章节名称(%@) = 章节路径(%@)", chapterName, chapterSrc);

    XDSCatalogueModel *catalogueModel = [[XDSCatalogueModel alloc] init];
    catalogueModel.catalogueName = chapterName;
    catalogueModel.link = chapterSrc;
    catalogueModel.catalogId = catalogId;
    catalogueModel.level = level;
    NSMutableArray *children = [NSMutableArray array];

    for (int i = 0; i < subNavPoints.count; i++) {
        CXMLElement *ele = subNavPoints[i];
        XDSCatalogueModel *model = [self getCatalogChildrenFromElem:ele level:level+1];
        if(model){
            model.parent = catalogueModel;
            [children addObject:model];
        }
    }
    catalogueModel.children = children;
    return catalogueModel;
}

/**
 解析 OPF 文件内容
 
 @param key 字段名,即: <dc-metadata> 元数据信息
 @param document OPF 文件数据
 @return 结果集
 */
+ (NSString *)readDCValueFromOPFForKey:(NSString *)key document:(CXMLDocument *)document{
    //    <title>:题名
    //    <creator>：责任者
    //    <subject>：主题词或关键词
    //    <description>：内容描述
    //    <contributor>：贡献者或其它次要责任者
    //    <date>：日期
    //    <type>：类型
    //    <format>：格式
    //    <identifier>：标识符
    //    <source>：来源
    //    <language>：语种
    //    <relation>：相关信息
    //    <coverage>：履盖范围
    //    <rights>：权限描述
    //    <x-metadata>，即扩展元素。如果有些信息在上述元素中无法描述，则在此元素中进行扩展。
    
    NSString *xPath = [NSString stringWithFormat:@"//dc:%@[1]",key];
    CXMLNode *node = [document nodeForXPath:xPath namespaceMappings:[NSDictionary dictionaryWithObject:@"http://purl.org/dc/elements/1.1/" forKey:@"dc"] error:nil];
    NSString *value = node.stringValue;
    
    return value.length?value:@"";
}

/**
 解析 Images 文件内容
 
 @param document Images 文件夹
 @return 结果集
 */
+ (NSString *)readCoverImage:(CXMLDocument *)document{
    CXMLElement *element = (CXMLElement *)[document nodeForXPath:@"//opf:meta[@name='cover']" namespaceMappings:[NSDictionary dictionaryWithObject:@"http://www.idpf.org/2007/opf" forKey:@"opf"] error:nil];
//    NSLog(@"%@", [element attributeForName:@"content"]);
    NSString *cover = [element attributeForName:@"content"].stringValue;
//    NSString *cover = [element attributeForName:@"name"].stringValue;
    NSLog(@"解析 Images 文件内容: %@", cover);
    
    return cover.length?cover:@"";
}
@end
