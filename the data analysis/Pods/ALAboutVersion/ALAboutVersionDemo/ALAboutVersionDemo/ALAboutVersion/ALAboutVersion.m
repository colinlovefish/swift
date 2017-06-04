//
//  ALNewVersion.m
//  XHVersionExample
//
//  Created by DHF on 2016/11/24.
//  Copyright © 2016年 ruiec.cn. All rights reserved.
//

#import "ALAboutVersion.h"
#import <StoreKit/StoreKit.h>

@implementation ALAppInfo

- (instancetype)initWithResult:(NSDictionary *)result {
    if (self = [super init]) {
        self.version = result[@"version"];
        self.releaseNotes = result[@"releaseNotes"];
        self.currentVersionReleaseDate = result[@"currentVersionReleaseDate"];
        self.trackId = result[@"trackId"];
        self.bundleId = result[@"bundleId"];
        self.trackViewUrl = result[@"trackViewUrl"];
        self.appDescription = result[@"appDescription"];
        self.sellerName = result[@"sellerName"];
        self.fileSizeBytes = result[@"fileSizeBytes"];
        self.screenshotUrls = result[@"screenshotUrls"];
    }
    return self;
}

@end

@interface ALAboutVersion () <UIAlertViewDelegate,SKStoreProductViewControllerDelegate>

@property (nonatomic,strong) ALAppInfo *appInfo;

@end

@implementation ALAboutVersion

+ (instancetype)shareInstance {
    static ALAboutVersion *version = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [[ALAboutVersion alloc] init];
    });
    return version;
}

+ (void)checkNewVersion {
    [[ALAboutVersion shareInstance] _checkNewVersion];
}

+ (void)checkNewVersionCustomAlert:(void (^)(ALAppInfo *))newVersion {
    [[ALAboutVersion shareInstance] _checkNewVersionCustomAlert:newVersion];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self _openInAppStoreForAppURL:self.appInfo.trackViewUrl];
    }
}

#pragma mark - SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)_checkNewVersion {
    [self _requestVersion:^(ALAppInfo *appInfo) {
        NSString *updateMsg = [NSString stringWithFormat:@"%@",appInfo.releaseNotes];
        if ([[UIDevice currentDevice].systemVersion floatValue] <= 8.0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"发现新版本" message:updateMsg delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"更新", nil];
            [alertView show];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"发现新版本" message:updateMsg preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self _openInAppStoreForAppURL:self.appInfo.trackViewUrl];
                //            [self openInStoreProductViewControllerForAppId:self.appInfo.trackId]
            }]];
            [[self _window].rootViewController presentViewController:alert animated:YES completion:nil];
        }
    }];
}

- (void)_checkNewVersionCustomAlert:(void(^)(ALAppInfo *appInfo))newVersion {
    [self _requestVersion:^(ALAppInfo *appInfo) {
        if (newVersion) {
            newVersion(appInfo);
        }
    }];
}

- (void)_openInStoreProductViewControllerForAppId:(NSString *)appId {
    SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc] init];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:appId forKey:SKStoreProductParameterITunesItemIdentifier];
    storeProductVC.delegate = self;
    [storeProductVC loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error) {
        if (result) {
            [[self _window].rootViewController presentViewController:storeProductVC animated:YES completion:nil];
        }
    }];
    
}

- (void)_openInAppStoreForAppURL:(NSString *)appURL {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appURL]];
}

- (void)_requestVersion:(void(^)(ALAppInfo *appInfo))newVersion {
    [self _requestData:^(NSDictionary *responseDict) {
        NSInteger resultCount = [responseDict[@"resultCount"] integerValue];
        if(resultCount == 1) {
            NSArray *resultArray = responseDict[@"results"];
            NSDictionary *result = resultArray.firstObject;
            ALAppInfo *appInfo = [[ALAppInfo alloc] initWithResult:result];
            NSString *version = appInfo.version;
            self.appInfo = appInfo;
            if([self _isNewVersion:version]) {
                if(newVersion) {
                    newVersion(self.appInfo);
                }
            }
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)_requestData:(void(^)(NSDictionary *responseDict))success failure:(void(^)(NSError *error))failure {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleId = infoDict[@"CFBundleIdentifier"];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?bundleId=%@",bundleId]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(!error) {
                    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                    if(success) {
                      success(responseDict);
                    }
                } else {
                    if(failure) {
                        failure(error);
                    }
                }
            });
        }];
        [dataTask resume];
    });
}

- (BOOL)_isNewVersion:(NSString *)newVersion {
    NSString *key = @"CFBundleShortVersionString";
    NSString *currentVersion = [NSBundle mainBundle].infoDictionary[key];
    if([currentVersion compare:newVersion options:NSNumericSearch] == NSOrderedAscending) {
        return YES;
    }
    return NO;
}

- (UIWindow *)_window {
    UIWindow *_window = nil;
    id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate respondsToSelector:@selector(_window)]) {
        _window = [delegate performSelector:@selector(window)];
    } else {
        _window = [[UIApplication sharedApplication] keyWindow];
    }
    return _window;
}

@end
