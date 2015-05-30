part of json_tokenizer;

//TODO Do we need this?  DefaultCodec seems to handle it for us.
class ListCodec extends Codec<List, String> {

  const ListCodec();

  @override
  Converter<String, List> get decoder => const _ListDecoder();

  @override
  Converter<List, String> get encoder => const _ListEncoder();
}

class _ListDecoder extends Converter<String, List> {

  const _ListDecoder();

  @override
  List convert(String input) => new List();
}

class _ListEncoder extends Converter<List, String> {

  const _ListEncoder();

  @override
  String convert(List input) => input.toString();
}