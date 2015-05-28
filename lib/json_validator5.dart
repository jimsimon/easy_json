library v5;

import "dart:collection";
import "package:json_tokenizer/json_tokenizer.dart";

enum STATE {
  INIT,
  TOP_LEVEL_VALUE,
  ENTERED_OBJECT,
  ENTERED_ARRAY,
  OBJECT_VALUE,
  OBJECT_VALUE_SEPARATOR,
  OBJECT_NAME_SEPARATOR,
  OBJECT_KEY,
  ARRAY_VALUE,
  ARRAY_VALUE_SEPARATOR,
  EXITED_OBJECT,
  EXITED_ARRAY,
  EOF
}

class JsonValidator {

  isValid(String json) {
    STATE _state = STATE.INIT;
    Queue<String> _stack = new Queue();
    Queue<Token> _tokens = new JsonTokenizer(json).tokens;

    while (_tokens.isNotEmpty) {
      Token token = _tokens.removeFirst();

      if (_tokens.length == 1 && token.type == "value-separator") {
        throwError(token);
      }

      switch(_state) {
        case STATE.INIT:
          switch(token.type) {
            case "begin-object":
              _stack.addFirst(token.type);
              _state = STATE.ENTERED_OBJECT;
              break;
            case "begin-array":
              _stack.addFirst(token.type);
              _state = STATE.ENTERED_ARRAY;
              break;
            case "value":
              _state = STATE.TOP_LEVEL_VALUE;
              break;
            default:
              throwError(token);
          }
          break;
        case STATE.TOP_LEVEL_VALUE:
          switch(token.type) {
            case "eof":
              _state = STATE.EOF;
              break;
            default:
              throwError(token);
          }
          break;
        case STATE.ENTERED_OBJECT:
          switch(token.type) {
            case "end-object":
              _stack.removeFirst();
              _state = STATE.EXITED_OBJECT;
              break;
            case "value":
            //TODO only allow strings
              _state = STATE.OBJECT_KEY;
              break;
            default:
              throwError(token);
          }
          break;
        case STATE.OBJECT_KEY:
          switch(token.type) {
            case "name-separator":
              _state = STATE.OBJECT_NAME_SEPARATOR;
              break;
            default:
              throwError(token);
          }
          break;
        case STATE.OBJECT_NAME_SEPARATOR:
          switch(token.type) {
            case "value":
              _state = STATE.OBJECT_VALUE;
              break;
            case "begin-array":
              _stack.addFirst(token.type);
              _state = STATE.ENTERED_ARRAY;
              break;
            case "begin-object":
              _stack.addFirst(token.type);
              _state = STATE.ENTERED_OBJECT;
              break;
            default:
              throwError(token);
          }
          break;
        case STATE.OBJECT_VALUE:
          switch(token.type) {
            case "end-object":
              _stack.removeFirst();
              _state = STATE.EXITED_OBJECT;
              break;
            case "value-separator":
              _state = STATE.OBJECT_VALUE_SEPARATOR;
              break;
            default:
              throwError(token);
          }
          break;
        case STATE.OBJECT_VALUE_SEPARATOR:
          switch(token.type) {
            case "value":
              _state = STATE.OBJECT_KEY;
              break;
            default:
              throwError(token);
          }
          break;
        case STATE.ENTERED_ARRAY:
          switch(token.type) {
            case "begin-array":
              _stack.addFirst(token.type);
              _state = STATE.ENTERED_ARRAY;
              break;
            case "end-array":
              _stack.removeFirst();
              _state = STATE.EXITED_ARRAY;
              break;
            case "value":
              _state = STATE.ARRAY_VALUE;
              break;
            case "begin-object":
              _stack.addFirst(token.type);
              _state = STATE.ENTERED_OBJECT;
              break;
            default:
              throwError(token);
          }
          break;
        case STATE.ARRAY_VALUE:
          switch(token.type) {
            case "end-array":
              _stack.removeFirst();
              _state = STATE.EXITED_ARRAY;
              break;
            case "value-separator":
              _state = STATE.ARRAY_VALUE_SEPARATOR;
              break;
            default:
              throwError(token);
          }
          break;
        case STATE.ARRAY_VALUE_SEPARATOR:
          switch(token.type) {
            case "value":
              _state = STATE.ARRAY_VALUE;
              break;
            case "begin-object":
              _stack.addFirst(token.type);
              _state = STATE.ENTERED_OBJECT;
              break;
            case "begin-array":
              _stack.addFirst(token.type);
              _state = STATE.ENTERED_ARRAY;
              break;
            default:
              throwError(token);
          }
          break;
        case STATE.EXITED_OBJECT:
          switch(token.type) {
            case "eof":
              _state = STATE.EOF;
              break;
            case "end-array":
              if (_stack.isEmpty) {
                throwError(token);
              }
              _stack.removeFirst();
              _state = STATE.EXITED_ARRAY;
              break;
            case "value-separator":
              _state = STATE.ARRAY_VALUE_SEPARATOR;
              break;
            case "end-object":
              _stack.removeFirst();
              _state = STATE.EXITED_OBJECT;
              break;
            default:
              throwError(token);
          }
          break;
        case STATE.EXITED_ARRAY:
          switch(token.type) {
            case "eof":
              _state = STATE.EOF;
              break;
            case "end-array":
              _stack.removeFirst();
              _state = STATE.EXITED_ARRAY;
              break;
            case "value-separator":
              if (_stack.first == "begin-array") {
                _state = STATE.ARRAY_VALUE_SEPARATOR;
              } else if (_stack.first == "begin-object"){
                _state = STATE.OBJECT_VALUE_SEPARATOR;
              }
              break;
            case "end-object":
              _stack.removeFirst();
              _state = STATE.EXITED_OBJECT;
              break;
            default:
              throwError(token);
          }
          break;
        default:
          throwError(token);
          break;
      }
      if (_state == STATE.EOF) {
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