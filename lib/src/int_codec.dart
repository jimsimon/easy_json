part of easy_json;

class IntCodec extends Codec<int, String> {

  const IntCodec();

  @override
  Converter<String, int> get decoder => const _IntDecoder();

  @override
  Converter<int, String> get encoder => const _IntEncoder();
}

class _IntDecoder extends Converter<String, int> {

  const _IntDecoder();

  @override
  int convert(String input) => int.parse(input);
}

class _IntEncoder extends Converter<int, String> {

  const _IntEncoder();

  @override
  String convert(int input) => input.toString();
}