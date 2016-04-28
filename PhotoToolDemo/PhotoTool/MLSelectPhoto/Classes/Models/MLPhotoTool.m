//
//  MLPhotoTool.m
//  多选相册照片
//
//  Created by long on 15/11/30.
//  Copyright © 2015年 long. All rights reserved.
//

#import "MLPhotoTool.h"

@implementation MLPhotoTool

static MLPhotoTool *sharePhotoTool = nil;


+ (instancetype)sharePhotoTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharePhotoTool = [[self alloc] init];
    });
    return sharePhotoTool;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharePhotoTool = [super allocWithZone:zone];
    });
    return sharePhotoTool;
}

/// 获取所有相册列表，sourceType资源类型
- (void)getAllSourceWithType:(MLSourceType)sourceType complete:(void(^)(NSArray *photoAblumList))complete {
    __block NSMutableArray *photoAblumLists = [NSMutableArray array];
    if (ML_ISIOS8) {
        mWeakSelf;
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status != PHAuthorizationStatusNotDetermined && status != PHAuthorizationStatusDenied) {
                [weakSelf getSourceWithType:sourceType photoAblumLists:photoAblumLists complete:complete];
            }
        }];
    } else {
        if (!self.library) {
            self.library = [[ALAssetsLibrary alloc] init];
        }
        [self.library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *assetsGroup, BOOL *stop) {
            if (assetsGroup) {
                if (sourceType == MLSourcePhoto) {
                    // 筛选图片资源
                    [assetsGroup setAssetsFilter:[ALAssetsFilter allAssets]];
                    [self getPhotoAssetsInfo:assetsGroup photoAblumLists:photoAblumLists sourceType:sourceType];
                } else if (sourceType == MLSourceVideo) {
                    // 筛选视频资源
                    [assetsGroup setAssetsFilter:[ALAssetsFilter allVideos]];
                    [self getPhotoAssetsInfo:assetsGroup photoAblumLists:photoAblumLists sourceType:sourceType];
                } else {
                    // 筛选声音资源
                }
            } else {
              complete(photoAblumLists);
            }
        } failureBlock:^(NSError *error) {
            if (error.code == -3311) {
                // ALAssetsLibraryAccessUserDeniedError
                NSLog(@"用户拒绝访问相册");
            }
        }];
    }
}

/// 传入相册集，获取该相册集中所有asset，sourceType资源类型
- (void)getAllSourceWithAssetsGroup:(id)assetsGroup Type:(MLSourceType)sourceType complete:(void(^)(NSArray *photoAsset))complete {
    NSMutableArray *assets = [NSMutableArray array];
    mWeakSelf;
    if (ML_ISIOS8) {
        PHFetchResult *result = [self fetchAssetsInAssetCollection:assetsGroup ascending:YES];
        [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MLSourceType type = [weakSelf getSourceTypeWithAsset:obj];
            // 过滤掉不同类型
            if (sourceType == type) {
                [assets addObject:obj];
            }
        }];
    } else {
        [assetsGroup enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
            if (asset) {
                MLSourceType type = [weakSelf getSourceTypeWithAsset:asset];
                // 过滤掉不同类型
                if (sourceType == type) {
                    [assets addObject:asset];
                }
            }
        }];
    }
    complete(assets);
}

/// 传入单张图片asset获取对应信息后返回
- (void)getPhotoInfo:(id)asset complete:(void(^)(MLSelectPhotoAssets *photoAsset))complete {
    MLSelectPhotoAssets *photoAsset = [[MLSelectPhotoAssets alloc] init];
    photoAsset.asset = asset;
    photoAsset.sourceType = [self getSourceTypeWithAsset:asset];
    [self getFullImageWithAsset:asset complete:^(UIImage *fullImage) {
        photoAsset.fullImage = fullImage;
    }];
    [self getThumbImageWithAsset:asset complete:^(UIImage *thumbImage) {
        photoAsset.thumbImage = thumbImage;
    }];
    complete(photoAsset);
}

/// 传入asset获取文件类型
- (MLSourceType)getSourceTypeWithAsset:(id)asset {
    MLSourceType sourceType;
    if (ML_ISIOS8) {
        PHAssetMediaType type = ((PHAsset *)asset).mediaType;
        if (type == PHAssetMediaTypeImage) {
            sourceType = MLSourcePhoto;
        } else if (type == PHAssetMediaTypeVideo) {
            sourceType = MLSourceVideo;
        } else if (type == PHAssetMediaTypeVideo) {
            sourceType = MLSourceAudio;
        } else {
            sourceType = MLSourceOthers;
        }
    } else {
        NSString *type = [asset valueForProperty:ALAssetPropertyType];
        if ([type isEqualToString:ALAssetTypeVideo]) {
            sourceType = MLSourceVideo;
        } else if ([type isEqualToString:ALAssetTypePhoto]) {
            sourceType = MLSourcePhoto;
        } else {
            sourceType = MLSourceAudio;
        }
    }
    return sourceType;
}

/// 传入asset获取缩略图
- (void)getThumbImageWithAsset:(id)asset complete:(void(^)(UIImage *thumbImage))complete {
    if (ML_ISIOS8) {
        [self requestImageForAsset:asset size:CGSizeMake(200, 200) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
            complete(image);
        }];
    } else {
        complete([UIImage imageWithCGImage:[asset aspectRatioThumbnail]]);
    }
}

/// 传入asset获取原图
- (void)getFullImageWithAsset:(id)asset complete:(void(^)(UIImage *fullImage))complete {
    if (ML_ISIOS8) {
        [self requestImageForAsset:asset size:PHImageManagerMaximumSize resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
            //过滤缩略图  wj
            if (info[@"PHImageFileURLKey"]) {
                complete(image);
            }
        }];
    } else {
        complete([UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]]);
    }
}

/// 传入相册集取到相册第一张缩略图
- (void)getFirstThumbWithAssetGroup:(id)assetGroup complete:(void(^)(UIImage *thumbImage))complete {
    if (ML_ISIOS8) {
        PHFetchResult *result = [self fetchAssetsInAssetCollection:assetGroup ascending:YES];
        if (result.count > 0) {
            [self requestImageForAsset:result.lastObject size:CGSizeMake(200, 200) resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage *image, NSDictionary *info) {
                complete(image);
            }];
        }
    } else {
        complete([UIImage imageWithCGImage:[((ALAssetsGroup *)assetGroup) posterImage]]);
    }    
}

/// 传入相册集取到该相册标题，图片或视频数量等信息suorce筛选的类型
- (void)getPhotoAssetsInfo:(id)assets photoAblumLists:(NSMutableArray *)photoAblumLists sourceType:(MLSourceType)sourceType {
    NSString *title;
    NSInteger assetsCount = 0;
    if (ML_ISIOS8) {
        PHFetchResult *result = [self fetchAssetsInAssetCollection:assets ascending:YES];
        PHAssetMediaType type;
        if (sourceType == MLSourcePhoto) {
            type = PHAssetMediaTypeImage;
        } else if (sourceType == MLSourceVideo) {
            type = PHAssetMediaTypeVideo;
        } else if (sourceType == MLSourceAudio) {
            type = PHAssetMediaTypeAudio;
        } else {
            type = PHAssetMediaTypeUnknown;
        }
        assetsCount = [result countOfAssetsWithMediaType:type];
        title = ((PHAssetCollection *)assets).localizedTitle;
    } else {
        assetsCount = [assets numberOfAssets];
        title = [assets valueForProperty:@"ALAssetsGroupPropertyName"];
    }
    // 包装一个模型来赋值
    if (assetsCount) {
        MLSelectPhotoPickerGroup *photoAblumList = [[MLSelectPhotoPickerGroup alloc] init];
        photoAblumList.assetsGroup = assets;
        photoAblumList.title = title;
        photoAblumList.assetsCount = assetsCount;
        [photoAblumLists addObject:photoAblumList];
    }
}

/// 传入asset判断是否是同一个用于小图和原图时的比较
- (BOOL)isSameAsset:(id)asset asset:(id)otherAsset {
    BOOL isSame = NO;
    if (ML_ISIOS8) {
        // 取到名字，判断名字是否一样
        NSString *assetName = [asset valueForKey:@"filename"];
        NSString *otherName = [otherAsset valueForKey:@"filename"];
        isSame = [assetName isEqualToString:otherName];
    } else {
        NSString *urlStr = [((ALAsset *)asset) defaultRepresentation].url.absoluteString;
        NSString *otherStr = [((ALAsset *)otherAsset) defaultRepresentation].url.absoluteString;
        isSame = [urlStr isEqualToString:otherStr];
    }
    return isSame;
}

/// 传URL取到对应的图片信息
- (id)getAssetWithURL:(NSURL *)url {
    __block id photoAsset;
    if (ML_ISIOS8) {
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        photoAsset = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:option].lastObject;
    } else {
        if (!self.library) {
            self.library = [[ALAssetsLibrary alloc] init];
        }
        [self.library assetForURL:url resultBlock:^(ALAsset *asset) {
            photoAsset = asset;
        } failureBlock:nil];
    }
    return photoAsset;
}

/// 保存image返回指定类型asset或url,iOS8以下不指定相册
- (void)saveImage:(UIImage *)image returnType:(MLReturnType)returnType complete:(void(^)(id source))complete {
    __block id photoSource;
    __block BOOL isSource;
    if (ML_ISIOS8) {
            __block NSString *assetId = nil;
            // 1. 存储图片到"相机胶卷"
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{ // 这个block里保存一些"修改"性质的代码
                // 新建一个PHAssetCreationRequest对象, 保存图片到"相机胶卷"
                // 返回PHAsset(图片)的字符串标识
                PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAssetFromImage:image];
                assetId = request.placeholderForCreatedAsset.localIdentifier;
            } completionHandler:^(BOOL success, NSError *error) {
                if (error) {
                    NSLog(@"保存图片到相机胶卷中失败");
                } else {
                    NSLog(@"成功保存图片到相机胶卷中");
                    // 2. 获得相册对象
                    PHAssetCollection *collection = [self collection];
                    // 3. 将“相机胶卷”中的图片添加到新的相册
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
                        // 根据唯一标示获得相片对象
                        PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
                        // 添加图片到相册中
                        [request addAssets:@[asset]];
                        [asset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
                            if (returnType == MLReturnTypeURL) {
                                photoSource = contentEditingInput.fullSizeImageURL;
                            } else {
                                photoSource = asset;
                            }
                            if (photoSource && isSource) {
                                complete(photoSource);
                            }
                        }];
                        
                    } completionHandler:^(BOOL success, NSError *error) {
                        if (error) {
                            NSLog(@"添加图片到相册中失败");
                        } else {
                            NSLog(@"保存成功");
                            isSource = YES;
                            if (photoSource) {
                                complete(photoSource);
                            }
                        }
                    }];
                }
            }];
    } else {
        if (!self.library) {
            self.library = [[ALAssetsLibrary alloc] init];
        }
        [self.library writeImageToSavedPhotosAlbum:image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
            if (returnType == MLReturnTypeURL) {
                complete(assetURL);
            } else {
                [self.library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                    complete(asset);
                } failureBlock:nil];
            }
        }];
    }
}

/// 保存图片到指定相册，iOS8以下暂时找不到方法
- (void)saveImage:(UIImage *)image {
    if (ML_ISIOS8) {
        /*
         PHAsset : 一个PHAsset对象就代表一个资源文件,比如一张图片
         PHAssetCollection : 一个PHAssetCollection对象就代表一个相册
         */
        __block NSString *assetId = nil;
        // 1. 存储图片到"相机胶卷"
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{ // 这个block里保存一些"修改"性质的代码
            // 新建一个PHAssetCreationRequest对象, 保存图片到"相机胶卷"
            // 返回PHAsset(图片)的字符串标识
            assetId = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
        } completionHandler:^(BOOL success, NSError *error) {
            if (error) {
                NSLog(@"保存图片到相机胶卷中失败");
            } else {
                NSLog(@"成功保存图片到相机胶卷中");
                // 2. 获得相册对象
                PHAssetCollection *collection = [self collection];
                // 3. 将“相机胶卷”中的图片添加到新的相册
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
                    // 根据唯一标示获得相片对象
                    PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
                    // 添加图片到相册中
                    [request addAssets:@[asset]];
                } completionHandler:^(BOOL success, NSError *error) {
                    if (error) {
                        NSLog(@"添加图片到相册中失败");
                        return;
                    } else {
                        NSLog(@"保存成功");
                    }
                }];
            }
        }];
    } else {
        if (!self.library) {
            self.library = [[ALAssetsLibrary alloc] init];
        }
        [self.library writeImageToSavedPhotosAlbum:image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                NSLog(@"保存失败");
            } else {
                NSLog(@"保存成功");
            }
        }];
    }
    
}

#pragma mark - iOS8及以上的相册操作
/// 判断第一次授权情况再取所有相册
- (void)getSourceWithType:(MLSourceType)sourceType photoAblumLists:(NSMutableArray *)photoAblumLists complete:(void(^)(NSArray *photoAblumList))complete  {
    // 获取所有智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    mWeakSelf;
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        // 过滤掉视频和最近删除
        if (![collection.localizedTitle isEqualToString:@"Recently Deleted"] && ![collection.localizedTitle isEqualToString:@"最近删除"]) {
            if (sourceType == MLSourcePhoto) {
                // 筛选图片资源
                if (![collection.localizedTitle isEqualToString:@"Videos"] && ![collection.localizedTitle isEqualToString:@"视频"]) {
                    [weakSelf getPhotoAssetsInfo:collection photoAblumLists:photoAblumLists sourceType:sourceType];
                }
            } else if (sourceType == MLSourceVideo) {
                // 筛选视频资源
                if ([collection.localizedTitle isEqualToString:@"Videos"] || [collection.localizedTitle isEqualToString:@"视频"]) {
                    [weakSelf getPhotoAssetsInfo:collection photoAblumLists:photoAblumLists sourceType:sourceType];
                }
            } else {
                // 筛选声音资源
            }
        }
    }];
    // 获取用户创建的相册
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        [weakSelf getPhotoAssetsInfo:collection photoAblumLists:photoAblumLists sourceType:sourceType];
    }];
    complete(photoAblumLists);
}

/// 查找或创建相册
- (PHAssetCollection *)collection{
    // 先获得之前创建过的相册
    PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collectionResult) {
        if ([collection.localizedTitle isEqualToString:@"畅往相册"]) {
            return collection;
        }
    }
    // 如果相册不存在,就创建新的相册(文件夹)
    __block NSString *collectionId = nil; // __block修改block外部的变量的值
    // 这个方法会在相册创建完毕后才会返回
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        // 新建一个PHAssertCollectionChangeRequest对象, 用来创建一个新的相册
        collectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"畅往相册"].placeholderForCreatedAssetCollection.localIdentifier;
    } error:nil];
    
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionId] options:nil].firstObject;
}

/// 相册标题转换方法
- (NSString *)transformAblumTitle:(NSString *)title {
    if ([title isEqualToString:@"Slo-mo"]) {
        return @"慢动作";
    } else if ([title isEqualToString:@"Recently Added"]) {
        return @"最近添加";
    } else if ([title isEqualToString:@"Favorites"]) {
        return @"最爱";
    } else if ([title isEqualToString:@"Recently Deleted"]) {
        return @"最近删除";
    } else if ([title isEqualToString:@"Videos"]) {
        return @"视频";
    } else if ([title isEqualToString:@"All Photos"]) {
        return @"所有照片";
    } else if ([title isEqualToString:@"Selfies"]) {
        return @"自拍";
    } else if ([title isEqualToString:@"Screenshots"]) {
        return @"屏幕快照";
    } else if ([title isEqualToString:@"Camera Roll"]) {
        return @"相机胶卷";
    } else if ([title isEqualToString:@"Panoramas"]) {
        return @"全景照片";
    }
    return nil;
}

- (PHFetchResult *)fetchAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending {
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    return result;
}

/// 获取asset对应的图片
- (void)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *image, NSDictionary *info))completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    /**
     resizeMode：对请求的图像怎样缩放。有三种选择：None，默认加载方式；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
     deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
     这个属性只有在 synchronous 为 true 时有效。
     */
    option.resizeMode = resizeMode;//控制照片尺寸
    //option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;//控制照片质量
    //option.synchronous = YES;
    option.networkAccessAllowed = YES;
    //param：targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize
    //contetModel
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage *image, NSDictionary *info) {
        completion(image,info);
    }];
}

@end
