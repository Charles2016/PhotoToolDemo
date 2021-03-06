//  github: https://github.com/MakeZL/MLSelectPhoto
//  author: @email <120886865@qq.com>
//
//  ZLPhotoPickerBrowserPhotoScrollView.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-14.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MLSelectPhotoPickerBrowserPhotoImageView.h"
#import "MLSelectPhotoPickerBrowserPhotoView.h"

typedef void(^callBackBlock)(id obj);
@class MLSelectPhotoPickerBrowserPhotoScrollView;

@protocol ZLPhotoPickerPhotoScrollViewDelegate <NSObject>
@optional
// 单击调用
- (void) pickerPhotoScrollViewDidSingleClick:(MLSelectPhotoPickerBrowserPhotoScrollView *)photoScrollView;
@end

@interface MLSelectPhotoPickerBrowserPhotoScrollView : UIScrollView <UIScrollViewDelegate, ZLPhotoPickerBrowserPhotoImageViewDelegate,ZLPhotoPickerBrowserPhotoViewDelegate>
@property (nonatomic, strong) id asset;
@property (nonatomic, weak) id <ZLPhotoPickerPhotoScrollViewDelegate> photoScrollViewDelegate;
// 长按图片弹出的UIActionSheet选项名称
@property (nonatomic, strong) NSArray *sheetStrArray;
// 长按图片弹出的UIActionSheet回调
@property (nonatomic, copy) void (^sheetBlock)(UIImage *image, NSInteger buttonIndex);
// 单击销毁的block
@property (nonatomic, copy) callBackBlock callback;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;//加载图片菊花

@end
