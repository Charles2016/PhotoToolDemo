//  github: https://github.com/MakeZL/MLSelectPhoto
//  author: @email <120886865@qq.com>
//
//  MLSelectPhotoPickerGroup.h
//  MLSelectPhoto
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 相册相关信息
@interface MLSelectPhotoPickerGroup : NSObject

@property (nonatomic, copy) NSString *type; //文件类型(照片或视频)
@property (nonatomic, copy) NSString *title; //相册名字
@property (nonatomic, strong) UIImage *thumbImage; //相册第一张图片缩略图
@property (nonatomic, assign) NSInteger assetsCount; //该相册内相片数量
@property (nonatomic, strong) id assetsGroup;//相册集，通过该属性获取该相册集下所有照片

@end
