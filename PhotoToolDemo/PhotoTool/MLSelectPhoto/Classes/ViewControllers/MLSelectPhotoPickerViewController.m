//  github: https://github.com/MakeZL/MLSelectPhoto
//  author: @email <120886865@qq.com>
//
//  PickerViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "MLSelectPhotoPickerViewController.h"
#import "MLSelectPhotoNavigationViewController.h"
#import "MLSelectPhotoPickerGroupViewController.h"
#import "MLSelectPhotoAssets.h"

@interface MLSelectPhotoPickerViewController ()
@property (nonatomic, weak) MLSelectPhotoPickerGroupViewController *groupVC;
@end

@implementation MLSelectPhotoPickerViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self addNotification];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - init Action
- (void)createNavigationController {
    MLSelectPhotoPickerGroupViewController *groupVC = [[MLSelectPhotoPickerGroupViewController alloc] init];
    MLSelectPhotoNavigationViewController *nav = [[MLSelectPhotoNavigationViewController alloc] initWithRootViewController:groupVC];
    nav.view.frame = self.view.bounds;
    [self addChildViewController:nav];
    [self.view addSubview:nav.view];
    self.groupVC = groupVC;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self createNavigationController];
    }
    return self;
}

- (void)setSelectPickers:(NSArray *)selectPickers {
    _selectPickers = selectPickers;
    self.groupVC.selectAsstes = selectPickers;
}

- (void)setStatus:(PickerViewShowStatus)status {
    _status = status;
    self.groupVC.status = status;
}

- (void)setSourceType:(MLSourceType)sourceType
{
    _sourceType = sourceType;
    self.groupVC.sourceType = sourceType;
}

- (void)setMaxCount:(NSInteger)maxCount {
    if (maxCount <= 0) return;
    _maxCount = maxCount;
    self.groupVC.maxCount = maxCount;
}

- (void)setDoneStr:(NSString *)doneStr {
    self.groupVC.doneStr = doneStr;
}

#pragma mark - 展示控制器
- (void)showPickerVc:(UIViewController *)vc {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    __weak typeof(vc)weakVc = vc;
    if (weakVc != nil) {
        [weakVc presentViewController:self animated:YES completion:nil];
    }
}

- (void)addNotification {
    // 监听异步done通知
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(done:) name:PICKER_TAKE_DONE object:nil];
    });
}

- (void)done:(NSNotification *)notify {
    NSArray *selectArray =  notify.userInfo[@"selectAssets"];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(pickerViewControllerDoneAsstes:)]) {
            [self.delegate pickerViewControllerDoneAsstes:selectArray];
        }else if (self.callBack){
            self.callBack(selectArray);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)setTopShowPhotoPicker:(BOOL)topShowPhotoPicker {
    _topShowPhotoPicker = topShowPhotoPicker;
    self.groupVC.topShowPhotoPicker = topShowPhotoPicker;
}

- (void)setDelegate:(id<ZLPhotoPickerViewControllerDelegate>)delegate {
    _delegate = delegate;
    self.groupVC.delegate = delegate;
}

@end
