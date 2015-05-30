library json_parser.test;

import 'package:test/test.dart';

import "package:json_tokenizer/json_tokenizer.dart";

main() async {
  var parser;
  setUp((){
    parser = new JsonParser();
  });

  group("positive tests", () {
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
      expect(parser.parse('{"hello": "value"}', Fixture).hello, "value");
    });

    test("allows object with multiple key-value pairs", () {
      Fixture result = parser.parse('{"hello": "value", "world": "value2", "cool": "value3"}', Fixture);
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
      Type type = new TypeToken<List<Fixture>>().type;
      var result = parser.parse('[{}]', type);
      expect(result, isList);
      expect(result[0], new isInstanceOf<Fixture>());
    });

    test("handles arrays with multiple empty objects", () {
      Type type = new TypeToken<List<Fixture>>().type;
      var result = parser.parse('[{},{}]', type);
      expect(result, isList);
      expect(result[0], new isInstanceOf<Fixture>());
      expect(result[1], new isInstanceOf<Fixture>());
      expect(result[0], isNot(result[1]));
    });

    test("handles arrays with single non-empty objects", () {
      Type type = new TypeToken<List<Fixture>>().type;
      var result = parser.parse('[{"hello":"world"}]', type);
      expect(result, isList);
      expect(result[0], new isInstanceOf<Fixture>());
      expect(result[0].hello, "world");
    });

    test("handles arrays with multiple non-empty objects", () {
      Type type = new TypeToken<List<Fixture>>().type;
      var result = parser.parse('[{"hello":"world"},{"hello":"goodbye"}]', type);
      expect(result, isList);
      expect(result[0], new isInstanceOf<Fixture>());
      expect(result[0].hello, "world");
      expect(result[1], new isInstanceOf<Fixture>());
      expect(result[1].hello, "goodbye");
    });

//    test("handles arrays with mixed elements", () {
//      expect(parser.parse('[{"hello":"world"},123,"goodbye",true]'), isTrue);
//    });

    test("handles arrays within arrays", () {
      Type type = new TypeToken<List<List<String>>>().type;
      expect(parser.parse('[[],[]]', type), [[],[]]);
    });

    test("handles objects with property value of empty array", () {
      var result = parser.parse('{"array":[]}', NestedListFixture);
      expect(result, new isInstanceOf<NestedListFixture>());
      expect(result.array, isEmpty);
    });

    test("handles objects with property value of array with single item", () {
      var result = parser.parse('{"array":["hello"]}', NestedListFixture);
      expect(result, new isInstanceOf<NestedListFixture>());
      expect(result.array, ["hello"]);
    });

    test("handles objects with property value of array with multiple items", () {
      var result = parser.parse('{"array":["hello","world"]}', NestedListFixture);
      expect(result, new isInstanceOf<NestedListFixture>());
      expect(result.array, ["hello", "world"]);
    });

    test("handles objects with property value of array with multiple mixed items", () {
      expect(parser.parse('{"array":["hello","world",123,true,1.1]}'), isTrue);
    });

    test("handles objects with multiple mixed property values with multiple mixed items", () {
      expect(parser.parse('{"array":["hello","world",123,true,1.1], "good": null, "this": 123, "works": [9]}'), isTrue);
    });

    test("handles objects with property value of empty object", () {
      expect(parser.parse('{"array":{}}'), isTrue);
    });
  });

  group("negative tests", (){
    group("does not allow mismatching braces and brackets", (){
      test("bracket then brace", (){
        expect(() => parser.parse('[}'), throwsArgumentError);
      });

      test("brace then bracket", (){
        expect(() => parser.parse('{]'), throwsArgumentError);
      });

      test("valid braces extra bracket at front", (){
        expect(() => parser.parse('[{}'), throwsArgumentError);
      });

      test("valid braces extra bracket at end", (){
        expect(() => parser.parse('{}]'), throwsArgumentError);
      });
    });

    test("does not allow comma after array", (){
      expect(() => parser.parse('[],'), throwsArgumentError);
    });

    test("does not allow comma after object", (){
      expect(() => parser.parse('{},'), throwsArgumentError);
    });

    test("does not allow a comma after top level value", (){
      expect(() => parser.parse('"hello",'), throwsArgumentError);
    });

    test("does not allow only a comma", (){
      expect(() => parser.parse(','), throwsArgumentError);
    });
  });
}

class Fixture {
  String hello;
  String world;
  String cool;
}

class NestedListFixture {
  List<String> array;
}