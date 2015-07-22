library easy_json.json_parser_integration_test;

import 'package:test/test.dart';
import 'package:http/http.dart';
import "package:easy_json/easy_json.dart";

main() {
  group("parser", () {
    test("can retrieve data from pub api", () async {
      Response response = await get("http://pub.dartlang.org/api/packages/json_lexer");
      String json = response.body;
      JsonParser parser = new JsonParser();
      FullPackage fp = parser.parse(json, FullPackage);
      expect(fp.name, "json_lexer");
    });
  });
}

class FullPackage {
  DateTime created;
  int downloads;
  List<String> uploaders;
  List<Version> versions;
  String name;
  String url;
  String uploaders_url;
  String new_version_url;
  String version_url;
  Version latest;
}

class Version {
  Pubspec pubspec;
  String url;
  String archive_url;
  String version;
  String new_dartdoc_url;
  String package_url;
}

class Pubspec {
  Environment environment;
  String version;
  String description;
  String author;
  List<String> authors;
  Map<String, String> dev_dependencies;
  Map<String, String> dependencies;
  String homepage;
  String name;
}

class Environment {
  String sdk;
}