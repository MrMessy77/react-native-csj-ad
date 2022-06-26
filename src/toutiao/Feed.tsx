import React from 'react';
import { requireNativeComponent, StyleSheet, ViewStyle } from 'react-native';
const FeedAdComponent = requireNativeComponent('FeedAd');
import TxFeed from '../tencent/TxFeed';
export interface FeedAdProps {
    provider?: string;
    codeid: string;
    style?: ViewStyle;
    adWidth?: number;
    visible?: boolean;
    onAdLayout?: Function;
    onAdError?: Function;
    onAdClose?: Function;
    onAdClick?: Function;
}

const FeedAd = (props: FeedAdProps) => {
    const {
        provider,
        codeid,
        style,
        adWidth = 150,
        onAdLayout,
        onAdError,
        onAdClose,
        onAdClick,
        visible = true,
    } = props;
    const [closed, setClosed] = React.useState(false);
    const [height, setHeight] = React.useState(0);
    // FeedAd是否显示，外部和内部均可控制，外部visible、内部closed
    if (!visible || closed) return null;

    if (provider === '腾讯') {
        return <TxFeed codeid={codeid} adWidth={adWidth} />;
    }

    return (
        <FeedAdComponent
            codeid={codeid}
            // 里面素材的宽度，减30是有些情况下，里面素材过宽贴边显示不全
            adWidth={adWidth - 30}
            // 为了不影响广告宽度占满屏幕的情况，style的width可单独控制
            style={{ width: adWidth, height, ...style }}
            onAdError={(e: any) => {
                onAdError && onAdError(e.nativeEvent);
            }}
            onAdClick={(e: any) => {
                onAdClick && onAdClick(e.nativeEvent);
            }}
            onAdClose={(e: any) => {
                setClosed(true);
                onAdClose && onAdClose(e.nativeEvent);
            }}
            onAdLayout={(e: any) => {
                if (e.nativeEvent.height) {
                    setHeight(e.nativeEvent.height + 10);
                    onAdLayout && onAdLayout(e.nativeEvent);
                }
            }}
        />
    );
};

export default FeedAd;
