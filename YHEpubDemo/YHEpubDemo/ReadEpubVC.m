//
//  ReadEpubVC.m
//  YHEpubDemo
//
//  Created by survivors on 2019/3/1.
//  Copyright © 2019年 survivorsfyh. All rights reserved.
//

#import "ReadEpubVC.h"
#import <QuickLook/QuickLook.h>

@interface ReadEpubVC ()<UITableViewDelegate, UITableViewDataSource, QLPreviewControllerDelegate, QLPreviewControllerDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *list;
@property (nonatomic, strong) NSURL *currentFile;

@end

@implementation ReadEpubVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.tableView = [[UITableView alloc] init];
    self.tableView.rowHeight = 44;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];

    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.tableView.bottomAnchor  constraintEqualToAnchor:self.view.bottomAnchor].active = YES;

    self.list = [NSMutableArray array];
    [self loadFiles];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.hidesBottomBarWhenPushed = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadFiles];
}

- (void)loadFiles
{
    [self.list removeAllObjects];
    
    NSArray *epubs = [[NSBundle mainBundle] URLsForResourcesWithExtension:@"epub" subdirectory:nil];
    NSArray *texts = [[NSBundle mainBundle] URLsForResourcesWithExtension:@"txt" subdirectory:nil];
    [self.list addObjectsFromArray:epubs];
    [self.list addObjectsFromArray:texts];

    for (NSString *name in @[@"downloads",@"imports"]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *downloadDir = [[paths objectAtIndex:0] stringByAppendingFormat:@"/%@",name];
        NSURL *downloadPath = [NSURL fileURLWithPath:downloadDir];
        BOOL isPath = NO;
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:downloadDir isDirectory:&isPath];
        if(!exists || !isPath){
            [[NSFileManager defaultManager] createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
        }else{
            NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:downloadDir error:nil];
            for (NSString *item in items) {
                NSURL *url = [NSURL fileURLWithPath:item relativeToURL:downloadPath];
                [self.list addObject:url];
            }
        }
    }


    [self.tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.list.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    NSInteger row = indexPath.row;
    NSURL *path = self.list[row];
    cell.textLabel.text = [path.lastPathComponent stringByRemovingPercentEncoding];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSURL *path = self.list[row];
    self.currentFile = path;
    NSString *fileType = [path.lastPathComponent pathExtension].lowercaseString;
    if([@[@"epub",@"txt"] containsObject:fileType]){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            XDSBookModel *bookModel = [XDSBookModel getLocalModelWithURL:path];
            dispatch_async(dispatch_get_main_queue(), ^{
                XDSReadPageViewController *pageView = [[XDSReadPageViewController alloc] init];
                [[XDSReadManager sharedManager] setResourceURL:path];//文件位置
                [[XDSReadManager sharedManager] setBookModel:bookModel];
                [[XDSReadManager sharedManager] setRmDelegate:pageView];
                self.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:pageView animated:YES];
            });
        });
    }else{
        QLPreviewController *previewController = [[QLPreviewController alloc] init];
        previewController.delegate = self;
        previewController.dataSource = self;
        [self.navigationController presentViewController:previewController animated:YES completion:nil];
    }
}

- (NSInteger)numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller{

    return 1;

}


- (id)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {

    return self.currentFile;

}


- (void)previewControllerDidDismiss:(QLPreviewController *)controller {


}

@end
