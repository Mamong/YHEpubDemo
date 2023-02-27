//
//  BookSourceViewController.m
//  YHEpubDemo
//
//  Created by tryao on 2023/2/26.
//  Copyright © 2023 survivorsfyh. All rights reserved.
//

#import "BookSourceViewController.h"
#import "BSWebViewController.h"

@interface BookSourceViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *list;

@end

@implementation BookSourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

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

    self.list = [NSMutableArray arrayWithObject:@{@"name":@"zlib",@"url":@"https://lib-y7x4yvslqzf6chmzs5qzrejc.mountain.pm/"}];

    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark -
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    NSInteger row = indexPath.row;
    NSDictionary *source = self.list[row];
    cell.textLabel.text = source[@"name"];
    cell.detailTextLabel.text = source[@"url"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSDictionary *source = self.list[row];
    
    BSWebViewController *vc = [[BSWebViewController alloc] init];
    vc.url = source[@"url"];
    vc.mimeTypes = @[@"application/epub+zip"];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;

    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
