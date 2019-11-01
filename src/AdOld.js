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
} from 'react-native';
import CounterView from './CounterView';

class AdOld extends Component {
  state = {
    data: 'DTW',
    count: 1,
  };

  updateEvents = async () => {
    try {
      console.log('updateEvents');
    } catch (e) {
      console.error(e);
    }
  };

  onClick = () => {
    // this.updateEvents();
    console.log('onClick');
    console.log(NativeModules.CalendarManager);
    console.log('increment:', NativeModules.CalendarManager.increment());
    NativeModules.CalendarManager.getCount((first, ...others) => {
      console.log('count is ', first);
      console.log('other arguments ', others);
    });

    this.decrement();
    this.decrementAsync();
  };

  decrement = () => {
    NativeModules.CalendarManager.decrement()
      .then(res => console.log(res))
      .catch(e => console.log(e.message, e.code));
  };

  decrementAsync = async () => {
    try {
      const res = await NativeModules.CalendarManager.decrement();
      console.log(res);
    } catch (e) {
      console.log(e.message, e.code);
    }
  };

  increment = () => {
    this.setState({count: this.state.count + 1});
  };

  update = e => {
    console.log('update fired', e.nativeEvent.count);
    this.setState({
      count: e.nativeEvent.count,
    });
  };

  updateNative = () => {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this.counterRef),
      UIManager['CounterView'].Commands.updateFromManager,
      [this.state.count],
    );
  };

  render() {
    return (
      <View style={styles.container}>
        <Text onPress={this.onClick}>
          Testing | {JSON.stringify(this.state.data)}
        </Text>
        <TouchableOpacity
          style={[styles.wrapper, styles.border]}
          onLongPress={this.updateNative}
          onPress={this.increment}>
          <Text style={styles.button}>{this.state.count}</Text>
        </TouchableOpacity>
        <CounterView style={styles.wrapper} count={2} onUpdate={this.update} ref={e => this.counterRef = e}/>
        <CounterView style={styles.wrapper} count={2} onUpdate={this.update} />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'stretch',
  },
  wrapper: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    height: 50,
  },
  border: {
    borderColor: '#eee',
    borderBottomWidth: 1,
  },
  button: {
    fontSize: 50,
    color: 'orange',
  },
});

export default AdOld;
