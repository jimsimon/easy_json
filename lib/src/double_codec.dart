part of json_tokenizer;

class DoubleCodec extends Codec<double, String> {

  const DoubleCodec();

  @override
  Converter<String, double> get decoder => const _DoubleDecoder();

  @override
  Converter<double, String> get encoder => const _DoubleEncoder();
}

class _DoubleDecoder extends Converter<String, double> {

  const _DoubleDecoder();

  @override
  double convert(String input) => double.parse(input);
}

class _DoubleEncoder extends Converter<double, String> {

  const _DoubleEncoder();

  @override
  String convert(double input) => input.toString();
}