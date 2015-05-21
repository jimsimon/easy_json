library json_parser.test;

import 'package:test/test.dart';

import 'package:json_tokenizer/json_tokenizer.dart';

main() {
  group("positive tests", () {
    test("allows top level integers", () {
      JsonValidator validator = new JsonValidator("1");
      expect(validator.isValid(), isTrue);
    });

    test("allows top level doubles", () {
      JsonValidator validator = new JsonValidator("1.1");
      expect(validator.isValid(), isTrue);
    });

    test("allows top level strings", () {
      JsonValidator validator = new JsonValidator('"hello"');
      expect(validator.isValid(), isTrue);
    });

    test("allows top level true", () {
      JsonValidator validator = new JsonValidator("true");
      expect(validator.isValid(), isTrue);
    });

    test("allows top level false", () {
      JsonValidator validator = new JsonValidator("false");
      expect(validator.isValid(), isTrue);
    });

    test("allows empty objects", () {
      JsonValidator validator = new JsonValidator("{}");
      expect(validator.isValid(), isTrue);
    });

    test("allows object with single key-value pair", () {
      JsonValidator validator = new JsonValidator('{"hello": "value"}');
      expect(validator.isValid(), isTrue);
    });

    test("allows object with multiple key-value pairs", () {
      JsonValidator validator = new JsonValidator('{"hello": "value", "world": "value2", "!": "value3"}');
      expect(validator.isValid(), isTrue);
    });

    test("allows empty arrays", () {
      JsonValidator validator = new JsonValidator('[]');
      expect(validator.isValid(), isTrue);
    });

    test("allows arrays with a single value", () {
      JsonValidator validator = new JsonValidator('["hello"]');
      expect(validator.isValid(), isTrue);
    });

    test("allows arrays with a multiple values", () {
      JsonValidator validator = new JsonValidator('["hello", "world", "!"]');
      expect(validator.isValid(), isTrue);
    });

    test("handles arrays with a single empty object", () {
      JsonValidator validator = new JsonValidator('[{}]');
      expect(validator.isValid(), isTrue);
    });

    test("handles arrays with multiple empty objects", () {
      JsonValidator validator = new JsonValidator('[{},{}]');
      expect(validator.isValid(), isTrue);
    });

    test("handles arrays with single non-empty objects", () {
      JsonValidator validator = new JsonValidator('[{"hello":"world"}]');
      expect(validator.isValid(), isTrue);
    });

    test("handles arrays with multiple non-empty objects", () {
      JsonValidator validator = new JsonValidator('[{"hello":"world"},{"alas":"goodbye"}]');
      expect(validator.isValid(), isTrue);
    });

    test("handles arrays with mixed elements", () {
      JsonValidator validator = new JsonValidator('[{"hello":"world"},123,"goodbye",true]');
      expect(validator.isValid(), isTrue);
    });

    test("handles objects with property value of empty array", () {
      JsonValidator validator = new JsonValidator('{"array":[]}');
      expect(validator.isValid(), isTrue);
    });

    test("handles objects with property value of array with single item", () {
      JsonValidator validator = new JsonValidator('{"array":["hello"]}');
      expect(validator.isValid(), isTrue);
    });

    test("handles objects with property value of array with multiple items", () {
      JsonValidator validator = new JsonValidator('{"array":["hello","world"]}');
      expect(validator.isValid(), isTrue);
    });

    test("handles objects with property value of array with multiple mixed items", () {
      JsonValidator validator = new JsonValidator('{"array":["hello","world",123,true,1.1]}');
      expect(validator.isValid(), isTrue);
    });

    test("handles objects with multiple mixed property values with multiple mixed items", () {
      JsonValidator validator = new JsonValidator('{"array":["hello","world",123,true,1.1], "good": null, "this": 123, "works": [9]}');
      expect(validator.isValid(), isTrue);
    });

    test("handles objects with property value of empty object", () {
      JsonValidator validator = new JsonValidator('{"array":{}}');
      expect(validator.isValid(), isTrue);
    });
  });

  group("negative tests", (){

  });
}