//
//  ALNewVersion.h
//  XHVersionExample
//
//  Created by DHF on 2016/11/24.
//  Copyright © 2016年 ruiec.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALAppInfo : NSObject

@property (nonatomic,copy) NSString *version;//版本号
@property (nonatomic,copy) NSString *releaseNotes;//更新日志
@property (nonatomic,copy) NSString *currentVersionReleaseDate;//更新时间
@property (nonatomic,copy) NSString *trackId;//APPId
@property (nonatomic,copy) NSString *bundleId;//bundleId
@property (nonatomic,copy) NSString *trackViewUrl;//AppStore地址
@property (nonatomic,copy) NSString *appDescription;//APP简介
@property (nonatomic,copy) NSString *sellerName;//开发商
@property (nonatomic,copy) NSString *fileSizeBytes;//文件大小
@property (nonatomic,strong)NSArray *screenshotUrls;//展示图

- (instancetype)initWithResult:(NSDictionary *)result;

@end

@interface ALAboutVersion : NSObject

+ (void)checkNewVersion;
+ (void)checkNewVersionCustomAlert:(void(^)(ALAppInfo *appInfo))newVersion;

@end
