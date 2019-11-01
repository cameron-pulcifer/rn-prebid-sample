import React from 'react';
import {
  Text,
  View
} from 'react-native';

const Content = (props) => {
  const style = {
    backgroundColor: props.bgColor || 'white',
    height: props.height || 200,
    flex: 1,
    borderWidth: 5,
    borderColor: '#fff',
    alignContent: 'center',
    justifyContent: 'center',
    padding: 20
  };
  return (
    <View style={style}>
      <Text>{props.children}</Text>
    </View>
  );
};

export default Content;