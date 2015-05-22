part of json_tokenizer;

class JsonValidator {
  Queue<Token> _tokens;
  String state = "init";
  Queue<String> containerStack = new Queue();

  JsonValidator._fromTokens(Queue<Token> this._tokens);

  JsonValidator(String json) {
    _tokens = new JsonTokenizer(json)._tokens;
  }

  Token _getNextToken() {
    if (_tokens.isEmpty) {
      return new Token()..type="eof";
    }
    return _tokens.removeFirst();
  }

  isValid() {
    while (true) {
      Token token = _getNextToken();
      switch(state) {
        case "init":
          switch(token.type) {
            case "begin-object":
              containerStack.addFirst(token.type);
              state = "entered-object";
              break;
            case "begin-array":
              containerStack.addFirst(token.type);
              state = "entered-array";
              break;
            case "value":
              state = "top-level-value";
              break;
            default:
              throwError(token);
          }
          break;
        case "top-level-value":
          switch(token.type) {
            case "eof":
              state = "eof";
              break;
            default:
              throwError(token);
          }
          break;
        case "entered-object":
          switch(token.type) {
            case "end-object":
              containerStack.removeFirst();
              state = "exited-object";
              break;
            case "value":
              //TODO only allow strings
              state = "object-key";
              break;
            default:
              throwError(token);
          }
          break;
        case "object-key":
          switch(token.type) {
            case "name-separator":
              state = "object-name-separator";
              break;
            default:
              throwError(token);
          }
          break;
        case "object-name-separator":
          switch(token.type) {
            case "value":
              state = "object-value";
              break;
            case "begin-array":
              containerStack.addFirst(token.type);
              state = "entered-array";
              break;
            case "begin-object":
              containerStack.addFirst(token.type);
              state = "entered-object";
              break;
            default:
              throwError(token);
          }
          break;
        case "object-value":
          switch(token.type) {
            case "end-object":
              containerStack.removeFirst();
              state = "exited-object";
              break;
            case "value-separator":
              state = "object-value-separator";
              break;
            default:
              throwError(token);
          }
          break;
        case "object-value-separator":
          switch(token.type) {
            case "value":
              state = "object-key";
              break;
            default:
              throwError(token);
          }
          break;
        case "entered-array":
          switch(token.type) {
            case "begin-array":
              containerStack.addFirst(token.type);
              state = "entered-array";
              break;
            case "end-array":
              containerStack.removeFirst();
              state = "exited-array";
              break;
            case "value":
              state = "array-value";
              break;
            case "begin-object":
              containerStack.addFirst(token.type);
              state = "entered-object";
              break;
            default:
              throwError(token);
          }
          break;
        case "array-value":
          switch(token.type) {
            case "end-array":
              containerStack.removeFirst();
              state = "exited-array";
              break;
            case "value-separator":
              state = "array-value-separator";
              break;
            default:
              throwError(token);
          }
          break;
        case "array-value-separator":
          switch(token.type) {
            case "value":
              state = "array-value";
              break;
            case "begin-object":
              containerStack.addFirst(token.type);
              state = "entered-object";
              break;
            case "begin-array":
              containerStack.addFirst(token.type);
              state = "entered-array";
              break;
            default:
              throwError(token);
          }
          break;
        case "exited-object":
          switch(token.type) {
            case "eof":
              state = "eof";
              break;
            case "end-array":
              if (containerStack.isEmpty) {
                throwError(token);
              }
              containerStack.removeFirst();
              state = "exited-array";
              break;
            case "value-separator":
              state = "array-value-separator";
              break;
            case "end-object":
              containerStack.removeFirst();
              state = "exited-object";
              break;
            default:
              throwError(token);
          }
          break;
        case "exited-array":
          switch(token.type) {
            case "eof":
              state = "eof";
              break;
            case "end-array":
              containerStack.removeFirst();
              state = "exited-array";
              break;
            case "value-separator":
              if (containerStack.isEmpty) {
                throwError(token);
              }
              if (containerStack.first == "begin-array") {
                state = "array-value-separator";
              } else if (containerStack.first == "begin-object"){
                state = "object-value-separator";
              }
              break;
            case "end-object":
              containerStack.removeFirst();
              state = "exited-object";
              break;
            default:
              throwError(token);
          }
          break;
        case "eof":
          if (containerStack.isNotEmpty) {
            throw new ArgumentError("Unexpected end of input");
          }
          return true;
        default:
          throwError(token);
          break;
      }
    }
  }
}

void throwError(Token token) {
  throw new ArgumentError("Unexpected token: ${token.value}");
}