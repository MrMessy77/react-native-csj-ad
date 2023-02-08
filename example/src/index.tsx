import React, { useEffect } from 'react';
import { ScrollView, View, Text, TouchableOpacity, StyleSheet } from 'react-native';

import { ad } from 'react-native-ad';

export default function Splash() {
  useEffect(() => {
    ad.init({ appid: '5364208' });
  }, []);

  return (
    <View style={styles.container}>
      <Text style={styles.welcome}>
        穿山甲广告
      </Text>
      <TouchableOpacity
        style={styles.button}
        onPress={async () => {
          let { eventEmitter } = ad.startSplash({ slotID: '888082675' });
          eventEmitter.addListener('SplashAdEvent', (event) => {
            console.log(event)
          });
        }}>
        <Text style={{ textAlign: 'center', color: '#fff' }}>开屏广告</Text>
      </TouchableOpacity>
      <TouchableOpacity
        style={styles.button}
        onPress={() => {
        }}>
        <Text style={{ textAlign: 'center', color: '#fff' }}>全屏广告</Text>
      </TouchableOpacity>
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
    fontSize: 28,
    textAlign: 'center',
    margin: 10,
  },
  button: {
    marginVertical: 10,
    paddingHorizontal: 20,
    paddingVertical: 15,
    backgroundColor: '#F96',
    borderRadius: 50,
    width: '80%'
  }
});
