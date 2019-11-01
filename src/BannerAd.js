import React, {Component} from 'react';
import {
  SafeAreaView,
  StyleSheet,
  ScrollView,
  View,
  Text,
  StatusBar,
  NativeModules,
  TouchableOpacity,
  UIManager,
  findNodeHandle,
  Button,
} from 'react-native';
import AdView from './AdView';
import { throwStatement } from '@babel/types';

class BannerAd extends Component {
  bannerSizes = [
    "mediumRectangle",
    "banner",
    "largeBanner",
    // "mediumRectangle",
    "fullBanner",
    "leaderboard",
    "smartBannerPortrait",
    "smartBannerLandscape"
  ];
  adUnits = [
    '1001-rubicon-300x250',
    '1001-appnexus-300x250',
    '1001-300x250',
  ];
  
  state = {
    bannerSize: this.bannerSizes[0],
    adUnit: this.adUnits[0],
    isVisible: false,
    adUnitIndex: 0,
    bannerSizeIndex: 0,
    message: '',
    messages: [],
  };

  onLoadClicked = () => {
    this.setState({isVisible: true});
  };

  // onClick = (e) => {
  //   console.log(e.nativeEvent.bannerSize);
  //   this.setState({bannerSize: e.nativeEvent.bannerSize});
  // };

  onLogFromNative = (e) => {
    console.log('%conLogFromNative', 'background-color: purple; color: white;', e.nativeEvent.message);
    this.setState({message: e.nativeEvent.message});
    const messages = [...this.state.messages];
    messages.push(e.nativeEvent.message);
    this.setState({messages});
  };

  onRefreshClicked = (propName, value, index) => {
    this.setState({[propName]:value, [propName + 'Index']: index});
  };

  onDestroyClicked = () => {
    this.setState({bannerSize: 'destroy', bannerSizeIndex: -1});
  };

  didFailToReceiveAdWithError = console.log;

  render() {
    console.log(this.state);
    const buttonView = (text, event, isSelected) => (
      <View style={{alignItems: 'flex-start', flexDirection: 'row'}}>
        <TouchableOpacity style={[styles.button, isSelected ? styles.selected : null]} onPress={event}>
          <Text>{text}</Text>
        </TouchableOpacity>
      </View>
    );
    
    if (!this.state.isVisible) {
      return (
        <View style={styles.container}>
          {buttonView('Load me', this.onLoadClicked)}
          <Text style={[styles.wrapper, {backgroundColor: '#efefef'}]}>
            Ad not loaded
          </Text>
        </View>
      );
    }
    
    return (
      <View style={styles.container}>
        <View style={{flexDirection: 'row'}}>
          {buttonView('Destroy', this.onDestroyClicked, this.state.bannerSizeIndex === -1)}
          {this.bannerSizes.map((item, index) => (
            <View key={item}>
              {buttonView('B ' + (index + 1), () => this.onRefreshClicked('bannerSize', item, index), this.state.bannerSizeIndex === index)}
            </View>
          ))}
        </View>
        <View style={{flexDirection: 'row'}}>
          {this.adUnits.map((item, index) => (
            <View key={item}>
              {buttonView('Ad ' + (index + 1), () => this.onRefreshClicked('adUnit', item, index), this.state.adUnitIndex === index)}
            </View>
          ))}
        </View>
        <AdView
          adUnit={this.state.adUnit}
          bannerSize={this.state.bannerSize}
          // onClick={this.onClick}
          style={[styles.wrapper, styles.ad]}
          onDidFailToReceiveAdWithError={(event) => {
            this.didFailToReceiveAdWithError(event.nativeEvent.error);
          }}
          onLog={this.onLogFromNative}
        />
        <Text>
          {this.state.bannerSize}
          {"\n"}
          {this.state.adUnit}
          {"\n"}
          {this.state.messages.length > 0 && this.state.messages.map((item, index) => (
            (index + 1) + ": " + item + "\n"
          ))}
        </Text>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'stretch'
  },
  ad: {
    height: 250
  },
  wrapper: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  border: {
    borderColor: '#eee',
    borderBottomWidth: 1,
  },
  button: {
    padding: 5,
    margin: 3,
    borderColor: '#efefef',
    borderWidth: 1,
    backgroundColor: '#ddd'
  },
  selected: {
    backgroundColor: 'lightblue'
  }
});

export default BannerAd;
