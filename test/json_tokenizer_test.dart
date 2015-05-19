// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library json_tokenizer.test;

import 'package:test/test.dart';

import 'package:json_tokenizer/json_tokenizer.dart';

void main() {
  group("Tokenizer", ()
  {
    test("can handle ints", () {
      JsonTokenizer tokenizer = new JsonTokenizer("2");
      Token token = tokenizer.nextToken();
      expect(token.type, "number");
      expect(token.value, "2");
    });

    test("can handle doubles", () {
      JsonTokenizer tokenizer = new JsonTokenizer("2.1");
      Token token = tokenizer.nextToken();
      expect(token.type, "number");
      expect(token.value, "2.1");
    });

    test("can handle Strings", () {
      JsonTokenizer tokenizer = new JsonTokenizer('"hello"');
      Token token = tokenizer.nextToken();
      expect(token.type, "string");
      expect(token.value, "hello");
    });

    test("can handle bools", () {
      JsonTokenizer tokenizer = new JsonTokenizer('true');
      Token token = tokenizer.nextToken();
      expect(token.type, "bool");
      expect(token.value, "true");

      tokenizer = new JsonTokenizer('false');
      token = tokenizer.nextToken();
      expect(token.type, "bool");
      expect(token.value, "false");
    });

    test("can handle start of an object", (){
      JsonTokenizer tokenizer = new JsonTokenizer('{');
      Token token = tokenizer.nextToken();
      expect(token.type, "begin-object");
      expect(token.value, "{");
    });

    test("can handle end of an object", (){
      JsonTokenizer tokenizer = new JsonTokenizer('}');
      Token token = tokenizer.nextToken();
      expect(token.type, "end-object");
      expect(token.value, "}");
    });

    test("can handle start of an array", (){
      JsonTokenizer tokenizer = new JsonTokenizer('[');
      Token token = tokenizer.nextToken();
      expect(token.type, "begin-array");
      expect(token.value, "[");
    });

    test("can handle end of an object", (){
      JsonTokenizer tokenizer = new JsonTokenizer(']');
      Token token = tokenizer.nextToken();
      expect(token.type, "end-array");
      expect(token.value, "]");
    });

    test("can handle null", (){
      JsonTokenizer tokenizer = new JsonTokenizer('null');
      Token token = tokenizer.nextToken();
      expect(token.type, "null");
      expect(token.value, "null");
    });

    test("can handle commas", (){
      JsonTokenizer tokenizer = new JsonTokenizer(',');
      Token token = tokenizer.nextToken();
      expect(token.type, "value-separator");
      expect(token.value, ",");
    });

    test("can handle colons", (){
      JsonTokenizer tokenizer = new JsonTokenizer(':');
      Token token = tokenizer.nextToken();
      expect(token.type, "name-separator");
      expect(token.value, ":");
    });

    test("throws error for bad input", (){
      expect(() => new JsonTokenizer('bad'), throwsArgumentError);
    });

    test("can handle input with multiple tokens", (){
      JsonTokenizer tokenizer = new JsonTokenizer('{}');
      Token token = tokenizer.nextToken();
      expect(token.type, "begin-object");
      expect(token.value, "{");

      token = tokenizer.nextToken();
      expect(token.type, "end-object");
      expect(token.value, "}");
    });

    test("can handle input with multiple tokens", (){
      JsonTokenizer tokenizer = new JsonTokenizer('{"test": 123}');
      Token token = tokenizer.nextToken();
      expect(token.type, "begin-object");
      expect(token.value, "{");

      token = tokenizer.nextToken();
      expect(token.type, "string");
      expect(token.value, "test");

      token = tokenizer.nextToken();
      expect(token.type, "name-separator");
      expect(token.value, ":");

      token = tokenizer.nextToken();
      expect(token.type, "number");
      expect(token.value, "123");

      token = tokenizer.nextToken();
      expect(token.type, "end-object");
      expect(token.value, "}");
    });

  });
}
