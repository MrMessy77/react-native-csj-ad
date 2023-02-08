import React from 'react';
import { NativeModules, NativeEventEmitter } from 'react-native';

const { SplashAd } = NativeModules;
const eventEmitter = new NativeEventEmitter(SplashAd);

export interface SPLASHAD_PROPS_TYPE {
  slotID: string; // 广告位id
  hideSkipButton?: boolean; // 隐藏跳过按钮
  tolerateTimeout?: number; // 倒计时时间
}

export default ({ slotID, hideSkipButton, tolerateTimeout }: SPLASHAD_PROPS_TYPE) => {
  let result = SplashAd.loadSplashAd({ slotID, hideSkipButton, tolerateTimeout });

  return {
    result,
    eventEmitter,
  };
};
