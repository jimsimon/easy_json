// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library json_lexer.test;

import 'package:test/test.dart';

import 'package:json_lexer/json_lexer.dart';

void main() {
  group("lexer", () {
    test("can handle ints", () {
      JsonLexer lexer = new JsonLexer("2");
      Token token = lexer.nextToken();
      expect(token.valueType, ValueType.NUMBER);
      expect(token.value, "2");
    });

    test("can handle doubles", () {
      JsonLexer lexer = new JsonLexer("2.1");
      Token token = lexer.nextToken();
      expect(token.valueType, ValueType.NUMBER);
      expect(token.value, "2.1");
    });

    test("can handle Strings", () {
      JsonLexer lexer = new JsonLexer('"hello"');
      Token token = lexer.nextToken();
      expect(token.valueType, ValueType.STRING);
      expect(token.value, "hello");
    });

    test("can handle bools", () {
      JsonLexer lexer = new JsonLexer('true');
      Token token = lexer.nextToken();
      expect(token.valueType, ValueType.BOOL);
      expect(token.value, "true");

      lexer = new JsonLexer('false');
      token = lexer.nextToken();
      expect(token.valueType, ValueType.BOOL);
      expect(token.value, "false");
    });

    test("can handle objects", () {
      JsonLexer lexer = new JsonLexer('{}');
      Token token = lexer.nextToken();
      expect(token.valueType, ValueType.BEGIN_OBJECT);
      expect(token.value, "{");

      token = lexer.nextToken();
      expect(token.valueType, ValueType.END_OBJECT);
      expect(token.value, "}");
    });

    test("can handle arrays", () {
      JsonLexer lexer = new JsonLexer('[]');
      Token token = lexer.nextToken();
      expect(token.valueType, ValueType.BEGIN_ARRAY);
      expect(token.value, "[");

      token = lexer.nextToken();
      expect(token.valueType, ValueType.END_ARRAY);
      expect(token.value, "]");
    });

    test("can handle null", () {
      JsonLexer lexer = new JsonLexer('null');
      Token token = lexer.nextToken();
      expect(token.valueType, ValueType.NULL);
      expect(token.value, "null");
    });

    test("can handle commas", () {
      JsonLexer lexer = new JsonLexer(',');
      Token token = lexer.nextToken();
      expect(token.valueType, ValueType.VALUE_SEPARATOR);
      expect(token.value, ",");
    });

    test("can handle colons", () {
      JsonLexer lexer = new JsonLexer(':');
      Token token = lexer.nextToken();
      expect(token.valueType, ValueType.NAME_SEPARATOR);
      expect(token.value, ":");
    });

    test("throws error for bad input", () {
      expect(() => new JsonLexer('bad'), throwsArgumentError);
    });

    test("can handle input with multiple tokens", () {
      JsonLexer lexer = new JsonLexer('{}');
      Token token = lexer.nextToken();
      expect(token.valueType, ValueType.BEGIN_OBJECT);
      expect(token.value, "{");

      token = lexer.nextToken();
      expect(token.valueType, ValueType.END_OBJECT);
      expect(token.value, "}");
    });

    test("can handle input with multiple tokens", () {
      JsonLexer lexer = new JsonLexer('{"test": 123}');
      Token token = lexer.nextToken();
      expect(token.valueType, ValueType.BEGIN_OBJECT);
      expect(token.value, "{");

      token = lexer.nextToken();
      expect(token.valueType, ValueType.STRING);
      expect(token.value, "test");

      token = lexer.nextToken();
      expect(token.valueType, ValueType.NAME_SEPARATOR);
      expect(token.value, ":");

      token = lexer.nextToken();
      expect(token.valueType, ValueType.NUMBER);
      expect(token.value, "123");

      token = lexer.nextToken();
      expect(token.valueType, ValueType.END_OBJECT);
      expect(token.value, "}");
    });

//    group("syntax error tests: ", () {
//      test("throws error for missing closing curly brace", (){
//        expect(() => new Jsonlexer("{"), throwsArgumentError);
//      });
//
//      test("throws error for missing closing square bracket", (){
//        expect(() => new Jsonlexer("["), throwsArgumentError);
//      });
//
//      test("throws error for mismatching curly braces", () {
//        expect(() => new Jsonlexer("}"), throwsArgumentError);
//      });
//
//      test("throws error for mismatching square brackets", () {
//        expect(() => new Jsonlexer("]"), throwsArgumentError);
//      });
//
//      test("throws error for missing name in name-value pair", () {
//        expect(() => new Jsonlexer("{:123}"), throwsArgumentError);
//      });
//
//      test("throws error for missing value in name-value pair", () {
//        expect(() => new Jsonlexer('{"hi":}'), throwsArgumentError);
//      });
//
//      test("throws error for invalid name type in name-value pair", () {
//        expect(() => new Jsonlexer('{123:"hello"}'), throwsArgumentError);
//      });
//    });
  });
}
