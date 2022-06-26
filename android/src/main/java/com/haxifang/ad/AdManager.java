package com.haxifang.ad;

import static com.facebook.react.bridge.UiThreadUtil.runOnUiThread;

import android.util.Log;
import androidx.annotation.NonNull;
import com.bytedance.sdk.openadsdk.AdSlot;
import com.bytedance.sdk.openadsdk.TTAdNative;
import com.bytedance.sdk.openadsdk.TTNativeExpressAd;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.haxifang.ad.activities.FullScreenActivity;
import com.haxifang.ad.activities.RewardActivity;
import com.haxifang.ad.activities.SplashActivity;
import java.util.List;

public class AdManager extends ReactContextBaseJavaModule {
  public static ReactApplicationContext reactAppContext;
  public static final String TAG = "AdManager";

  public AdManager(ReactApplicationContext reactContext) {
    super(reactAppContext);
    reactAppContext = reactContext;
  }

  @NonNull
  @Override
  public String getName() {
    return TAG;
  }

  @ReactMethod
  public void init(ReadableMap options) {
    //默认头条穿山甲
    AdBoss.tt_appid =
      options.hasKey("appid") ? options.getString("appid") : AdBoss.tt_appid;
    AdBoss.debug =
      options.hasKey("debug") ? options.getBoolean("debug") : AdBoss.debug;

    if (AdBoss.tt_appid != null) {
      runOnUiThread(
        () -> {
          AdBoss.initSdk(reactAppContext, AdBoss.tt_appid, AdBoss.debug);

          // Bin：这里预加载穿山甲广告逻辑需要放在 sdk init 逻辑之后

          if (options.hasKey("codeid_splash")) {
            String codeid_splash = options.getString("codeid_splash");
            SplashActivity.loadSplashAd(
              codeid_splash,
              () -> {
                // 开屏广告预加载成功
                Log.d(TAG, "开屏预加载成功 codeid_splash " + codeid_splash);
              },
              () -> {}
            );
          }

          if (options.hasKey("codeid_full_video")) {
            AdBoss.codeid_full_video = options.getString("codeid_full_video");
            AdBoss.full_video_orientation =
              options.getString("full_video_orientation");
            //提前加载
            FullScreenActivity.loadAd(
              AdBoss.codeid_full_video,
              AdBoss.full_video_orientation,
              () -> {
                Log.d(
                  TAG,
                  "提前加载 成功 codeid_full_video " + AdBoss.codeid_full_video
                );
              }
            );
          }

          if (options.hasKey("codeid_reward_video")) {
            AdBoss.codeid_reward_video =
              options.getString("codeid_reward_video");
            //提前加载
            RewardActivity.loadAd(
              AdBoss.codeid_reward_video,
              () -> {
                Log.d(
                  TAG,
                  "提前加载 成功 codeid_reward_video " +
                  AdBoss.codeid_reward_video
                );
              }
            );
          }
        }
      );
    }

    // 支持一口气init所有需要的adConfig
    // 腾讯优量汇广告
    AdBoss.tx_appid =
      options.hasKey("tx_appid")
        ? options.getString("tx_appid")
        : AdBoss.tx_appid;
    if (AdBoss.tx_appid != null) {
      AdBoss.initTx(reactAppContext, AdBoss.tx_appid);
    }

    //百度广告
    AdBoss.bd_appid =
      options.hasKey("bd_appid")
        ? options.getString("bd_appid")
        : AdBoss.bd_appid;
    if (AdBoss.bd_appid != null) {
      AdBoss.initBd(reactAppContext, AdBoss.bd_appid);
    }

    //快手广告
    AdBoss.ks_appid =
      options.hasKey("ks_appid")
        ? options.getString("ks_appid")
        : AdBoss.ks_appid;
    if (AdBoss.ks_appid != null) {
      AdBoss.initKs(reactAppContext, AdBoss.ks_appid, AdBoss.debug);
    }

    //支持传参头条需要的userId和appName ...
    if (options.hasKey("uid")) {
      AdBoss.userId = options.getString("uid");
    }
    if (options.hasKey("app")) {
      AdBoss.appName = options.getString("app");
    }
    if (options.hasKey("amount")) {
      AdBoss.rewardAmount = options.getInt("amount");
    }
    if (options.hasKey("reward")) {
      AdBoss.rewardName = options.getString("reward");
    }
  }

  /**
   * 方便从RN主动预加载第一个广告，避免用户第一个签到的信息流广告加载+图片显示感觉很慢
   * （需要注意在展示弹层前才预加载）
   */
  @ReactMethod
  public void loadFeedAd(ReadableMap options, final Promise promise) {
    String codeId = options.getString("codeid");
    float width = 0;
    if (options.hasKey("adWidth")) {
      width = Float.parseFloat(options.getString("adWidth"));
    }
    AdBoss.feedPromise = promise;
    if (AdBoss.feed_provider.equals("腾讯")) {
      //FIXME ...
      return;
    }
    if (AdBoss.feed_provider.equals("百度")) {
      //百度的是横幅banner，不需要预加载
      return;
    }
    loadTTFeedAd(codeId, width);
  }

  /**
   * 方便从RN主动预加载第一个draw feed广告，后面每个都为下一个提前缓存广告
   * （需要注意在展示弹层前才预加载）
   */
  @ReactMethod
  public void loadDrawFeedAd(ReadableMap options) {
    String codeId = options.getString("codeid");
    loadTTDrawFeedAd(codeId);
  }

  /**
   * 加载穿山甲的信息流广告
   *
   * @param codeId
   * @param width
   */
  private static void loadTTFeedAd(String codeId, float width) {
    if (AdBoss.TTAdSdk == null) {
      Log.e(TAG, "TTAdSdk 还没初始化");
      return;
    }

    // step4:创建广告请求参数AdSlot,具体参数含义参考文档
    // 默认宽度，兼容大部分弹层的宽度即可
    float expressViewWidth = width > 0 ? width : 280;
    float expressViewHeight = 0; // 自动高度

    AdSlot adSlot = new AdSlot.Builder()
      .setCodeId(codeId) // 广告位id
      .setSupportDeepLink(true)
      .setAdCount(1) // 请求广告数量为1到3条
      .setExpressViewAcceptedSize(expressViewWidth, expressViewHeight) // 期望模板广告view的size,单位dp,高度0自适应
      .setImageAcceptedSize(640, 320)
      .setNativeAdType(AdSlot.TYPE_INTERACTION_AD) // 坑啊，不设置这个，feed广告native出不来，一直差量无效，文档太烂
      .build();

    // step5:请求广告，对请求回调的广告作渲染处理
    AdBoss.TTAdSdk.loadNativeExpressAd(
      adSlot,
      new TTAdNative.NativeExpressAdListener() {

        @Override
        public void onError(int code, String message) {
          Log.d(TAG, message);
          AdBoss.feedPromise.reject("101", "feed ad error" + message);
        }

        @Override
        public void onNativeExpressAdLoad(List<TTNativeExpressAd> ads) {
          Log.d(TAG, "onNativeExpressAdLoad: FeedAd !!!");
          if (ads == null || ads.size() == 0) {
            return;
          }
          // 缓存加载成功的信息流广告
          AdBoss.feedAd = ads.get(0);
          AdBoss.feedPromise.resolve(true);
        }
      }
    );
  }

  /**
   * 加载穿山甲的Draw信息流广告
   *
   * @param codeId
   */
  private static void loadTTDrawFeedAd(String codeId) {
    if (AdBoss.TTAdSdk == null) {
      Log.e(TAG, "TTAdSdk 还没初始化");
      return;
    }

    // 创建广告请求参数AdSlot,具体参数含义参考文档
    float expressViewWidth = 1080;
    float expressViewHeight = 1920;
    AdSlot adSlot = new AdSlot.Builder()
      .setCodeId(codeId)
      .setSupportDeepLink(true)
      .setImageAcceptedSize(1080, 1920)
      .setExpressViewAcceptedSize(expressViewWidth, expressViewHeight) // 期望模板广告view的size,单位dp
      .setAdCount(1) // 请求广告数量为1到3条
      .build();

    // 请求广告,对请求回调的广告作渲染处理
    AdBoss.TTAdSdk.loadExpressDrawFeedAd(
      adSlot,
      new TTAdNative.NativeExpressAdListener() {

        @Override
        public void onError(int code, String message) {
          Log.d(TAG, message);
        }

        @Override
        public void onNativeExpressAdLoad(List<TTNativeExpressAd> ads) {
          if (ads == null || ads.isEmpty()) {
            // TToast.show(mContext, " ad is null!");
            Log.d(TAG, "没有请求到drawfeed广告");
            return;
          }
          //成功加载到drawfeed广告 缓存
          AdBoss.drawfeedAd = ads.get(0);
        }
      }
    );
  }

  /**
   * 主动看激励视频时，才检查这个权限
   */
  @ReactMethod
  public void requestPermission() {
    // step3:(可选，强烈建议在合适的时机调用):申请部分权限，如read_phone_state,防止获取不了imei时候，下载类广告没有填充的问题。
    AdBoss.ttAdManager.requestPermissionIfNecessary(reactAppContext);
  }
}
