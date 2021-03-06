part of easy_json;

enum _STATE {
  INIT,
  FINISHED_VALUE,
  IN_OBJECT,
  IN_ARRAY,
  EOF
}

class JsonParser {

  Map<Symbol, Codec> _codecs = new HashMap();

  Map<Symbol, Codec> _loadBasicCodecs() {
    return {
      reflectType(int).qualifiedName: const IntCodec(),
      reflectType(double).qualifiedName: const DoubleCodec(),
      reflectType(bool).qualifiedName: const BoolCodec(),
      reflectType(String).qualifiedName: const StringCodec(),
      reflectType(List).qualifiedName: const ListCodec()
    };
  }

  JsonParser() {
    _codecs.addAll(_loadBasicCodecs());
  }

  addCodecForType(Type type, Codec codec) {
    addCodecForSymbol(reflectType(type).qualifiedName, codec);
  }

  addCodecForSymbol(Symbol qualifiedName, Codec codec) {
    _codecs[qualifiedName] = codec;
  }

  parse(String json, Type t) {
    _STATE state = _STATE.INIT;

    Queue<String> statusStack = new Queue();
    Queue valueStack = new Queue();
    Queue<TypeMirror> typeMirrorStack = new Queue();
    typeMirrorStack.addFirst(reflectType(t));

    Queue<Token> tokens = new JsonLexer(json).tokens;

    while (tokens.isNotEmpty) {
      Token token = tokens.removeFirst();

      switch(state) {
        case _STATE.INIT:
          TypeMirror typeMirror = typeMirrorStack.first;
          switch(token.type) {
            case TokenType.VALUE:
              state = _STATE.FINISHED_VALUE;
              var value = _convertTokenToType(token, typeMirror);
              valueStack.addFirst(value);
              break;
            case TokenType.BEGIN_OBJECT:
              var value = _convertTokenToType(token, typeMirror);
              valueStack.addFirst(value);
              state = _STATE.IN_OBJECT;
              break;
            case TokenType.BEGIN_ARRAY:
              var value = _convertTokenToType(token, typeMirror);
              valueStack.addFirst(value);
              state = _STATE.IN_ARRAY;
              break;
            default:
              _throwError(token);
          }
          break;
        case _STATE.FINISHED_VALUE:
          switch(token.type) {
            case TokenType.EOF:
              state = _STATE.EOF;
              break;
            default:
              _throwError(token);
          }
          break;
        case _STATE.IN_OBJECT:
          switch(token.type) {
            case TokenType.VALUE_SEPARATOR:
              state = _STATE.IN_OBJECT;
              break;
            case TokenType.VALUE:
              tokens.removeFirst(); //Account for name-separator token
              var valueToken = tokens.removeFirst();
              InstanceMirror im = reflect(valueStack.first);
              TypeMirror valueTypeMirror;
              var value;
              if (valueStack.first is Map) {
                //TODO Make sure first type argument is String
                var keyTypeMirror = im.type.typeArguments[0];
                if (keyTypeMirror.qualifiedName != reflectType(String).qualifiedName) {
                  throw new ArgumentError("Invalid map key type of ${keyTypeMirror.qualifiedName}.  Map keys must be of type String");
                }
                valueTypeMirror = im.type.typeArguments[1];
                value = _convertTokenToType(valueToken, valueTypeMirror);
                valueStack.first[token.value] = value;
              } else {
                Symbol symbol = new Symbol(token.value + "=");
                MethodMirror setter = im.type.instanceMembers[symbol];
                valueTypeMirror = setter.parameters.first.type;
                value = _convertTokenToType(valueToken, valueTypeMirror);
                im.setField(new Symbol(token.value), value);
              }

              if (valueToken.type == TokenType.BEGIN_ARRAY) {
                typeMirrorStack.addFirst(valueTypeMirror);
                valueStack.addFirst(value);
                state = _STATE.IN_ARRAY;
              } else if (valueToken.type == TokenType.BEGIN_OBJECT) {
                typeMirrorStack.addFirst(valueTypeMirror);
                valueStack.addFirst(value);
              }
              break;
            case TokenType.END_OBJECT:
              if(valueStack.length > 1) {
                valueStack.removeFirst();
                if (valueStack.first is Iterable) {
                  state = _STATE.IN_ARRAY;
                }
              } else {
                state = _STATE.FINISHED_VALUE;
              }
              break;
            default:
              _throwError(token);
          }
          break;
        case _STATE.IN_ARRAY:
          TypeMirror typeMirror = typeMirrorStack.first;
          switch(token.type) {
            case TokenType.VALUE_SEPARATOR:
              state = _STATE.IN_ARRAY;
              break;
            case TokenType.VALUE:
              var value = _convertTokenToType(token, typeMirror.typeArguments.first);
              valueStack.first.add(value);
              state = _STATE.IN_ARRAY;
              break;
            case TokenType.BEGIN_OBJECT:
              var value = _convertTokenToType(token, typeMirror.typeArguments.first);
              valueStack.first.add(value);
              valueStack.addFirst(value);
              state = _STATE.IN_OBJECT;
              break;
            case TokenType.BEGIN_ARRAY:
              var value = _convertTokenToType(token, typeMirror.typeArguments.first);
              valueStack.first.add(value);
              valueStack.addFirst(value);
              typeMirrorStack.addFirst(typeMirror.typeArguments.first);
              break;
            case TokenType.END_ARRAY:
              if(valueStack.length > 1) {
                valueStack.removeFirst();
                typeMirrorStack.removeFirst();
                if (valueStack.first is! Iterable) {
                  state = _STATE.IN_OBJECT;
                }
              } else {
                state = _STATE.FINISHED_VALUE;
              }
              break;
            default:
              _throwError(token);
          }
          break;
        default:
          _throwError(token);
          break;
      }
      if (state == _STATE.EOF) {
        if (statusStack.isNotEmpty) {
          _throwError(token);
        }
        return valueStack.removeFirst();
      }
    }
  }

  _convertTokenToType(Token token, TypeMirror typeMirror) {
    if (token.valueType == ValueType.NULL) {
      return null;
    }

    var codec = _codecs[typeMirror.qualifiedName];
    if (codec == null) {
      codec = new DefaultCodec(typeMirror);
    }
    return codec.decode(token.value);
  }

  void _throwError(Token token) {
    throw new ArgumentError("Unexpected token: ${token.value}");
  }
}

