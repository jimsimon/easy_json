library easy_json;

@MirrorsUsed(targets: const [int, double, bool, String, num, List, Map, Set, Object], metaTargets: const [_Serializable])
import "dart:mirrors";
import "dart:convert";
import "dart:collection";

import "package:json_lexer/json_lexer.dart";
export "package:json_lexer/json_lexer.dart" show LexerException;

part "json_consumer.dart";
part "json_parser.dart";
part "type_token.dart";
part "serializable.dart";
part "src/int_codec.dart";
part "src/double_codec.dart";
part "src/bool_codec.dart";
part "src/string_codec.dart";
part "src/default_codec.dart";
part "src/list_codec.dart";