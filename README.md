[![Build Status](https://travis-ci.org/jimsimon/easy_json.svg)](https://travis-ci.org/jimsimon/easy_json)
[![Coverage Status](https://coveralls.io/repos/jimsimon/easy_json/badge.svg?branch=master)](https://coveralls.io/r/jimsimon/easy_json?branch=master)
[![Pub](https://img.shields.io/pub/v/easy_json.svg)]()

# easy_json
A serialization package for easily converting Dart objects to and from JSON.
 
# Features
* Written entirely in Dart (does not rely on Dart's JSON Codec)
* Works on the VM only (dart2js support is in-progress)
* Handles escaped JSON strings
* Easy to extend with support for new types via codecs
* Easy to override existing type codecs

# Limitations
* Dart classes must either have a no-args constructor, or a codec must be defined for that type.
* Type arguments must be specified for any class that has them.  This means that just saying List or Map will not work.  Instead you should do something like List<String> or Map<String, Person>.
* JSON parsing is strict, which means the parser will error on invalid JSON (i.e. unquoted object keys, object keys with the wrong type of quotes, etc.)

# Example Usage (Normal Types)
```dart
import "package:easy_json/easy_json.dart";

class Person {
  String firstName;
  String lastName;
  
  Person(this.firstName, this.lastName);
}

main() {
  Person person = new Person("Jim", "Simon");
  
  JsonComposer composer = new JsonComposer();
  String json = composer.compose(person);
  
  JsonParser parser = new JsonParser();
  person = parser.parse(json, Person);
}
```

# Example Usage (Generic Types)
When the object you want to serialize has one or more generic type arguments, you must use a TypeToken when using the parser.
```dart
import "package:easy_json/easy_json.dart";

main() {
  Map<String, String> example = {
    "firstName": "Jim",
    "lastName": "Simon"
  }
  
  JsonComposer composer = new JsonComposer();
  String json = composer.compose(example);
    
  JsonParser parser = new JsonParser();
  Type type = new TypeToken<Map<String, String>>().type;
  example = parser.parse(json, type);
}
```

# Adding Support for New Types via Codecs
By default, this library comes with codecs for the following types:
* bool
* double
* int
* List
* String

These codecs are automatically preloaded when a JsonParser object is created.

The purpose of a codec is to handle the serialization and deserialization of the type it's being registered for.  This means that the List codec should (and does) only create an empty list, and should not handle it's items as they will be handled by the codec for their Type.

To add a new codec, implement the abstract Codec class provided by the dart:convert package, and then register it as follows:
```dart
import "package:easy_json/easy_json.dart";

main() {
  JsonParser parser = new JsonParser();
  parser.addCodecForType(MyType, const MyTypeCodec());
  parser.addCodecForSymbol(const Symbol("my.package.MyOtherType", const MyOtherTypeCodec());
  
  ...
}
```

If the parser encounters a Type that does not have a Codec associated with it, it will attempt to use mirrors (reflection) to handle it.
