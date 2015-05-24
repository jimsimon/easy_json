/// The json_tokenizer library.
library json_tokenizer;

import "dart:collection";

RegExp STRING = new RegExp(r'^"$');
RegExp WHITESPACE = new RegExp(r"^\s$");

List numberCharacters = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-", "e", "E", "."];

Map<String, String> valueTypeMap = {
  "0": "number",
  "1": "number",
  "2": "number",
  "3": "number",
  "4": "number",
  "5": "number",
  "6": "number",
  "7": "number",
  "8": "number",
  "9": "number",
  "-": "number",
  "t": "bool",
  "f": "bool",
  "{": "begin-object",
  "}": "end-object",
  "[": "begin-array",
  "]": "end-array",
  "n": "null",
  ",": "value-separator",
  ":": "name-separator",
  '"': "string"
};

Map<String, String> tokenTypeMap = {
  "0": "value",
  "1": "value",
  "2": "value",
  "3": "value",
  "4": "value",
  "5": "value",
  "6": "value",
  "7": "value",
  "8": "value",
  "9": "value",
  "-": "value",
  "t": "value",
  "f": "value",
  "{": "begin-object",
  "}": "end-object",
  "[": "begin-array",
  "]": "end-array",
  "n": "value",
  ",": "value-separator",
  ":": "name-separator",
  '"': "value"
};

class JsonTokenizer {

  int _index = 0;
  String _json;
  Queue<Token> tokens;

  JsonTokenizer(String this._json) {
    tokens = _tokenize();
  }

  Token nextToken() {
    if (tokens.isEmpty) {
      return null;
    }

    return tokens.removeFirst();
  }

  Queue<Token> _tokenize() {
    Queue<Token> tokens = new Queue();
    while(_index != _json.length) {
      String character = _json[_index];
      while (WHITESPACE.hasMatch(character)) {
        _index++;
        character = _json[_index];
      }

      String value;
      var valueType = valueTypeMap[character];
      var tokenType = tokenTypeMap[character];
      switch (valueType) {
        case "number":
          value = parseNumber();
          break;
        case "bool":
          value = parseBool();
          break;
        case "null":
          value = parseNull();
          break;
        case "string":
          value = parseString();
          break;
        case "begin-object":
        case "end-object":
        case "begin-array":
        case "end-array":
        case "name-separator":
        case "value-separator":
          value = character;
          _index++;
          break;
        default:
          throw new ArgumentError("Unknown type");
      }

      Token token = new Token();
      token.valueType = valueType;
      token.value = value;
      token.type = tokenType;
      tokens.add(token);
    }
    tokens.add(new Token()..type="eof");
    return tokens;
  }

  String parseNumber() {
    String number = "";

    String character = _json[_index];
    while(numberCharacters.contains(character)) {
      number += character;
      _index++;
      if (_index == _json.length) {
        break;
      }
      character = _json[_index];
    }
    return number;
  }

  String parseString() {
    _index++;
    String string = "";
    String character = _json[_index];
    while (character != '"') {
      string += character;
      _index++;
      if (_index == _json.length) {
        throw new ArgumentError("Invalid json fragment encountered: $string");
      }
      character = _json[_index];
    }
    _index++;
    return string;
  }

  String parseBool() {
    int remainingLength = _json.length - _index;
    if (remainingLength >= 5 && _json.substring(_index, _index + 5) == "false") {
      _index += 5;
      return "false";
    }

    if (remainingLength >= 4 && _json.substring(_index, _index + 4) == "true") {
      _index += 4;
      return "true";
    }
    throw new ArgumentError("Invalid json fragment encountered: $_json");
  }

  String parseNull() {
    String value = "";
    int remainingLength = _json.length - _index;
    if (remainingLength >= 4 && _json.substring(_index, _index + 4) == "null") {
      _index += 4;
      return "null";
    }
    throw new ArgumentError("Invalid json fragment encountered: $value");
  }
}


class Token {
  String valueType;
  String value;
  String type;
}