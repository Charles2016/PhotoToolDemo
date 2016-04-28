//  github: https://github.com/MakeZL/MLSelectPhoto
//  author: @email <120886865@qq.com>
//
//  ZLPhotoPickerAssetsViewController.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-12.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLSelectPhotoPickerGroupViewController.h"
#import "MLPhotoTool.h"

@class MLSelectPhotoPickerGroup;

@interface MLSelectPhotoPickerAssetsViewController : UIViewController

@property (weak ,nonatomic) MLSelectPhotoPickerGroupViewController *groupVC;
@property (nonatomic, assign) MLSourceType sourceType;
@property (nonatomic, strong) MLSelectPhotoPickerGroup *photoGroup;
@property (nonatomic, assign) NSInteger maxCount;
@property (nonatomic, strong) NSString *doneStr;
// 需要记录选中的值的数据
@property (nonatomic, strong) NSArray *selectPickerAssets;
// 置顶展示图片
@property (nonatomic, assign) BOOL topShowPhotoPicker;

@end
