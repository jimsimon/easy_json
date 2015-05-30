part of json_tokenizer;

enum STATE {
  INIT,
  FINISHED_VALUE,
  IN_OBJECT,
  IN_ARRAY,
  FINISHED_OBJECT_ENTRY,
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
    STATE state = STATE.INIT;

    Queue<String> statusStack = new Queue();
    Queue valueStack = new Queue();
    Queue<TypeMirror> typeMirrorStack = new Queue();
    typeMirrorStack.addFirst(reflectType(t));

    Queue<Token> tokens = new JsonTokenizer(json).tokens;

    while (tokens.isNotEmpty) {
      Token token = tokens.removeFirst();

//      if (_tokens.length == 1 && token.type == "value-separator") {
//        throwError(token);
//      }

      switch(state) {
        case STATE.INIT:
          TypeMirror typeMirror = typeMirrorStack.first;
          switch(token.type) {
            case "value":
              state = STATE.FINISHED_VALUE;
              var value = _codecs[typeMirror.qualifiedName].decode(token.value);
              valueStack.addFirst(value);
              break;
            case "begin-object":
              var codec = _codecs[typeMirror.qualifiedName];
              if (codec == null) {
                codec = new DefaultCodec(typeMirror);
              }
              var value = codec.decode(token.value);
              valueStack.addFirst(value);
              state = STATE.IN_OBJECT;
              break;
            case "begin-array":
              var codec = _codecs[typeMirror.qualifiedName];
              if (codec == null) {
                codec = new DefaultCodec(typeMirror);
              }
              var value = codec.decode(token.value);
              valueStack.addFirst(value);
              state = STATE.IN_ARRAY;
              break;
            default:
              throwError(token);
          }
          break;
        case STATE.FINISHED_VALUE:
          switch(token.type) {
            case "eof":
              state = STATE.EOF;
              break;
            default:
              throwError(token);
          }
          break;
        case STATE.IN_OBJECT:
          switch(token.type) {
            case "value":
              //TODO verify value is a String
              tokens.removeFirst(); //TODO verify name-separator
              var valueToken = tokens.removeFirst();
              var valueToSet = valueToken.value;
              InstanceMirror im = reflect(valueStack.first);
              Symbol symbol = new Symbol(token.value + "=");
              MethodMirror setter = im.type.instanceMembers[symbol];
              TypeMirror valueTypeMirror = setter.parameters.first.type;
              var codec = _codecs[valueTypeMirror.qualifiedName];
              if (codec == null) {
                codec = new DefaultCodec(setter.parameters.first.type);
              }
              var value = codec.decode(valueToSet);
              im.setField(new Symbol(token.value), value);

              //TODO check for nested objects
              if (valueToken.type == "value") {
                state = STATE.FINISHED_OBJECT_ENTRY;
              } else if (valueToken.type == "begin-array") {
                typeMirrorStack.addFirst(valueTypeMirror);
                valueStack.addFirst(value);
                state = STATE.IN_ARRAY;
              }
              break;
            case "end-object":
              if(valueStack.length > 1) {
                valueStack.removeFirst();
                if (valueStack.first is Iterable) {
                  state = STATE.IN_ARRAY;
                }
                //TODO handle else
              } else {
                state = STATE.FINISHED_VALUE;
              }
              break;
            default:
              throwError(token);
          }
          break;
        case STATE.FINISHED_OBJECT_ENTRY:
          switch(token.type) {
            case "end-object":
              if(valueStack.length > 1) {
                valueStack.removeFirst();
                if (valueStack.first is Iterable) {
                  state = STATE.IN_ARRAY;
                }
                //TODO handle else
              } else {
                state = STATE.FINISHED_VALUE;
              }
              break;
            case "value-separator":
              state = STATE.IN_OBJECT;
              break;
            default:
              throwError(token);
          }
          break;
        case STATE.IN_ARRAY:
          TypeMirror typeMirror = typeMirrorStack.first;
          switch(token.type) {
            case "value-separator":
              state = STATE.IN_ARRAY;
              break;
            case "value":
              var value = _codecs[typeMirror.typeArguments.first.qualifiedName].decode(token.value);
              valueStack.first.add(value);
              state = STATE.IN_ARRAY;
              break;
            case "begin-object":
              var codec = _codecs[typeMirror.typeArguments.first.qualifiedName];
              if (codec == null) {
                codec = new DefaultCodec(typeMirror.typeArguments.first);
              }
              var value = codec.decode(token.value);
              valueStack.first.add(value);
              valueStack.addFirst(value);
              state = STATE.IN_OBJECT;
              break;
            case "begin-array":
              var valueTypeMirror = typeMirror.typeArguments.first;
              var codec = _codecs[valueTypeMirror.qualifiedName];
              if (codec == null) {
                codec = new DefaultCodec(valueTypeMirror);
              }
              var value = codec.decode(token.value);
              valueStack.first.add(value);
              valueStack.addFirst(value);
              typeMirrorStack.addFirst(valueTypeMirror);
              break;
            case "end-array":
              if(valueStack.length > 1) {
                valueStack.removeFirst();
                typeMirrorStack.removeFirst();
                if (valueStack.first is Iterable) {
                  state = STATE.IN_ARRAY;
                } else {
                  state = STATE.FINISHED_OBJECT_ENTRY;
                }
                //TODO handle else
              } else {
                state = STATE.FINISHED_VALUE;
              }
              break;
            default:
              throwError(token);
          }
          break;
        default:
          throwError(token);
          break;
      }
      if (state == STATE.EOF) {
        if (statusStack.isNotEmpty) {
          throwError(token);
        }
        return valueStack.removeFirst();
      }
    }
  }
}

void throwError(Token token) {
  throw new ArgumentError("Unexpected token: ${token.value}");
}