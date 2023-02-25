//
//  ReadEpubVC.m
//  YHEpubDemo
//
//  Created by survivors on 2019/3/1.
//  Copyright © 2019年 survivorsfyh. All rights reserved.
//

#import "ReadEpubVC.h"

@interface ReadEpubVC ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *list;

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

    [self loadFiles];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.hidesBottomBarWhenPushed = NO;
}

- (void)loadFiles
{
    self.list = [NSMutableArray array];
    NSArray *epubs = [[NSBundle mainBundle] URLsForResourcesWithExtension:@"epub" subdirectory:nil];
    NSArray *texts = [[NSBundle mainBundle] URLsForResourcesWithExtension:@"txt" subdirectory:nil];
    [self.list addObjectsFromArray:epubs];
    [self.list addObjectsFromArray:texts];
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
    cell.textLabel.text = path.lastPathComponent;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSURL *path = self.list[row];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        XDSBookModel *bookModel = [XDSBookModel getLocalModelWithURL:path];
        dispatch_async(dispatch_get_main_queue(), ^{
            XDSReadPageViewController *pageView = [[XDSReadPageViewController alloc] init];
            pageView.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [[XDSReadManager sharedManager] setResourceURL:path];//文件位置
            [[XDSReadManager sharedManager] setBookModel:bookModel];
            [[XDSReadManager sharedManager] setRmDelegate:pageView];
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:pageView animated:YES];
        });
    });
}
@end
