//  github: https://github.com/MakeZL/MLSelectPhoto
//  author: @email <120886865@qq.com>
//
//  ZLPhotoPickerGroupViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#define CELL_ROW 4
#define CELL_MARGIN 5
#define CELL_LINE_MARGIN 5


#import "MLSelectPhotoPickerGroupViewController.h"
#import "MLSelectPhotoPickerCollectionView.h"
#import "MLSelectPhotoPickerGroupViewController.h"
#import "MLSelectPhotoPickerGroup.h"
#import "MLSelectPhotoPickerGroupTableViewCell.h"
#import "MLSelectPhotoPickerAssetsViewController.h"

@interface MLSelectPhotoPickerGroupViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic , weak) MLSelectPhotoPickerAssetsViewController *collectionVc;

@property (nonatomic , weak) UITableView *tableView;
@property (nonatomic , strong) NSArray *groups;

@end

@implementation MLSelectPhotoPickerGroupViewController

- (UITableView *)tableView{
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.tableFooterView = [[UIView alloc] init];
        tableView.translatesAutoresizingMaskIntoConstraints = NO;
        [tableView registerClass:[MLSelectPhotoPickerGroupTableViewCell class] forCellReuseIdentifier:@"cell"];
        tableView.delegate = self;
        tableView.dataSource = self;
        [self.view addSubview:tableView];
        self.tableView = tableView;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(tableView);
        
        NSString *heightVfl = @"V:|-0-[tableView]-0-|";
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:nil views:views]];
        NSString *widthVfl = @"H:|-0-[tableView]-0-|";
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:nil views:views]];
        
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self tableView];
    
    // 设置按钮
    [self setupButtons];
    
    // 获取图片
    [self getImgs];
    
    self.title = @"选择相册";
    
}

- (void)setupButtons {
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    
    self.navigationItem.rightBarButtonItem = barItem;
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MLSelectPhotoPickerGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[MLSelectPhotoPickerGroupTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.group = self.groups[indexPath.row];
    
    return cell;
    
}

#pragma mark -<UITableViewDelegate>
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MLSelectPhotoPickerGroup *group = self.groups[indexPath.row];
    MLSelectPhotoPickerAssetsViewController *assetsVC = [[MLSelectPhotoPickerAssetsViewController alloc] init];
    assetsVC.doneStr = self.doneStr;
    assetsVC.selectPickerAssets = self.selectAsstes;
    assetsVC.groupVC = self;
    assetsVC.sourceType = self.sourceType;
    assetsVC.photoGroup = group;
    assetsVC.topShowPhotoPicker = self.topShowPhotoPicker;
    assetsVC.maxCount = self.maxCount;
    [self.navigationController pushViewController:assetsVC animated:YES];
}

#pragma mark -<Images Datas>

-(void)getImgs {
    mWeakSelf;
    [[MLPhotoTool sharePhotoTool] getAllSourceWithType:self.sourceType complete:^(NSArray *groups) {
        // 返回主线程跳转并刷新界面
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.groups = groups;
            [weakSelf.tableView reloadData];
            if (weakSelf.status == PickerViewShowStatusCameraRoll) {
                for (MLSelectPhotoPickerGroup *photoGroup in groups) {
                    if ([photoGroup.title isEqualToString:@"Camera Roll"] || [photoGroup.title isEqualToString:@"相机胶卷"]) {
                        MLSelectPhotoPickerAssetsViewController *assetsVC = [[MLSelectPhotoPickerAssetsViewController alloc] init];
                        assetsVC.doneStr = weakSelf.doneStr;
                        assetsVC.selectPickerAssets = weakSelf.selectAsstes;
                        assetsVC.groupVC = weakSelf;
                        assetsVC.sourceType = weakSelf.sourceType;
                        assetsVC.photoGroup = photoGroup;
                        assetsVC.topShowPhotoPicker = weakSelf.topShowPhotoPicker;
                        assetsVC.maxCount = weakSelf.maxCount;
                        [weakSelf.navigationController pushViewController:assetsVC animated:NO];
                        break;
                    }
                }
            }
        });
    }];
}

#pragma mark -<Navigation Actions>
- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
