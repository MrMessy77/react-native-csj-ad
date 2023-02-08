//
//  SplashAd.m
//
//  Created by ivan zhang on 2019/9/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "SplashAd.h"

#import <BUAdSDK/BUAdSDKManager.h>
#import <BUAdSDK/BURewardedVideoModel.h>
#import <BUAdSDK/BUSplashAd.h>

#define AD_EVENT @"SplashAdEvent"

@interface SplashAd () <BUSplashAdDelegate>

@end

@implementation SplashAd

RCT_EXPORT_MODULE();

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (NSArray<NSString *> *)supportedEvents {
    return @[
        AD_EVENT
    ];
}

RCT_EXPORT_METHOD(loadSplashAd:(NSDictionary *)options resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
    
    NSString *slotID = options[@"slotID"];
    NSString *hideSkipButton = options[@"hideSkipButton"];
    NSString *tolerateTimeout = options[@"tolerateTimeout"];
    
    if(slotID == nil) {
        NSError *error = [[NSError alloc] initWithDomain:@"splash" code:-1 userInfo:nil];
        reject(@"-1", @"slotID不能为空", error);
        return;
    }
        
    // 穿山甲开屏广告
    CGSize size = [UIScreen mainScreen].bounds.size;
    BUSplashAd *_splashAd = [[BUSplashAd alloc] initWithSlotID:slotID adSize:size];
    // 设置开屏广告代理
    _splashAd.delegate = self;

    if (hideSkipButton != nil) {
        _splashAd.hideSkipButton = YES;
    }
    if (tolerateTimeout != nil) {
        _splashAd.tolerateTimeout = [tolerateTimeout doubleValue];
    }
    
    // 加载广告
    [_splashAd loadAdData];
    
    resolve(@"调用成功");
}

/*******************************BUSplashAdDelegate*********************************/
// SDK渲染开屏广告加载成功回调
- (void)splashAdLoadSuccess:(nonnull BUSplashAd *)splashAd {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"onAdLoadSuccess" forKey:@"event"];
    [self sendEventWithName:AD_EVENT body:dic];
}

// 返回的错误码(error)表示广告加载失败的原因，所有错误码详情请见链接Link
- (void)splashAdLoadFail:(nonnull BUSplashAd *)splashAd error:(BUAdError * _Nullable)error {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"onAdLoadFail" forKey:@"event"];
    [dic setObject:[NSString stringWithFormat:@"%ld",error.code] forKey:@"code"];
    [dic setObject:error.userInfo forKey:@"msg"];
    [self sendEventWithName:AD_EVENT body:dic];
}

// SDK渲染开屏广告即将展示
- (void)splashAdWillShow:(nonnull BUSplashAd *)splashAd {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"onAdWillShow" forKey:@"event"];
    [self sendEventWithName:AD_EVENT body:dic];
}

// SDK渲染开屏广告展示
- (void)splashAdDidShow:(nonnull BUSplashAd *)splashAd {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"onAdDidShow" forKey:@"event"];
    [self sendEventWithName:AD_EVENT body:dic];
}

// SDK渲染开屏广告点击回调
- (void)splashAdDidClick:(BUSplashAd *)splashAd {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"onAdDidClick" forKey:@"event"];
    [self sendEventWithName:AD_EVENT body:dic];
}

// SDK渲染开屏广告关闭回调，当用户点击广告时会直接触发此回调，建议在此回调方法中直接进行广告对象的移除操作
- (void)splashAdDidClose:(nonnull BUSplashAd *)splashAd closeType:(BUSplashAdCloseType)closeType {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"onAdDidClose" forKey:@"event"];
    [dic setObject:[NSString stringWithFormat:@"%ld", (long)closeType] forKey:@"closeType"];
    [self sendEventWithName:AD_EVENT body:dic];
}

// SDK渲染开屏广告视图控制器关闭
- (void)splashAdViewControllerDidClose:(nonnull BUSplashAd *)splashAd {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"onAdViewControllerDidClose" forKey:@"event"];
    [self sendEventWithName:AD_EVENT body:dic];
}

// 此回调在广告跳转到其他控制器时，该控制器被关闭时调用。interactionType：此参数可区分是打开的appstore/网页/视频广告详情页面
- (void)splashDidCloseOtherController:(nonnull BUSplashAd *)splashAd interactionType:(BUInteractionType)interactionType {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"onDidCloseOtherController" forKey:@"event"];
    [dic setObject:[NSString stringWithFormat:@"%ld", (long)interactionType] forKey:@"interactionType"];
    [self sendEventWithName:AD_EVENT body:dic];
}

// SDK渲染开屏广告渲染成功回调
- (void)splashAdRenderSuccess:(nonnull BUSplashAd *)splashAd {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"onAdRenderSuccess" forKey:@"event"];
    [self sendEventWithName:AD_EVENT body:dic];
}

// SDK渲染开屏广告渲染失败回调
- (void)splashAdRenderFail:(nonnull BUSplashAd *)splashAd error:(BUAdError * _Nullable)error {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"onAdRenderFail" forKey:@"event"];
    [dic setObject:[NSString stringWithFormat:@"%ld",error.code] forKey:@"code"];
    [dic setObject:error.userInfo forKey:@"msg"];
    [self sendEventWithName:AD_EVENT body:dic];
}

// 视频广告播放完毕回调
- (void)splashVideoAdDidPlayFinish:(nonnull BUSplashAd *)splashAd didFailWithError:(nonnull NSError *)error {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"onVideoAdDidPlayFinish" forKey:@"event"];
    [dic setObject:[NSString stringWithFormat:@"%ld",error.code] forKey:@"code"];
    [dic setObject:error.userInfo forKey:@"msg"];
    [self sendEventWithName:AD_EVENT body:dic];
}

@end


