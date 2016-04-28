//  github: https://github.com/MakeZL/MLSelectPhoto
//  author: @email <120886865@qq.com>
//
//  MLSelectPhotoBrowserViewController.m
//  MLSelectPhoto
//
//  Created by 张磊 on 15/4/23.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

#import "MLSelectPhotoBrowserViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIView+MLExtension.h"
#import "MLSelectPhotoPickerBrowserPhotoScrollView.h"
#import "UIImage+MLTint.h"
#import "MLSelectPhotoCommon.h"
#import "MLSelectPhotoAssets.h"

// 分页控制器的高度
static NSInteger ZLPickerColletionViewPadding = 10;
static NSString *_cellIdentifier = @"collectionViewCell";

@interface MLSelectPhotoBrowserViewController () <UIScrollViewDelegate,ZLPhotoPickerPhotoScrollViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate>

// 控件
@property (strong,nonatomic)    UIButton         *deleleBtn;
@property (weak,nonatomic)      UIButton         *backBtn;
@property (weak,nonatomic)      UICollectionView *collectionView;
// 标记View
@property (strong,nonatomic)    UIToolbar *toolBar;
@property (weak,nonatomic)      UILabel *makeView;
@property (strong,nonatomic)    UIButton *doneBtn;
@property (strong,nonatomic)    NSMutableDictionary *deleteAssets;
// 是否是编辑模式
@property (assign,nonatomic) BOOL isEditing;
@property (assign,nonatomic) BOOL isShowSheet;

@end

@implementation MLSelectPhotoBrowserViewController

#pragma mark - getter
-(NSMutableDictionary *)deleteAssets{
    if (!_deleteAssets) {
        _deleteAssets = [NSMutableDictionary dictionary];
    }
    return _deleteAssets;
}

- (void)setDoneAssets:(NSMutableArray *)doneAssets{
    _doneAssets = [NSMutableArray arrayWithArray:doneAssets];
    [self refreshAsset];
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.itemSize = CGSizeMake(self.view.ml_size.width + ZLPickerColletionViewPadding, self.view.ml_size.height);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.ml_width + ZLPickerColletionViewPadding,self.view.ml_height) collectionViewLayout:flowLayout];
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.pagingEnabled = YES;
        collectionView.dataSource = self;
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.bounces = YES;
        collectionView.delegate = self;
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:_cellIdentifier];
        
        [self.view addSubview:collectionView];
        self.collectionView = collectionView;
        
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_collectionView]-x-|" options:0 metrics:@{@"x":@(-ZLPickerColletionViewPadding)} views:@{@"_collectionView":_collectionView}]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_collectionView]-0-|" options:0 metrics:nil views:@{@"_collectionView":_collectionView}]];
        
        if (self.isEditing) {
            // 初始化底部ToorBar
            [self setupToorBar];
        }
    }
    return _collectionView;
}

- (UILabel *)makeView{
    if (!_makeView) {
        UILabel *makeView = [[UILabel alloc] init];
        makeView.textColor = [UIColor whiteColor];
        makeView.textAlignment = NSTextAlignmentCenter;
        makeView.font = [UIFont systemFontOfSize:13];
        makeView.frame = CGRectMake(-18, 12.5, 20, 20);
        makeView.hidden = YES;
        makeView.layer.cornerRadius = makeView.frame.size.height / 2.0;
        makeView.clipsToBounds = YES;
        makeView.backgroundColor = [UIColor colorWithRed:0/255.0 green:91/255.0 blue:255/255.0 alpha:1.0];
        [self.view addSubview:makeView];
        self.makeView = makeView;
    }
    return _makeView;
}

- (UIButton *)doneBtn{
    if (!_doneBtn) {
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setTitleColor:[UIColor colorWithRed:0/255.0 green:91/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
        rightBtn.enabled = YES;
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        rightBtn.frame = CGRectMake(0, 0, 45, 45);
        [rightBtn setTitle:self.doneStr ? self.doneStr : @"完成" forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn addSubview:self.makeView];
        self.doneBtn = rightBtn;
    }
    return _doneBtn;
}

- (UIButton *)deleleBtn {
    if (!_deleleBtn) {
        UIButton *deleleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleleBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [deleleBtn setImage:[[UIImage imageNamed:MLSelectPhotoSrcName(@"photo_choose_icon")] imageWithTintColor:[UIColor grayColor]] forState:UIControlStateNormal];
        deleleBtn.frame = CGRectMake(0, 0, 22, 22);
        [deleleBtn addTarget:self action:@selector(deleteAsset) forControlEvents:UIControlEventTouchUpInside];
        self.deleleBtn = deleleBtn;
    }
    return _deleleBtn;
}

#pragma mark - setter
- (void)setPhotos:(NSArray *)photos {
    _photos = photos;

    [self reloadData];
}

#pragma mark - Life cycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.isBrowse) {
        self.navigationController.navigationBar.hidden = YES;
        self.toolBar.hidden = YES;
    }
    if ([self.doneAssets containsObject:[self.photos objectAtIndex:self.currentPage]]) {
        [self.deleleBtn setImage:[UIImage imageNamed:MLSelectPhotoSrcName(@"photo_choose_icon") ] forState:UIControlStateNormal];
    }else{
        [self.deleleBtn setImage:[UIImage imageNamed:MLSelectPhotoSrcName(@"photo_unchoose_icon")] forState:UIControlStateNormal];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (!self.isBrowse) {
        if (self.doneAssets) {
            [[NSNotificationCenter defaultCenter] postNotificationName:PICKER_REFRESH_DONE object:nil userInfo:@{@"assets":self.doneAssets}];
        }
    }
    
    self.navigationController.navigationBar.hidden = NO;
    self.toolBar.hidden = NO;
}

#pragma mark - 初始化底部ToorBar && 对应按钮方法
- (void)setupToorBar {
    UIToolbar *toorBar = [[UIToolbar alloc] init];
    toorBar.barTintColor = UIColorFromRGB(0x333333);
    toorBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:toorBar];
    self.toolBar = toorBar;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(toorBar);
    NSString *widthVfl =  @"H:|-0-[toorBar]-0-|";
    NSString *heightVfl = @"V:[toorBar(44)]-0-|";
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:0 views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:0 views:views]];
    
    // 左视图 中间距 右视图
    UIBarButtonItem *fiexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.doneBtn];
    
    toorBar.items = @[fiexItem,rightItem];
}

- (void)refreshAsset {
    for (NSInteger i = 0; i < self.photos.count; i++) {
        MLSelectPhotoAssets *asset = [self.photos objectAtIndex:i];
        if ([self.doneAssets containsObject:asset]) {
            [self.deleteAssets setObject:@YES forKey:[NSString stringWithFormat:@"%ld",i]];
        }
    }
    
    self.makeView.hidden = !(self.doneAssets.count && self.isEditing);
    self.makeView.text = [NSString stringWithFormat:@"%ld",self.doneAssets.count];
}

#pragma mark - Actions
- (void)done {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PICKER_TAKE_DONE object:nil userInfo:@{@"selectAssets":self.doneAssets}];
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)deleteAsset {
    // 红点动画
    [self.makeView.layer removeAllAnimations];
    CAKeyframeAnimation *scaoleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaoleAnimation.duration = 0.25;
    scaoleAnimation.autoreverses = YES;
    scaoleAnimation.values = @[[NSNumber numberWithFloat:1.0],[NSNumber numberWithFloat:1.2],[NSNumber numberWithFloat:1.0]];
    scaoleAnimation.fillMode = kCAFillModeForwards;
    [self.makeView.layer addAnimation:scaoleAnimation forKey:@"transform.rotate"];
    [self.deleleBtn.layer addAnimation:scaoleAnimation forKey:@"transform.rotate"];
    
    NSString *currentPage = [NSString stringWithFormat:@"%ld",self.currentPage];
    if ([self.doneAssets containsObject:[self.photos objectAtIndex:self.currentPage]]) {
        [self.doneAssets removeObject:[self.photos objectAtIndex:self.currentPage]];
        [self.deleleBtn setImage:[UIImage imageNamed:MLSelectPhotoSrcName(@"photo_unchoose_icon")] forState:UIControlStateNormal];
        [self.deleteAssets removeObjectForKey:currentPage];
    }else{
        if (self.doneAssets.count >= self.maxCount) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您已经选满图片啦." delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
            [alertView show];
            return ;
        }
        [self.deleteAssets setObject:@YES forKey:currentPage];
        [self.deleleBtn setImage:[UIImage imageNamed:MLSelectPhotoSrcName(@"photo_choose_icon") ] forState:UIControlStateNormal];
        [self.doneAssets addObject:[self.photos objectAtIndex:self.currentPage]];
    }
    
    self.makeView.hidden = !(self.doneAssets.count && self.isEditing);
    self.makeView.text = [NSString stringWithFormat:@"%ld",self.doneAssets.count];
}

- (void)showFromeImageView:(UIImageView *)imageView {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    [window.rootViewController addChildViewController:self];
//    [UIView animateWithDuration:0.2 animations:^{
//        self.view.size = imageView.frame.size;
//        self.view.center = imageView.center;
//    } completion:^(BOOL finished) {
//        self.view.size = [UIScreen mainScreen].bounds.size;
//        self.view.center = window.center;
//    }];
}

#pragma mark - reloadData
- (void)reloadData {
    [self.collectionView reloadData];
    self.collectionView.contentOffset = CGPointMake(self.currentPage * self.collectionView.ml_width, self.collectionView.contentOffset.y);
    // 添加自定义View
    [self setPageLabelPage:self.currentPage];
}

- (void)setIsEditing:(BOOL)isEditing {
    _isEditing = isEditing;
    
    if (isEditing) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.deleleBtn];
    }
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.photos.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellIdentifier forIndexPath:indexPath];
    
    if (self.photos.count) {
        cell.backgroundColor = [UIColor clearColor];
        if([[cell.contentView.subviews lastObject] isKindOfClass:[UIView class]]){
            [[cell.contentView.subviews lastObject] removeFromSuperview];
        }
        
        UIView *scrollBoxView = [[UIView alloc] init];
        scrollBoxView.frame = cell.bounds;
        scrollBoxView.ml_y = cell.ml_y;
        [cell.contentView addSubview:scrollBoxView];
        
        MLSelectPhotoPickerBrowserPhotoScrollView *scrollView =  [[MLSelectPhotoPickerBrowserPhotoScrollView alloc] init];
        scrollView.sheetStrArray = self.sheetStrArray;
        scrollView.sheetBlock = self.sheetBlock;
        scrollView.backgroundColor = [UIColor clearColor];
        // 为了监听单击photoView事件
        scrollView.frame = [UIScreen mainScreen].bounds;
        scrollView.photoScrollViewDelegate = self;
        scrollView.asset = self.photos[indexPath.item];
        
        [scrollBoxView addSubview:scrollView];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return cell;
}

// 单击调用
- (void)pickerPhotoScrollViewDidSingleClick:(MLSelectPhotoPickerBrowserPhotoScrollView *)photoScrollView {
    if (self.isBrowse) {
        self.view.backgroundColor = [UIColor clearColor];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    } else {
        self.navigationController.navigationBar.hidden = !self.navigationController.navigationBar.isHidden;
        if (self.isEditing) {
            self.toolBar.hidden = !self.toolBar.isHidden;
        }
    }
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger currentPage = (NSInteger)((scrollView.contentOffset.x / scrollView.ml_width) + 0.5);
    if([[self.deleteAssets allValues] count] == 0 || [self.deleteAssets valueForKeyPath:[NSString stringWithFormat:@"%ld",(currentPage)]] == nil){
        [self.deleleBtn setImage:[UIImage imageNamed:MLSelectPhotoSrcName(@"photo_unchoose_icon")] forState:UIControlStateNormal];
    }else{
        [self.deleleBtn setImage:[UIImage imageNamed:MLSelectPhotoSrcName(@"photo_choose_icon") ] forState:UIControlStateNormal];
    }
}

- (void)setPageLabelPage:(NSInteger)page {
    self.title = [NSString stringWithFormat:@"%ld / %ld",page + 1, self.photos.count];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger currentPage = (NSInteger)scrollView.contentOffset.x / scrollView.ml_width;
    self.currentPage = currentPage;
    [self setPageLabelPage:currentPage];
}

@end