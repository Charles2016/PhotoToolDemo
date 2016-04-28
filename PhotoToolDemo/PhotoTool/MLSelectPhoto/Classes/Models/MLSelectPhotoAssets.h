//  github: https://github.com/MakeZL/MLSelectPhoto
//  author: @email <120886865@qq.com>
//
//  ZLAssets.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 15-1-3.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLSelectPhotoCommon.h"

/// 单张图片信息
@interface MLSelectPhotoAssets : NSObject

@property (nonatomic, strong) UIImage *thumbImage;  //缩略图
@property (nonatomic, strong) UIImage *fullImage;   //原图
@property (nonatomic, assign) MLSourceType sourceType;     //获取是否是视频类型
@property (nonatomic, strong) id asset;//图片集，通过该属性获取该照片相关信息

@end
