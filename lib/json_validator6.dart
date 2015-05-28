library v6;

import "dart:collection";
import "package:json_tokenizer/json_tokenizer.dart";


class JsonValidator {

  static const int INIT = 0;
  static const int TOP_LEVEL_VALUE = 1;
  static const int ENTERED_OBJECT = 2;
  static const int ENTERED_ARRAY = 3;
  static const int OBJECT_VALUE = 4;
  static const int OBJECT_VALUE_SEPARATOR = 5;
  static const int OBJECT_NAME_SEPARATOR = 6;
  static const int OBJECT_KEY = 7;
  static const int ARRAY_VALUE = 8;
  static const int ARRAY_VALUE_SEPARATOR = 9;
  static const int EXITED_OBJECT = 10;
  static const int EXITED_ARRAY = 11;
  static const int EOF = 12;

  isValid(String json) {
    int _state = INIT;
    Queue<String> _stack = new Queue();
    Queue<Token> _tokens = new JsonTokenizer(json).tokens;

    while (_tokens.isNotEmpty) {
      Token token = _tokens.removeFirst();

      if (_tokens.length == 1 && token.type == "value-separator") {
        throwError(token);
      }

      switch (_state) {
        case INIT:
          switch (token.type) {
            case "begin-object":
              _stack.addFirst(token.type);
              _state = ENTERED_OBJECT;
              break;
            case "begin-array":
              _stack.addFirst(token.type);
              _state = ENTERED_ARRAY;
              break;
            case "value":
              _state = TOP_LEVEL_VALUE;
              break;
            default:
              throwError(token);
          }
          break;
        case TOP_LEVEL_VALUE:
          switch (token.type) {
            case "eof":
              _state = EOF;
              break;
            default:
              throwError(token);
          }
          break;
        case ENTERED_OBJECT:
          switch (token.type) {
            case "end-object":
              _stack.removeFirst();
              _state = EXITED_OBJECT;
              break;
            case "value":
            //TODO only allow strings
              _state = OBJECT_KEY;
              break;
            default:
              throwError(token);
          }
          break;
        case OBJECT_KEY:
          switch (token.type) {
            case "name-separator":
              _state = OBJECT_NAME_SEPARATOR;
              break;
            default:
              throwError(token);
          }
          break;
        case OBJECT_NAME_SEPARATOR:
          switch (token.type) {
            case "value":
              _state = OBJECT_VALUE;
              break;
            case "begin-array":
              _stack.addFirst(token.type);
              _state = ENTERED_ARRAY;
              break;
            case "begin-object":
              _stack.addFirst(token.type);
              _state = ENTERED_OBJECT;
              break;
            default:
              throwError(token);
          }
          break;
        case OBJECT_VALUE:
          switch (token.type) {
            case "end-object":
              _stack.removeFirst();
              _state = EXITED_OBJECT;
              break;
            case "value-separator":
              _state = OBJECT_VALUE_SEPARATOR;
              break;
            default:
              throwError(token);
          }
          break;
        case OBJECT_VALUE_SEPARATOR:
          switch (token.type) {
            case "value":
              _state = OBJECT_KEY;
              break;
            default:
              throwError(token);
          }
          break;
        case ENTERED_ARRAY:
          switch (token.type) {
            case "begin-array":
              _stack.addFirst(token.type);
              _state = ENTERED_ARRAY;
              break;
            case "end-array":
              _stack.removeFirst();
              _state = EXITED_ARRAY;
              break;
            case "value":
              _state = ARRAY_VALUE;
              break;
            case "begin-object":
              _stack.addFirst(token.type);
              _state = ENTERED_OBJECT;
              break;
            default:
              throwError(token);
          }
          break;
        case ARRAY_VALUE:
          switch (token.type) {
            case "end-array":
              _stack.removeFirst();
              _state = EXITED_ARRAY;
              break;
            case "value-separator":
              _state = ARRAY_VALUE_SEPARATOR;
              break;
            default:
              throwError(token);
          }
          break;
        case ARRAY_VALUE_SEPARATOR:
          switch (token.type) {
            case "value":
              _state = ARRAY_VALUE;
              break;
            case "begin-object":
              _stack.addFirst(token.type);
              _state = ENTERED_OBJECT;
              break;
            case "begin-array":
              _stack.addFirst(token.type);
              _state = ENTERED_ARRAY;
              break;
            default:
              throwError(token);
          }
          break;
        case EXITED_OBJECT:
          switch (token.type) {
            case "eof":
              _state = EOF;
              break;
            case "end-array":
              if (_stack.isEmpty) {
                throwError(token);
              }
              _stack.removeFirst();
              _state = EXITED_ARRAY;
              break;
            case "value-separator":
              _state = ARRAY_VALUE_SEPARATOR;
              break;
            case "end-object":
              _stack.removeFirst();
              _state = EXITED_OBJECT;
              break;
            default:
              throwError(token);
          }
          break;
        case EXITED_ARRAY:
          switch (token.type) {
            case "eof":
              _state = EOF;
              break;
            case "end-array":
              _stack.removeFirst();
              _state = EXITED_ARRAY;
              break;
            case "value-separator":
              if (_stack.first == "begin-array") {
                _state = ARRAY_VALUE_SEPARATOR;
              } else if (_stack.first == "begin-object") {
                _state = OBJECT_VALUE_SEPARATOR;
              }
              break;
            case "end-object":
              _stack.removeFirst();
              _state = EXITED_OBJECT;
              break;
            default:
              throwError(token);
          }
          break;
        default:
          throwError(token);
          break;
      }
      if (_state == EOF) {
        if (_stack.isNotEmpty) {
          throwError(token);
        }
        return true;
      }
    }
  }
}

void throwError(Token token) {
  throw new ArgumentError("Unexpected token: ${token.value}");
}