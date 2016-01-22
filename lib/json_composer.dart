part of easy_json;

class JsonComposer {

  bool _isPrimitive(value) {
    return value == null || value is num || value is bool;
  }

  _translateToJsonCodecCompatibleRepresentation(input) {
    if (_isPrimitive(input) || input is String) {
      //TODO Remove once https://code.google.com/p/dart/issues/detail?id=1533 (dart2js and spec disagree about numerics) is fixed
      if (input is double) {
        var dblInput = input as double;
        var remainder = dblInput.remainder(1);
        if (remainder == 0) {
          return dblInput.toInt();
        }
      }
      return input;
    }

    if (input is List) {
      List list = [];
      List inputAsList = input as List;
      inputAsList.forEach((inputValue){
        var value = _translateToJsonCodecCompatibleRepresentation(inputValue);
        list.add(value);
      });
      return list;
    }
    if (input is Map) {
      var map = {};
      Map inputAsMap = input as Map;
      inputAsMap.forEach((inputKey, inputValue){
        if (!_isValidJsonKeyType(inputKey)) {
          throw new ArgumentError("Map keys must be a String");
        }
        var key = _translateToJsonCodecCompatibleRepresentation(inputKey);
        var value = _translateToJsonCodecCompatibleRepresentation(inputValue);

        if (_isPrimitive(key)) {
          key = "$key";
        }
        map[key] = value;
      });
      return map;
    }

    //Has to be an object
    Map map = {};
    InstanceMirror im = reflect(input);
    ClassMirror cm = im.type;
    List propertyKeys = cm.instanceMembers.keys.toList();
    for (int i = 0; i < propertyKeys.length; i++) {
      Symbol key = propertyKeys[i];
//        String keyName = serializable.getName(key);
      //TODO: Fix this hack once reflectable supports getName
      String keyName = _getKeyName(key);
      MethodMirror mm = cm.instanceMembers[key];
      if (mm.isGetter && mm.isSynthetic) {
        map[keyName] = _translateToJsonCodecCompatibleRepresentation(im.getField(key).reflectee);
      }
    }
    return map;
  }

  String compose(input) {
    var jsonCodecCompatibleRepresentation = _translateToJsonCodecCompatibleRepresentation(input);
    return JSON.encode(jsonCodecCompatibleRepresentation);
  }

  String _getKeyName(Symbol key) {
    String keyName = key.toString();
    keyName = keyName.substring(8, keyName.length - 2);
    return keyName;
  }

  bool _isValidJsonKeyType(value) {
    return _isPrimitive(value) || value is String;
  }
}
