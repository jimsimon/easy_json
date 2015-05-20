// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library json_tokenizer.test;

import 'package:test/test.dart';

import 'package:json_tokenizer/json_tokenizer.dart';

void main() {
  group("Tokenizer", () {
    test("can handle ints", () {
      JsonTokenizer tokenizer = new JsonTokenizer("2");
      Token token = tokenizer.nextToken();
      expect(token.valueType, "number");
      expect(token.value, "2");
    });

    test("can handle doubles", () {
      JsonTokenizer tokenizer = new JsonTokenizer("2.1");
      Token token = tokenizer.nextToken();
      expect(token.valueType, "number");
      expect(token.value, "2.1");
    });

    test("can handle Strings", () {
      JsonTokenizer tokenizer = new JsonTokenizer('"hello"');
      Token token = tokenizer.nextToken();
      expect(token.valueType, "string");
      expect(token.value, "hello");
    });

    test("can handle bools", () {
      JsonTokenizer tokenizer = new JsonTokenizer('true');
      Token token = tokenizer.nextToken();
      expect(token.valueType, "bool");
      expect(token.value, "true");

      tokenizer = new JsonTokenizer('false');
      token = tokenizer.nextToken();
      expect(token.valueType, "bool");
      expect(token.value, "false");
    });

    test("can handle objects", () {
      JsonTokenizer tokenizer = new JsonTokenizer('{}');
      Token token = tokenizer.nextToken();
      expect(token.valueType, "begin-object");
      expect(token.value, "{");

      token = tokenizer.nextToken();
      expect(token.valueType, "end-object");
      expect(token.value, "}");
    });

    test("can handle arrays", () {
      JsonTokenizer tokenizer = new JsonTokenizer('[]');
      Token token = tokenizer.nextToken();
      expect(token.valueType, "begin-array");
      expect(token.value, "[");

      token = tokenizer.nextToken();
      expect(token.valueType, "end-array");
      expect(token.value, "]");
    });

    test("can handle null", () {
      JsonTokenizer tokenizer = new JsonTokenizer('null');
      Token token = tokenizer.nextToken();
      expect(token.valueType, "null");
      expect(token.value, "null");
    });

    test("can handle commas", () {
      JsonTokenizer tokenizer = new JsonTokenizer(',');
      Token token = tokenizer.nextToken();
      expect(token.valueType, "value-separator");
      expect(token.value, ",");
    });

    test("can handle colons", () {
      JsonTokenizer tokenizer = new JsonTokenizer(':');
      Token token = tokenizer.nextToken();
      expect(token.valueType, "name-separator");
      expect(token.value, ":");
    });

    test("throws error for bad input", () {
      expect(() => new JsonTokenizer('bad'), throwsArgumentError);
    });

    test("can handle input with multiple tokens", () {
      JsonTokenizer tokenizer = new JsonTokenizer('{}');
      Token token = tokenizer.nextToken();
      expect(token.valueType, "begin-object");
      expect(token.value, "{");

      token = tokenizer.nextToken();
      expect(token.valueType, "end-object");
      expect(token.value, "}");
    });

    test("can handle input with multiple tokens", () {
      JsonTokenizer tokenizer = new JsonTokenizer('{"test": 123}');
      Token token = tokenizer.nextToken();
      expect(token.valueType, "begin-object");
      expect(token.value, "{");

      token = tokenizer.nextToken();
      expect(token.valueType, "string");
      expect(token.value, "test");

      token = tokenizer.nextToken();
      expect(token.valueType, "name-separator");
      expect(token.value, ":");

      token = tokenizer.nextToken();
      expect(token.valueType, "number");
      expect(token.value, "123");

      token = tokenizer.nextToken();
      expect(token.valueType, "end-object");
      expect(token.value, "}");
    });

//    group("syntax error tests: ", () {
//      test("throws error for missing closing curly brace", (){
//        expect(() => new JsonTokenizer("{"), throwsArgumentError);
//      });
//
//      test("throws error for missing closing square bracket", (){
//        expect(() => new JsonTokenizer("["), throwsArgumentError);
//      });
//
//      test("throws error for mismatching curly braces", () {
//        expect(() => new JsonTokenizer("}"), throwsArgumentError);
//      });
//
//      test("throws error for mismatching square brackets", () {
//        expect(() => new JsonTokenizer("]"), throwsArgumentError);
//      });
//
//      test("throws error for missing name in name-value pair", () {
//        expect(() => new JsonTokenizer("{:123}"), throwsArgumentError);
//      });
//
//      test("throws error for missing value in name-value pair", () {
//        expect(() => new JsonTokenizer('{"hi":}'), throwsArgumentError);
//      });
//
//      test("throws error for invalid name type in name-value pair", () {
//        expect(() => new JsonTokenizer('{123:"hello"}'), throwsArgumentError);
//      });
//    });
  });
}
