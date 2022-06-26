import React, {useEffect} from 'react';
import {StyleSheet, View} from 'react-native';
import {ad} from 'react-native-ad';

export default function DrawFeed() {
  useEffect(() => {
    ad.init({
      appid: '5016582',
      app: '演示APP',
    });

    console.log(ad);

    //提前加载 drawfeed ad
    ad.loadDrawFeedAd({
      appid: '5016582',
      codeid: '945339778',
    });

    return () => {};
  }, []);
  return (
    <View style={styles.container}>
      <ad.DrawFeed
        codeid="945339778" // 广告位 codeid （必传），注意区分 Android 和 IOS
        onAdShow={(msg: any) => {
          // 广告加载成功回调
          console.log('Draw Feed 广告加载成功！', msg);
        }}
        onAdError={(err: any) => {
          // 广告加载失败回调
          console.log('Draw Feed 广告加载失败！', err);
        }}
        onAdClick={(val: any) => {
          // 广告点击回调
          console.log('Draw Feed 广告被用户点击！', val);
        }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});
