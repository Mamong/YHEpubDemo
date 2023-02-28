//
//  XDSCatalogueViewController.m
//  XDSReader
//
//  Created by dusheng.xu on 2017/6/20.
//  Copyright © 2017年 macos. All rights reserved.
//

#import "XDSCatalogueViewController.h"
#import "XDSCatalogCell.h"

@interface XDSCatalogueViewController ()
@property(nonatomic, strong) NSMutableArray *catalogs;
@end

@implementation XDSCatalogueViewController

CGFloat const kCatalogueTableViewCellHeight = 44.f;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = kCatalogueTableViewCellHeight;
    self.tableView.sectionFooterHeight = CGFLOAT_MIN;
    self.tableView.sectionHeaderHeight = CGFLOAT_MIN;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];

    //滚到可视区域
    NSInteger chapter = [CURRENT_BOOK_MODEL.chapters indexOfObject:CURRENT_RECORD.chapterModel];
    CGRect visibleRect = self.view.bounds;
    visibleRect.size.height = kCatalogueTableViewCellHeight;
    visibleRect.origin.y = kCatalogueTableViewCellHeight * chapter + CGRectGetHeight(self.view.bounds)/2 + kTabBarHeight;
    [self.tableView scrollRectToVisible:visibleRect animated:NO];
}

- (void)reloadData
{
    self.catalogs = [NSMutableArray arrayWithArray:CURRENT_BOOK_MODEL.catalog.children];
    NSMutableArray *q = [NSMutableArray arrayWithArray:CURRENT_BOOK_MODEL.catalog.children];
    while (q.count > 0) {
        XDSCatalogueModel *top = q[0];
        [q removeObjectAtIndex:0];
        if(top.isExpand){
            [q addObjectsFromArray:top.children];
            NSInteger idx = [self.catalogs indexOfObject:top];
            if(idx == NSNotFound){
                idx = -1;
            }
            [self.catalogs insertObjects:top.children atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(idx+1, top.children.count)]];
        }
    }
    [self.tableView reloadData];
}

#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.catalogs.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XDSCatalogCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (nil == cell) {
        cell = [[XDSCatalogCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    
    XDSCatalogueModel *catalogueModel = self.catalogs[indexPath.row];
    [cell reloadData:catalogueModel];
    cell.tapMoreBlock = ^{
        catalogueModel.expand = !catalogueModel.isExpand;
        [self reloadData];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_cvDelegate && [_cvDelegate respondsToSelector:@selector(catalogueViewDidSelecteCatalogue:)]){
        XDSCatalogueModel *catalogueModel = self.catalogs[indexPath.row];
        [_cvDelegate catalogueViewDidSelecteCatalogue:catalogueModel];
    }
}
@end
