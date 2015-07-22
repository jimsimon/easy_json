@TestOn("vm || browser")
library easy_json.json_composer_test;

import "package:test/test.dart";
import "package:easy_json/easy_json.dart";

main() {
  JsonComposer composer = new JsonComposer();
  group("Encoder", () {
    test("can encode null", () {
      expect(composer.compose(null), "null");
    });

    test("can encode integers", () {
      expect(composer.compose(1), "1");
    });

    test("can encode doubles", (){
      expect(composer.compose(2.0), "2");
    });

    test("can encode strings", () {
      expect(composer.compose("hello world"), '"hello world"');
    });

    test("can encode booleans", () {
      expect(composer.compose(true), "true");
    });

    test("can encode empty map literals", () {
      expect(composer.compose({}), "{}");
    });

    test("can encode empty map non-literals", () {
      expect(composer.compose(new Map()), "{}");
    });

    test("can encode valid non-empty maps with String keys", (){
      expect(composer.compose({"1": "hello"}), '{"1":"hello"}');
    });

    test("can encode valid non-empty maps with int keys", (){
      expect(composer.compose({1: "hello"}), '{"1":"hello"}');
    });

    test("can encode valid non-empty maps with double keys", (){
      expect(composer.compose({1.1: 1.1}), '{"1.1":1.1}');
    });

    test("can encode valid non-empty maps with boolean keys", (){
      expect(composer.compose({true: 1}), '{"true":1}');
    });

    test("can encode valid non-empty maps with mixed keys", (){
      expect(composer.compose({"1": "hello", 1.1: "hello", true: "hello"}), '{"1":"hello","1.1":"hello","true":"hello"}');
    });

    test("can encode valid non-empty maps with duplicate keys of different types", (){
      expect(composer.compose({"1": "hello", 1: "hello"}), '{"1":"hello"}');
    });

    test("throws error for complex keys", (){
      expect(() => composer.compose({{}: "hello"}), throwsArgumentError);
    });

    test("can encode empty list literals", () {
      expect(composer.compose([]), "[]");
    });

    test("can encode empty list objects", () {
      expect(composer.compose(new List()), "[]");
    });

    test("can encode list of Strings with single item", () {
      expect(composer.compose(["hello"]), '["hello"]');
    });

    test("can encode list of Strings with mixed items", () {
      expect(composer.compose(["hello", 1]), '["hello",1]');
    });

    test("can encode an object with no properties", () {
      expect(composer.compose(new Object()), "{}");
    }, skip: "Reflectable currently prevents serialization of root Object type");

    test("can encode an object with one property", () {
      var fixture = new SinglePropertyTestFixture();
      fixture.property1 = "hello";
      expect(composer.compose(fixture), '{"property1":"hello"}');
    });

    test("can encode an object with multiple properties", () {
      var fixture = new MultiplePropertyTestFixture();
      fixture.property1 = "hello";
      fixture.property2 = "world";
      expect(composer.compose(fixture), '{"property1":"hello","property2":"world"}');
    });

    test("can encode an object with complex properties", () {
      var fixture = new ComplexPropertyTestFixture();
      fixture.property1 = "hello";
      fixture.property2 = "world";
      fixture.complex = new MultiplePropertyTestFixture();
      fixture.complex.property1 = "goodbye";
      fixture.complex.property2 = "friends";
      expect(composer.compose(fixture), '{"property1":"hello","property2":"world","complex":{"property1":"goodbye","property2":"friends"}}');
    });

    //TODO Add List and Map tests with complex objects in them
    //TODO Add support for generics

  });
}

//@serializable
class SinglePropertyTestFixture {
  String property1;
}

//@serializable
class MultiplePropertyTestFixture extends SinglePropertyTestFixture {
  String property2;
}

//@serializable
class ComplexPropertyTestFixture extends MultiplePropertyTestFixture {
  SinglePropertyTestFixture complex;
}