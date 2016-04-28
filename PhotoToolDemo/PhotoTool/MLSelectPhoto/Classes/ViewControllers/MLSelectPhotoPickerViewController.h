//  github: https://github.com/MakeZL/MLSelectPhoto
//  author: @email <120886865@qq.com>
//
//  PickerViewController.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLSelectPhotoCommon.h"
// 回调
typedef void(^callBackBlock)(id obj);

// 状态组
typedef NS_ENUM(NSInteger , PickerViewShowStatus) {
    PickerViewShowStatusGroup = 0, // default groups .
    PickerViewShowStatusCameraRoll,
};

@protocol ZLPhotoPickerViewControllerDelegate <NSObject>
/**
 *  返回所有的Asstes对象
 */
- (void)pickerViewControllerDoneAsstes:(NSArray *) assets;
@end

@interface MLSelectPhotoPickerViewController : UIViewController

// @optional
@property (nonatomic, weak) id<ZLPhotoPickerViewControllerDelegate> delegate;
// 决定你是否需要push到内容控制器, 默认显示组
@property (nonatomic, assign) PickerViewShowStatus status;
// 取的是哪种数据sourceType(图片、声音或者视频)
@property (nonatomic, assign) MLSourceType sourceType;
// 可以用代理来返回值或者用block来返回值
@property (nonatomic, copy) callBackBlock callBack;
// 每次选择图片的最小数, 默认与最大数是9
@property (nonatomic, assign) NSInteger maxCount;
// 底下菜单栏完成按钮名字,若不设置则默认为@"完成"
@property (nonatomic, strong) NSString *doneStr;
// 记录选中的值
@property (nonatomic, strong) NSArray *selectPickers;
// 置顶展示图片
@property (nonatomic, assign) BOOL topShowPhotoPicker;
// @function
// 展示控制器
- (void)showPickerVc:(UIViewController *)vc;

@end
