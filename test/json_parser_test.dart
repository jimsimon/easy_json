library json_parser.test;

import 'package:test/test.dart';

import "package:json_tokenizer/json_tokenizer.dart";

main() async {
  JsonParser parser;
  setUp((){
    parser = new JsonParser();
  });

  //TODO Add tests for Maps
  group("positive tests", () {
    test("allows top level nulls", (){
      expect(parser.parse("null", Object), isNull);
    });

    test("parses the string 'null' correctly", (){
      expect(parser.parse('"null"', String), "null");
    });

    test("allows top level integers", () {
      expect(parser.parse("1", int), 1);
    });

    test("allows top level doubles", () {
      expect(parser.parse("1.1", double), 1.1);
    });

    test("allows top level strings", () {
      expect(parser.parse('"hello"', String), "hello");
    });

    test("allows top level true", () {
      expect(parser.parse("true", bool), isTrue);
    });

    test("allows top level false", () {
      expect(parser.parse("false", bool), isFalse);
    });

    test("allows empty objects", () {
      expect(parser.parse("{}", Object), new isInstanceOf<Object>());
    });

    test("allows object with single key-value pair", () {
      expect(parser.parse('{"hello": "value"}', SimpleFixture).hello, "value");
    });

    test("allows object with multiple key-value pairs", () {
      SimpleFixture result = parser.parse('{"hello": "value", "world": "value2", "cool": "value3"}', SimpleFixture);
      expect(result.hello, "value");
      expect(result.world, "value2");
      expect(result.cool, "value3");
    });

    test("allows empty arrays", () {
      Type type = new TypeToken<List<String>>().type;
      expect(parser.parse('[]', type), []);
    });

    test("allows arrays with a single value", () {
      Type type = new TypeToken<List<String>>().type;
      expect(parser.parse('["hello"]', type), ["hello"]);
    });

    test("allows arrays with a multiple values", () {
      Type type = new TypeToken<List<String>>().type;
      expect(parser.parse('["hello", "world", "!"]', type), ["hello", "world", "!"]);
    });

    test("handles arrays with a single empty object", () {
      Type type = new TypeToken<List<SimpleFixture>>().type;
      var result = parser.parse('[{}]', type);
      expect(result, isList);
      expect(result[0], new isInstanceOf<SimpleFixture>());
    });

    test("handles arrays with multiple empty objects", () {
      Type type = new TypeToken<List<SimpleFixture>>().type;
      var result = parser.parse('[{},{}]', type);
      expect(result, isList);
      expect(result[0], new isInstanceOf<SimpleFixture>());
      expect(result[1], new isInstanceOf<SimpleFixture>());
      expect(result[0], isNot(result[1]));
    });

    test("handles arrays with single non-empty objects", () {
      Type type = new TypeToken<List<SimpleFixture>>().type;
      var result = parser.parse('[{"hello":"world"}]', type);
      expect(result, isList);
      expect(result[0], new isInstanceOf<SimpleFixture>());
      expect(result[0].hello, "world");
    });

    test("handles arrays with multiple non-empty objects", () {
      Type type = new TypeToken<List<SimpleFixture>>().type;
      var result = parser.parse('[{"hello":"world"},{"hello":"goodbye"}]', type);
      expect(result, isList);
      expect(result[0], new isInstanceOf<SimpleFixture>());
      expect(result[0].hello, "world");
      expect(result[1], new isInstanceOf<SimpleFixture>());
      expect(result[1].hello, "goodbye");
    });

    test("handles arrays within arrays", () {
      Type type = new TypeToken<List<List<String>>>().type;
      expect(parser.parse('[[],[]]', type), [[],[]]);
    });

    test("handles objects with property value of empty array", () {
      var result = parser.parse('{"array":[]}', ComplexFixture);
      expect(result, new isInstanceOf<ComplexFixture>());
      expect(result.array, isEmpty);
    });

    test("handles objects with property value of array with single item", () {
      var result = parser.parse('{"array":["hello"]}', ComplexFixture);
      expect(result, new isInstanceOf<ComplexFixture>());
      expect(result.array, ["hello"]);
    });

    test("handles objects with property value of array with multiple items", () {
      var result = parser.parse('{"array":["hello","world"]}', ComplexFixture);
      expect(result, new isInstanceOf<ComplexFixture>());
      expect(result.array, ["hello", "world"]);
    });

    test("handles objects with multiple properties whose values have different types", () {
      var result = parser.parse('{"array":["hello","world"], "good": null, "thisInt": 123, "works": [9]}', ComplexFixture);
      expect(result, new isInstanceOf<ComplexFixture>());
      expect(result.array, ["hello", "world"]);
      expect(result.good, isNull);
      expect(result.thisInt, 123);
      expect(result.works, [9]);
    });

    test("handles objects with property value of empty object", () {
      var result = parser.parse('{"anObject":{}}', ComplexFixture);
      expect(result, new isInstanceOf<ComplexFixture>());
      expect(result.anObject, new isInstanceOf<SimpleFixture>());
      expect(result.anObject.hello, isNull);
      expect(result.anObject.world, isNull);
      expect(result.anObject.cool, isNull);
    });
  });

  //TODO add tests for when type (including generic types) is dynamic
  group("negative tests", (){
    group("does not allow mismatching braces and brackets", (){
      test("bracket then brace", (){
        Type type = new TypeToken<List<String>>().type;
        expect(() => parser.parse('[}', type), throwsArgumentError);
      });

      test("brace then bracket", (){
        expect(() => parser.parse('{]', Object), throwsArgumentError);
      });

      test("valid braces extra bracket at front", (){
        Type type = new TypeToken<List<String>>().type;
        expect(() => parser.parse('[{}', type), throwsArgumentError);
      });

      test("valid braces extra bracket at end", (){
        expect(() => parser.parse('{}]', Object), throwsArgumentError);
      });
    });

    test("does not allow comma after array", (){
      Type type = new TypeToken<List<String>>().type;
      expect(() => parser.parse('[],', type), throwsArgumentError);
    });

    test("does not allow comma after object", (){
      expect(() => parser.parse('{},', Object), throwsArgumentError);
    });

    test("does not allow a comma after top level value", (){
      expect(() => parser.parse('"hello",', String), throwsArgumentError);
    });

    test("does not allow only a comma", (){
      expect(() => parser.parse(',', String), throwsArgumentError);
    });
  });
}

@Serializable
class SimpleFixture {
  String hello;
  String world;
  String cool;
}

@Serializable
class ComplexFixture {
  SimpleFixture anObject;
  List<String> array;
  Object good;
  int thisInt;
  List<int> works;
}