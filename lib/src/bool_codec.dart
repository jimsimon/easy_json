part of easy_json;

class BoolCodec extends Codec<bool, String> {

  const BoolCodec();

  @override
  Converter<String, bool> get decoder => const _BoolDecoder();

  @override
  Converter<bool, String> get encoder => const _BoolEncoder();
}

class _BoolDecoder extends Converter<String, bool> {

  const _BoolDecoder();

  @override
  bool convert(String input) => input == "true" ? true : false;
}

class _BoolEncoder extends Converter<bool, String> {

  const _BoolEncoder();

  @override
  String convert(bool input) => input.toString();
}