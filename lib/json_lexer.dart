library json_lexer;

import "dart:collection";

enum ValueType {
  NUMBER,
  BOOL,
  STRING,
  BEGIN_OBJECT,
  END_OBJECT,
  BEGIN_ARRAY,
  END_ARRAY,
  NULL,
  VALUE_SEPARATOR,
  NAME_SEPARATOR
}

enum TokenType {
  VALUE,
  BEGIN_OBJECT,
  END_OBJECT,
  BEGIN_ARRAY,
  END_ARRAY,
  VALUE_SEPARATOR,
  NAME_SEPARATOR,
  EOF
}

RegExp _STRING = new RegExp(r'^"$');
RegExp _WHITESPACE = new RegExp(r"^\s$");

List _numberCharacters = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-", "e", "E", "."];

Map<String, ValueType> _valueTypeMap = {
  "0": ValueType.NUMBER,
  "1": ValueType.NUMBER,
  "2": ValueType.NUMBER,
  "3": ValueType.NUMBER,
  "4": ValueType.NUMBER,
  "5": ValueType.NUMBER,
  "6": ValueType.NUMBER,
  "7": ValueType.NUMBER,
  "8": ValueType.NUMBER,
  "9": ValueType.NUMBER,
  "-": ValueType.NUMBER,
  "t": ValueType.BOOL,
  "f": ValueType.BOOL,
  "{": ValueType.BEGIN_OBJECT,
  "}": ValueType.END_OBJECT,
  "[": ValueType.BEGIN_ARRAY,
  "]": ValueType.END_ARRAY,
  "n": ValueType.NULL,
  ",": ValueType.VALUE_SEPARATOR,
  ":": ValueType.NAME_SEPARATOR,
  '"': ValueType.STRING
};

Map<String, TokenType> _tokenTypeMap = {
  "0": TokenType.VALUE,
  "1": TokenType.VALUE,
  "2": TokenType.VALUE,
  "3": TokenType.VALUE,
  "4": TokenType.VALUE,
  "5": TokenType.VALUE,
  "6": TokenType.VALUE,
  "7": TokenType.VALUE,
  "8": TokenType.VALUE,
  "9": TokenType.VALUE,
  "-": TokenType.VALUE,
  "t": TokenType.VALUE,
  "f": TokenType.VALUE,
  "{": TokenType.BEGIN_OBJECT,
  "}": TokenType.END_OBJECT,
  "[": TokenType.BEGIN_ARRAY,
  "]": TokenType.END_ARRAY,
  "n": TokenType.VALUE,
  ",": TokenType.VALUE_SEPARATOR,
  ":": TokenType.NAME_SEPARATOR,
  '"': TokenType.VALUE
};

class JsonLexer {

  int _index = 0;
  String _json;
  Queue<Token> tokens;

  JsonLexer(String this._json) {
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
      while (_WHITESPACE.hasMatch(character)) {
        _index++;
        character = _json[_index];
      }

      String value;
      ValueType valueType = _valueTypeMap[character];
      TokenType tokenType = _tokenTypeMap[character];
      switch (valueType) {
        case ValueType.NUMBER:
          value = parseNumber();
          break;
        case ValueType.BOOL:
          value = parseBool();
          break;
        case ValueType.NULL:
          value = parseNull();
          break;
        case ValueType.STRING:
          value = parseString();
          break;
        case ValueType.BEGIN_OBJECT:
        case ValueType.END_OBJECT:
        case ValueType.BEGIN_ARRAY:
        case ValueType.END_ARRAY:
        case ValueType.NAME_SEPARATOR:
        case ValueType.VALUE_SEPARATOR:
          value = character;
          _index++;
          break;
        default:
          throw new ArgumentError("Syntax Error: Unexpected token $character");
      }

      Token token = new Token();
      token.valueType = valueType;
      token.value = value;
      token.type = tokenType;
      tokens.add(token);
    }
    tokens.add(new Token()..type=TokenType.EOF);
    return tokens;
  }

  String parseNumber() {
    String number = "";

    String character = _json[_index];
    while(_numberCharacters.contains(character)) {
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
  ValueType valueType;
  String value;
  TokenType type;
}