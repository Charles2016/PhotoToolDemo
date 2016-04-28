//  github: https://github.com/MakeZL/MLSelectPhoto
//  author: @email <120886865@qq.com>
//
//  MLSelectPhotoBrowserViewController.h
//  MLSelectPhoto
//
//  Created by 张磊 on 15/4/23.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLSelectPhotoBrowserViewController : UIViewController
// 展示的图片 MLSelectAssets
@property (nonatomic, strong) NSArray *photos;
// 选择的Assets
@property (nonatomic, strong) NSMutableArray *doneAssets;
// 长按图片弹出的UIActionSheet选项名称
@property (nonatomic, strong) NSArray *sheetStrArray;
// 长按图片弹出的UIActionSheet回调
@property (nonatomic, copy) void (^sheetBlock)(UIImage *image, NSInteger buttonIndex);
// 当前提供的分页数
@property (nonatomic, assign) NSInteger currentPage;
// 最多能选择图片的个数
@property (nonatomic, assign) NSInteger maxCount;
// 底下菜单栏完成按钮名字,若不设置则默认为@"完成"
@property (nonatomic, strong) NSString *doneStr;
// 是否用作图片组查看
@property (nonatomic, assign) BOOL isBrowse;

// 显示大图查看模式view
- (void)showFromeImageView:(UIImageView *)imageView;

@end
