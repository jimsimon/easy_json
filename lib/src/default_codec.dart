part of json_tokenizer;

class DefaultCodec<T> extends Codec<T, String> {

  final TypeMirror tm;
  const DefaultCodec(TypeMirror this.tm);

  @override
  Converter<String, T> get decoder => new _DefaultDecoder<T>(tm);

  @override
  Converter<T, String> get encoder => const _DefaultEncoder<T>();
}

class _DefaultDecoder<T> extends Converter<String, T> {

  final TypeMirror tm;
  _DefaultDecoder(TypeMirror this.tm);

  @override
  T convert(String input){
    return (tm as ClassMirror).newInstance(const Symbol(""), []).reflectee;
  }

}

class _DefaultEncoder<T> extends Converter<T, String> {

  const _DefaultEncoder();

  @override
  String convert(T input) => input.toString();
}