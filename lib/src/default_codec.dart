part of easy_json;

class DefaultCodec<T> extends Codec<T, String> {

  final TypeMirror tm;
  const DefaultCodec(TypeMirror this.tm);

  @override
  Converter<String, dynamic> get decoder => new _DefaultDecoder(tm);

  @override
  Converter<dynamic, String> get encoder => const _DefaultEncoder();
}

class _DefaultDecoder extends Converter<String, dynamic> {

  final TypeMirror tm;
  _DefaultDecoder(TypeMirror this.tm);

  @override
  dynamic convert(String input){
    return (tm as ClassMirror).newInstance(const Symbol(""), []).reflectee;
  }

}

class _DefaultEncoder extends Converter<dynamic, String> {

  const _DefaultEncoder();

  @override
  String convert(dynamic input) => input.toString();
}