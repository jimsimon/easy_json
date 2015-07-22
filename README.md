[![Build Status](https://travis-ci.org/jimsimon/easy_json.svg)](https://travis-ci.org/jimsimon/easy_json)
[![Coverage Status](https://coveralls.io/repos/jimsimon/easy_json/badge.svg?branch=master)](https://coveralls.io/r/jimsimon/easy_json?branch=master)
[![Pub](https://img.shields.io/pub/v/easy_json.svg)]()

# easy_json
A serialization package for easily converting Dart objects to and from JSON.
 
# Features
* Written entirely in Dart
* Works on the VM only (dart2js support is in-progress)
* Handles escaped JSON strings

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
