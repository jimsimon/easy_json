part of json_tokenizer;

class JsonValidator {

  isValid(String json) {
    String _state = "init";
    Queue<String> _stack = new Queue();
    Queue<Token> _tokens = new JsonTokenizer(json)._tokens;

    while (_tokens.isNotEmpty) {
      Token token = _tokens.removeFirst();
      switch(_state) {
        case "init":
          switch(token.type) {
            case "begin-object":
              _stack.addFirst(token.type);
              _state = "entered-object";
              break;
            case "begin-array":
              _stack.addFirst(token.type);
              _state = "entered-array";
              break;
            case "value":
              _state = "top-level-value";
              break;
            default:
              throwError(token);
          }
          break;
        case "top-level-value":
          switch(token.type) {
            case "eof":
              _state = "eof";
              break;
            default:
              throwError(token);
          }
          break;
        case "entered-object":
          switch(token.type) {
            case "end-object":
              _stack.removeFirst();
              _state = "exited-object";
              break;
            case "value":
              //TODO only allow strings
              _state = "object-key";
              break;
            default:
              throwError(token);
          }
          break;
        case "object-key":
          switch(token.type) {
            case "name-separator":
              _state = "object-name-separator";
              break;
            default:
              throwError(token);
          }
          break;
        case "object-name-separator":
          switch(token.type) {
            case "value":
              _state = "object-value";
              break;
            case "begin-array":
              _stack.addFirst(token.type);
              _state = "entered-array";
              break;
            case "begin-object":
              _stack.addFirst(token.type);
              _state = "entered-object";
              break;
            default:
              throwError(token);
          }
          break;
        case "object-value":
          switch(token.type) {
            case "end-object":
              _stack.removeFirst();
              _state = "exited-object";
              break;
            case "value-separator":
              _state = "object-value-separator";
              break;
            default:
              throwError(token);
          }
          break;
        case "object-value-separator":
          switch(token.type) {
            case "value":
              _state = "object-key";
              break;
            default:
              throwError(token);
          }
          break;
        case "entered-array":
          switch(token.type) {
            case "begin-array":
              _stack.addFirst(token.type);
              _state = "entered-array";
              break;
            case "end-array":
              _stack.removeFirst();
              _state = "exited-array";
              break;
            case "value":
              _state = "array-value";
              break;
            case "begin-object":
              _stack.addFirst(token.type);
              _state = "entered-object";
              break;
            default:
              throwError(token);
          }
          break;
        case "array-value":
          switch(token.type) {
            case "end-array":
              _stack.removeFirst();
              _state = "exited-array";
              break;
            case "value-separator":
              _state = "array-value-separator";
              break;
            default:
              throwError(token);
          }
          break;
        case "array-value-separator":
          switch(token.type) {
            case "value":
              _state = "array-value";
              break;
            case "begin-object":
              _stack.addFirst(token.type);
              _state = "entered-object";
              break;
            case "begin-array":
              _stack.addFirst(token.type);
              _state = "entered-array";
              break;
            default:
              throwError(token);
          }
          break;
        case "exited-object":
          switch(token.type) {
            case "eof":
              _state = "eof";
              break;
            case "end-array":
              if (_stack.isEmpty) {
                throwError(token);
              }
              _stack.removeFirst();
              _state = "exited-array";
              break;
            case "value-separator":
              _state = "array-value-separator";
              break;
            case "end-object":
              _stack.removeFirst();
              _state = "exited-object";
              break;
            default:
              throwError(token);
          }
          break;
        case "exited-array":
          switch(token.type) {
            case "eof":
              _state = "eof";
              break;
            case "end-array":
              _stack.removeFirst();
              _state = "exited-array";
              break;
            case "value-separator":
              if (_stack.isEmpty) {
                throwError(token);
              }
              if (_stack.first == "begin-array") {
                _state = "array-value-separator";
              } else if (_stack.first == "begin-object"){
                _state = "object-value-separator";
              }
              break;
            case "end-object":
              _stack.removeFirst();
              _state = "exited-object";
              break;
            default:
              throwError(token);
          }
          break;
        default:
          throwError(token);
          break;
      }
      if (_state == "eof") {
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