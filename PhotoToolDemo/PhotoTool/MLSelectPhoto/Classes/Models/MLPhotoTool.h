//
//  MLPhotoTool.h
//  多选相册照片
//
//  Created by long on 15/11/30.
//  Copyright © 2015年 long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MLSelectPhotoAssets.h"
#import "MLSelectPhotoPickerGroup.h"

#define ML_ISIOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface MLPhotoTool : NSObject

@property (nonatomic , strong) ALAssetsLibrary *library;

+ (instancetype)sharePhotoTool;

/// 获取所有相册列表，sourceType资源类型
- (void)getAllSourceWithType:(MLSourceType)sourceType complete:(void(^)(NSArray *photoAblumLists))complete;

/// 传入相册集，获取该相册集中所有asset，sourceType资源类型
- (void)getAllSourceWithAssetsGroup:(id)assetsGroup Type:(MLSourceType)sourceType complete:(void(^)(NSArray *photoAsset))complete;

/// 传入assets获取相册内的所有图片
- (MLSourceType)getSourceTypeWithAsset:(id)asset;

/// 传入asset获取缩略图
- (void)getThumbImageWithAsset:(id)asset complete:(void(^)(UIImage *thumbImage))complete;

/// 传入asset获取原图
- (void)getFullImageWithAsset:(id)asset complete:(void(^)(UIImage *fullImage))complete;

/// 传入相册集取到相册第一张缩略图
- (void)getFirstThumbWithAssetGroup:(id)assetGroup complete:(void(^)(UIImage *thumbImage))complete;

/// 传入asset判断是否是同一个用于小图和原图时的比较
- (BOOL)isSameAsset:(id)asset asset:(id)otherAsset;

/// 传URL取到对应的图片信息
- (id)getAssetWithURL:(NSURL *)url;

/// 保存image返回指定类型asset或url,iOS8以下不指定相册
- (void)saveImage:(UIImage *)image returnType:(MLReturnType)returnType complete:(void(^)(id source))complete;

@end
