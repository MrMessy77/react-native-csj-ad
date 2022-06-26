package com.haxifang.ad;

import android.app.Activity;
import android.content.Intent;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.haxifang.ad.activities.RewardActivity;
import com.haxifang.ad.utils.TToast;

public class RewardVideo extends ReactContextBaseJavaModule {
  private static final String TAG = "RewardVideo";
  private static ReactApplicationContext mContext;
  public static Promise promise;

  public RewardVideo(ReactApplicationContext context) {
    super(context);
    mContext = context;
  }

  @NonNull
  @Override
  public String getName() {
    return TAG;
  }

  @ReactMethod
  public void startAd(ReadableMap options, final Promise promise) {
    //拿到参数
    String codeId = options.getString("codeid");
    String provider = options.getString("provider");
    Log.d(TAG, "startAd:codeId: " + codeId + provider);

    //准备激励回调
    AdBoss.prepareReward(promise, mContext);
    // 启动激励视频页面
    if (provider.equals("腾讯")) {
      startTx(codeId);
    } else if (provider.equals("快手")) {
      startKs(codeId);
    } else {
      startTT(codeId);
    }
  }

  /**
   * 启动穿山甲激励视频
   *
   * @param codeId
   */
  public static void startTT(String codeId) {
    Activity context = mContext.getCurrentActivity();
    try {
      Intent intent = new Intent(mContext, RewardActivity.class);
      intent.putExtra("codeId", codeId);
      // 不要过渡动画
      context.overridePendingTransition(0, 0);
      context.startActivityForResult(intent, 10000);
    } catch (Exception e) {
      e.printStackTrace();
      Log.e(TAG, "start reward Activity error: ", e);
    }
  }

  /**
   * 启动优量汇激励视频
   *
   * @param codeId
   */
  public static void startTx(String codeId) {
    final String message = "启动腾讯激励视频";
    Log.d(TAG, message + "  codeID: " + codeId);
    Activity ac = mContext.getCurrentActivity();
    if (ac != null) {
      ac.runOnUiThread(
        () -> {
          // TToast.show(mContext, message);
          Intent intent = new Intent(
            mContext,
            com.haxifang.ad.activities.tencent.RewardActivity.class
          );
          intent.putExtra("codeId", codeId);
          ac.startActivity(intent);
        }
      );
    }
  }

  /**
   * 启动快手激励视频
   *
   * @param codeId
   */
  public static void startKs(String codeId) {
    final String message = "启动快手激励视频";
    Log.d(TAG, message + "  codeID: " + codeId);
    Activity ac = mContext.getCurrentActivity();
    if (ac != null) {
      ac.runOnUiThread(
        () -> {
          // TToast.show(mContext, message);
          Intent intent = new Intent(
            mContext,
            com.haxifang.ad.activities.kuaishou.RewardActivity.class
          );
          intent.putExtra("codeId", codeId);
          ac.startActivity(intent);
        }
      );
    }
  }

  // 发送事件到RN
  public static void sendEvent(String eventName, @Nullable WritableMap params) {
    mContext
      .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
      .emit(TAG + "-" + eventName, params);
  }
}
