part of json_tokenizer;

enum STATE {
  INIT,
  FINISHED_VALUE,
  IN_OBJECT,
  IN_ARRAY,
  EOF
}

class TypeToken<T> {
  Type get type => reflectType(T).reflectedType;
}

class JsonParser {

  Map<Symbol, Codec> _codecs = new HashMap();

  Map<Symbol, Codec> _loadBasicCodecs() {
    return {
      reflectType(int).qualifiedName: const IntCodec(),
      reflectType(double).qualifiedName: const DoubleCodec(),
      reflectType(bool).qualifiedName: const BoolCodec(),
      reflectType(String).qualifiedName: const StringCodec()
    };
  }

  JsonParser() {
    _codecs.addAll(_loadBasicCodecs());
  }

  convertValueToType(String value, TypeMirror typeMirror) {
    if (value == "null") {
      return null;
    }

    var codec = _codecs[typeMirror.qualifiedName];
    if (codec == null) {
      codec = new DefaultCodec(typeMirror);
    }
    return codec.decode(value);
  }

  addCodecForType(Type type, Codec codec) {
    addCodecForSymbol(reflectType(type).qualifiedName, codec);
  }

  addCodecForSymbol(Symbol qualifiedName, Codec codec) {
    _codecs[qualifiedName] = codec;
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
              var value = convertValueToType(token.value, typeMirror);
              valueStack.addFirst(value);
              break;
            case "begin-object":
              var value = convertValueToType(token.value, typeMirror);
              valueStack.addFirst(value);
              state = STATE.IN_OBJECT;
              break;
            case "begin-array":
              var value = convertValueToType(token.value, typeMirror);
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
            case "value-separator":
              state = STATE.IN_OBJECT;
              break;
            case "value":
              //TODO verify value is a String
              tokens.removeFirst(); //TODO verify name-separator
              var valueToken = tokens.removeFirst();
              var valueToSet = valueToken.value;
              InstanceMirror im = reflect(valueStack.first);
              Symbol symbol = new Symbol(token.value + "=");
              MethodMirror setter = im.type.instanceMembers[symbol];
              TypeMirror valueTypeMirror = setter.parameters.first.type;
              var value = convertValueToType(valueToSet, valueTypeMirror);
              im.setField(new Symbol(token.value), value);

              if (valueToken.type == "begin-array") {
                typeMirrorStack.addFirst(valueTypeMirror);
                valueStack.addFirst(value);
                state = STATE.IN_ARRAY;
              } else if (valueToken.type == "begin-object") {
                typeMirrorStack.addFirst(valueTypeMirror);
                valueStack.addFirst(value);
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
        case STATE.IN_ARRAY:
          TypeMirror typeMirror = typeMirrorStack.first;
          switch(token.type) {
            case "value-separator":
              state = STATE.IN_ARRAY;
              break;
            case "value":
              var value = convertValueToType(token.value, typeMirror.typeArguments.first);
              valueStack.first.add(value);
              state = STATE.IN_ARRAY;
              break;
            case "begin-object":
              var value = convertValueToType(token.value, typeMirror.typeArguments.first);
              valueStack.first.add(value);
              valueStack.addFirst(value);
              state = STATE.IN_OBJECT;
              break;
            case "begin-array":
              var value = convertValueToType(token.value, typeMirror.typeArguments.first);
              valueStack.first.add(value);
              valueStack.addFirst(value);
              typeMirrorStack.addFirst(typeMirror.typeArguments.first);
              break;
            case "end-array":
              if(valueStack.length > 1) {
                valueStack.removeFirst();
                typeMirrorStack.removeFirst();
                if (valueStack.first is Iterable) {
                  state = STATE.IN_ARRAY;
                } else {
                  state = STATE.IN_OBJECT;
                }
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