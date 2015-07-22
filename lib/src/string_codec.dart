part of easy_json;

class StringCodec extends Codec<String, String> {

  const StringCodec();

  @override
  Converter<String, String> get decoder => const _StringDecoder();

  @override
  Converter<String, String> get encoder => const _StringEncoder();
}

class _StringDecoder extends Converter<String, String> {

  const _StringDecoder();

  @override
  String convert(String input) => input;
}

class _StringEncoder extends Converter<String, String> {

  const _StringEncoder();

  @override
  String convert(String input) => input;
}