//  github: https://github.com/MakeZL/MLSelectPhoto
//  author: @email <120886865@qq.com>
//
//  ZLAssets.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 15-1-3.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

#import "MLSelectPhotoAssets.h"

@implementation MLSelectPhotoAssets

/*- (UIImage *)thumbImage {
    __block UIImage *thumb;
    [[MLPhotoTool sharePhotoTool] getThumbImageWithAsset:self.asset complete:^(UIImage *thumbImage) {
        thumb = thumbImage;
    }];
    return thumb;
}

- (UIImage *)fullImage {
    __block UIImage *full;
    [[MLPhotoTool sharePhotoTool] getFullImageWithAsset:self.asset complete:^(UIImage *fullImage) {
        full = fullImage;
    }];
    return full;
}

- (MLSourceType)sourceType {
    return [[MLPhotoTool sharePhotoTool] getSourceTypeWithAsset:self.asset];
}

- (NSURL *)assetURL{
    return [[self.asset defaultRepresentation] url];
}*/

@end
