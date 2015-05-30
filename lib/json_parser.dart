part of json_tokenizer;

enum STATE {
  INIT,
  FINISHED_VALUE,
  IN_OBJECT,
  IN_ARRAY,
  FINISHED_OBJECT_ENTRY,
  FINISHED_ARRAY_ENTRY,
  EOF
}

class TypeToken<T> {
  Type get type => reflectType(T).reflectedType;
}

class JsonParser {

  Map<String, Codec> _codecs = new HashMap();

  Map<String, Codec> _loadBasicCodecs() {
    return {
      reflectType(int).qualifiedName: const IntCodec(),
      reflectType(double).qualifiedName: const DoubleCodec(),
      reflectType(bool).qualifiedName: const BoolCodec(),
      reflectType(String).qualifiedName: const StringCodec()
    };
  }

  JsonParser() {
    _codecs = _loadBasicCodecs();
  }

  parse(String json, Type t) {
    TypeMirror typeMirror = reflectType(t);
    STATE _state = STATE.INIT;

    Queue<String> _statusStack = new Queue();
    Queue _valueStack = new Queue();

    Queue<Token> _tokens = new JsonTokenizer(json).tokens;

    while (_tokens.isNotEmpty) {
      Token token = _tokens.removeFirst();

//      if (_tokens.length == 1 && token.type == "value-separator") {
//        throwError(token);
//      }

      switch(_state) {
        case STATE.INIT:
          switch(token.type) {
            case "value":
              _state = STATE.FINISHED_VALUE;
              var value = _codecs[typeMirror.qualifiedName].decode(token.value);
              _valueStack.addFirst(value);
              break;
            case "begin-object":
              var codec = _codecs[typeMirror.qualifiedName];
              if (codec == null) {
                codec = new DefaultCodec(typeMirror);
              }
              var value = codec.decode(token.value);
              _valueStack.addFirst(value);
              _state = STATE.IN_OBJECT;
              break;
            case "begin-array":
              var codec = _codecs[typeMirror.qualifiedName];
              if (codec == null) {
                codec = new DefaultCodec(typeMirror);
              }
              var value = codec.decode(token.value);
              _valueStack.addFirst(value);
              _state = STATE.IN_ARRAY;
              break;
            default:
              throwError(token);
          }
          break;
        case STATE.FINISHED_VALUE:
          switch(token.type) {
            case "eof":
              _state = STATE.EOF;
              break;
            default:
              throwError(token);
          }
          break;
        case STATE.IN_OBJECT:
          switch(token.type) {
            case "value":
              //TODO verify value is a String
              _tokens.removeFirst(); //TODO verify name-separator
              var valueToSet = _tokens.removeFirst().value;
              //TODO check for nested objects

              InstanceMirror im = reflect(_valueStack.first);

              Symbol symbol = new Symbol(token.value + "=");
              MethodMirror setter = im.type.instanceMembers[symbol];
              var codec = _codecs[setter.parameters.first.type.qualifiedName];
              //TODO check if codec is null
              var value = codec.decode(valueToSet);
              im.setField(new Symbol(token.value), value);

              _state = STATE.FINISHED_OBJECT_ENTRY;
              break;
            case "end-object":
              if(_valueStack.length > 1) {
                _valueStack.removeFirst();
                if (_valueStack.first is Iterable) {
                  _state = STATE.FINISHED_ARRAY_ENTRY;
                }
                //TODO handle else
              } else {
                _state = STATE.FINISHED_VALUE;
              }
              break;
            default:
              throwError(token);
          }
          break;
        case STATE.FINISHED_OBJECT_ENTRY:
          switch(token.type) {
            case "end-object":
              if(_valueStack.length > 1) {
                _valueStack.removeFirst();
                if (_valueStack.first is Iterable) {
                  _state = STATE.FINISHED_ARRAY_ENTRY;
                }
                //TODO handle else
              } else {
                _state = STATE.FINISHED_VALUE;
              }
              break;
            case "value-separator":
              _state = STATE.IN_OBJECT;
              break;
            default:
              throwError(token);
          }
          break;
        case STATE.IN_ARRAY:
          switch(token.type) {
            case "value":
              var value = _codecs[typeMirror.typeArguments.first.qualifiedName].decode(token.value);
              _valueStack.first.add(value);
              _state = STATE.FINISHED_ARRAY_ENTRY;
              break;
            case "begin-object":
              var codec = _codecs[typeMirror.typeArguments.first.qualifiedName];
              if (codec == null) {
                codec = new DefaultCodec(typeMirror.typeArguments.first);
              }
              var value = codec.decode(token.value);
              _valueStack.first.add(value);
              _valueStack.addFirst(value);
              _state = STATE.IN_OBJECT;
              break;
            case "end-array":
              _state = STATE.FINISHED_VALUE;
              break;
            default:
              throwError(token);
          }
          break;
        case STATE.FINISHED_ARRAY_ENTRY:
          switch(token.type) {
            case "value-separator":
              _state = STATE.IN_ARRAY;
              break;
//            case "begin-object":
//              _state = STATE.IN_OBJECT;
//              break;
            case "end-array":
              _state = STATE.FINISHED_VALUE;
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
        if (_statusStack.isNotEmpty) {
          throwError(token);
        }
        return _valueStack.removeFirst();
      }
    }
  }
}

void throwError(Token token) {
  throw new ArgumentError("Unexpected token: ${token.value}");
}