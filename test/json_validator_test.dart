library json_parser.test;

import 'package:test/test.dart';

import 'package:json_tokenizer/json_tokenizer.dart';
import "package:json_tokenizer/json_validator5.dart";

main() async {
  var validator;
  setUp((){
    validator = new JsonValidator();
  });

  group("positive tests", () {
    test("allows top level integers", () {
      expect(validator.isValid("1"), isTrue);
    });

    test("allows top level doubles", () {
      expect(validator.isValid("1.1"), isTrue);
    });

    test("allows top level strings", () {
      expect(validator.isValid('"hello"'), isTrue);
    });

    test("allows top level true", () {
      expect(validator.isValid("true"), isTrue);
    });

    test("allows top level false", () {
      expect(validator.isValid("false"), isTrue);
    });

    test("allows empty objects", () {
      expect(validator.isValid("{}"), isTrue);
    });

    test("allows object with single key-value pair", () {
      expect(validator.isValid('{"hello": "value"}'), isTrue);
    });

    test("allows object with multiple key-value pairs", () {
      expect(validator.isValid('{"hello": "value", "world": "value2", "!": "value3"}'), isTrue);
    });

    test("allows empty arrays", () {
      expect(validator.isValid('[]'), isTrue);
    });

    test("allows arrays with a single value", () {
      expect(validator.isValid('["hello"]'), isTrue);
    });

    test("allows arrays with a multiple values", () {
      expect(validator.isValid('["hello", "world", "!"]'), isTrue);
    });

    test("handles arrays with a single empty object", () {
      expect(validator.isValid('[{}]'), isTrue);
    });

    test("handles arrays with multiple empty objects", () {
      expect(validator.isValid('[{},{}]'), isTrue);
    });

    test("handles arrays with single non-empty objects", () {
      expect(validator.isValid('[{"hello":"world"}]'), isTrue);
    });

    test("handles arrays with multiple non-empty objects", () {
      expect(validator.isValid('[{"hello":"world"},{"alas":"goodbye"}]'), isTrue);
    });

    test("handles arrays with mixed elements", () {
      expect(validator.isValid('[{"hello":"world"},123,"goodbye",true]'), isTrue);
    });

    test("handles arrays within arrays", () {
      expect(validator.isValid('[[],[]]'), isTrue);
    });

    test("handles objects with property value of empty array", () {
      expect(validator.isValid('{"array":[]}'), isTrue);
    });

    test("handles objects with property value of array with single item", () {
      expect(validator.isValid('{"array":["hello"]}'), isTrue);
    });

    test("handles objects with property value of array with multiple items", () {
      expect(validator.isValid('{"array":["hello","world"]}'), isTrue);
    });

    test("handles objects with property value of array with multiple mixed items", () {
      expect(validator.isValid('{"array":["hello","world",123,true,1.1]}'), isTrue);
    });

    test("handles objects with multiple mixed property values with multiple mixed items", () {
      expect(validator.isValid('{"array":["hello","world",123,true,1.1], "good": null, "this": 123, "works": [9]}'), isTrue);
    });

    test("handles objects with property value of empty object", () {
      expect(validator.isValid('{"array":{}}'), isTrue);
    });
  });

  group("negative tests", (){
    group("does not allow mismatching braces and brackets", (){
      test("bracket then brace", (){
        expect(() => validator.isValid('[}'), throwsArgumentError);
      });

      test("brace then bracket", (){
        expect(() => validator.isValid('{]'), throwsArgumentError);
      });

      test("valid braces extra bracket at front", (){
        expect(() => validator.isValid('[{}'), throwsArgumentError);
      });

      test("valid braces extra bracket at end", (){
        expect(() => validator.isValid('{}]'), throwsArgumentError);
      });
    });

    test("does not allow comma after array", (){
      expect(() => validator.isValid('[],'), throwsArgumentError);
    });

    test("does not allow comma after object", (){
      expect(() => validator.isValid('{},'), throwsArgumentError);
    });

    test("does not allow a comma after top level value", (){
      expect(() => validator.isValid('"hello",'), throwsArgumentError);
    });

    test("does not allow only a comma", (){
      expect(() => validator.isValid(','), throwsArgumentError);
    });
  });
}