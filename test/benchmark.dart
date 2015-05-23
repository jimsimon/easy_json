import "package:json_tokenizer/json_tokenizer.dart";

b2() {
  DateTime start = new DateTime.now();
  JsonValidator2 validator2 = new JsonValidator2();
  for (int i = 0; i < 10000; i++) {
    benchmark(validator2);
  }
  DateTime end = new DateTime.now();
  print("JsonValidator2 Time: ${end.difference(start).inMilliseconds}");
}

B1() {
  DateTime start = new DateTime.now();
  JsonValidator validator = new JsonValidator();
  for (int i = 0; i < 10000; i++) {
    benchmark(validator);
  }
  DateTime end = new DateTime.now();
  print("JsonValidator Time: ${end.difference(start).inMilliseconds}");
}

main() {
  B1();
  b2();
}

benchmark(validator) {
  validator.isValid("1");
  validator.isValid("1.1");
  validator.isValid('"hello"');
  validator.isValid("true");
  validator.isValid("false");
  validator.isValid("{}");
  validator.isValid('{"hello": "value"}');
  validator.isValid('{"hello": "value", "world": "value2", "!": "value3"}');
  validator.isValid('[]');
  validator.isValid('["hello"]');
  validator.isValid('["hello", "world", "!"]');
  validator.isValid('[{}]');
  validator.isValid('[{},{}]');
  validator.isValid('[{"hello":"world"}]');
  validator.isValid('[{"hello":"world"},{"alas":"goodbye"}]');
  validator.isValid('[{"hello":"world"},123,"goodbye",true]');
  validator.isValid('[[],[]]');
  validator.isValid('{"array":[]}');
  validator.isValid('{"array":["hello"]}');
  validator.isValid('{"array":["hello","world"]}');
  validator.isValid('{"array":["hello","world",123,true,1.1]}');
  validator.isValid('{"array":["hello","world",123,true,1.1], "good": null, "this": 123, "works": [9]}');
  validator.isValid('{"array":{}}');
}