//
//  RewardVideoViewController.m
//
//  Created by ivan zhang on 2019/5/6.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "RewardVideoViewController.h"
#import <BUAdSDK/BUNativeExpressRewardedVideoAd.h>
#import <BUAdSDK/BURewardedVideoModel.h>
#import "AdBoss.h"
#import "RewardVideo.h"

#define BUD_RGB(a,b,c) [UIColor colorWithRed:(a/255.0) green:(b/255.0) blue:(c/255.0) alpha:1]
#define GlobleHeight [UIScreen mainScreen].bounds.size.height
#define GlobleWidth [UIScreen mainScreen].bounds.size.width
#define inconWidth 45
#define inconEdge 15
#define bu_textEnde 5
#define bu_textColor BUD_RGB(0xf0, 0xf0, 0xf0)
#define bu_textFont 14

@interface RewardVideoViewController () <BUNativeExpressRewardedVideoAdDelegate>

@property (nonatomic, strong, nullable) UILabel *titleLabel;
@property BOOL isAdShowing;

@end

@implementation RewardVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //尝试cache 还是不行，rn提前加载的module和显示的线程不同，无法用...
//    BUNativeExpressRewardedVideoAd * adCache = [AdBoss getRewardAdCache];
//    if(adCache != nil) {
//        NSLog(@"尝试cache 有提前缓存的ad  ... valid = %s ", adCache.adValid ? "YES": "NO");
//        if(adCache.adValid){
//            [self showAd: adCache];
//        }
//    }
    
    //rn module已确保有缓存的ad
    BUNativeExpressRewardedVideoAd * ad = [AdBoss getRewardAd];
    if(ad != nil) {
        //关联回调
        ad.delegate = self;
        [ad loadAdData]; //加载广告
        
        if(ad.adValid){
            NSLog(@"有提前缓存的有效ad ...");
            //但是直接展示adManager缓存的ad对象，居然不显示画面
            // [self showAd: ad];
        }
    }
}

//展示广告
- (void) showAd :(BUNativeExpressRewardedVideoAd *) ad {
    if(!self.isAdShowing) {
        self.isAdShowing = true;
        NSLog(@"展示 提前缓存的ad adValid = %s", ad.adValid ? "Yes":"NO");
        if(ad.adValid) {
            [ad showAdFromRootViewController:self];
        }
    }
    else {
        NSLog(@"已展示提前缓存的ad !!!");
    }
}

#pragma mark BUNativeExpressRewardedVideoAdDelegate

- (void)nativeExpressRewardedVideoAdDidLoad:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    BUD_Log(@"rewardedVideoAd 激励视频 %s",__func__);
    [RewardVideo emitEvent: @{@"type": @"onAdLoaded", @"message": @"success"}];
    [AdBoss setRewardAdCache: rewardedVideoAd];
    [self showAd: rewardedVideoAd];
}

- (void)nativeExpressRewardedVideoAdViewRenderSuccess:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    BUD_Log(@"%s rewardVideoAd 激励视频 渲染成功",__func__);
	[AdBoss setRewardAdCache: rewardedVideoAd];
    [self showAd: rewardedVideoAd];
}

- (void)nativeExpressRewardedVideoAd:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    BUD_Log(@"rewardVideoAd 激励视频 didFailWithError: %@", error);
    [RewardVideo emitEvent: @{@"type": @"onAdError", @"message": @""}];
}


- (void)nativeExpressRewardedVideoAdCallback:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd withType:(BUNativeExpressRewardedVideoAdType)nativeExpressVideoType{
    BUD_Log(@"%s 激励视频 %lu",__func__, nativeExpressVideoType);
}

- (void)nativeExpressRewardedVideoAdDidDownLoadVideo:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    BUD_Log(@"%s rewardVideoAd 激励视频 下载完成了",__func__);
}

- (void)nativeExpressRewardedVideoAdViewRenderFail:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd error:(NSError *_Nullable)error {
    BUD_Log(@"%s rewardVideoAd 激励视频 渲染出错了",__func__);
    //TODO: 视频视图渲染出错了
}

- (void)nativeExpressRewardedVideoAdWillVisible:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    BUD_Log(@"%s 激励视频",__func__);
}

- (void)nativeExpressRewardedVideoAdDidVisible:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    BUD_Log(@"%s 激励视频",__func__);
}

- (void)nativeExpressRewardedVideoAdWillClose:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    BUD_Log(@"%s 激励视频",__func__);
}

- (void)nativeExpressRewardedVideoAdDidClose:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    BUD_Log(@"%s 激励视频",__func__);
    [RewardVideo emitEvent: @{@"type": @"onAdClose", @"message": @""}];
    
    //完成播放 关闭广告 拿回promise结果
    [[AdBoss getRootVC] dismissViewControllerAnimated:true completion:^{
        if([AdBoss getRewardVideoClicks] > 0)
        {
            //每次返回rn后清空激励视频点击次数
            [AdBoss resetClickRewardVideo];
            
            [AdBoss getResolve](@{
                @"video_play":@1,
                @"ad_click":@1, //点击
                @"ad_skip":@1
            });
        }else{
            [AdBoss getResolve](@{
                @"video_play":@1,
                @"ad_click":@0, //没有点击
                @"ad_skip":@1
            });
        }
    }];
    
}

- (void)nativeExpressRewardedVideoAdDidClick:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    BUD_Log(@"%s 激励视频",__func__);
    //点了激励视频
    [AdBoss clickRewardVideo];
    [RewardVideo emitEvent: @{@"type": @"onAdClick", @"message": @""}];
}

- (void)nativeExpressRewardedVideoAdDidClickSkip:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    BUD_Log(@"%s 激励视频",__func__);
    //TODO: 点了跳过激励视频
}

- (void)nativeExpressRewardedVideoAdDidPlayFinish:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    BUD_Log(@"%s 激励视频",__func__);
}

- (void)nativeExpressRewardedVideoAdServerRewardDidSucceed:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify {
    BUD_Log(@"%s 激励视频",__func__);
}

- (void)nativeExpressRewardedVideoAdServerRewardDidFail:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    BUD_Log(@"%s 激励视频",__func__);
}

- (void)nativeExpressRewardedVideoAdDidCloseOtherController:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd interactionType:(BUInteractionType)interactionType {
    NSString *str = nil;
    if (interactionType == BUInteractionTypePage) {
        str = @"ladingpage";
    } else if (interactionType == BUInteractionTypeVideoAdDetail) {
        str = @"videoDetail";
    } else {
        str = @"appstoreInApp";
    }
    BUD_Log(@"%s _激励视频其他关闭操作_ %@",__func__,str);
}

-(BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
@end
