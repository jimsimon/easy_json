library v2;

import "package:json_tokenizer/json_tokenizer.dart";
import "dart:collection";

Queue<Responsibility> requiredStack;
class JsonValidator {

  isValid(String json) {
    requiredStack = new Queue();
    Queue<Token> _tokens = new JsonTokenizer(json).tokens;

    requiredStack.addFirst(new ErrorResponsibility(true));
    requiredStack.addFirst(new EndOfInputResponsibility(true));
    requiredStack.addFirst(new BeginObjectResponsibility(false));
    requiredStack.addFirst(new BeginArrayResponsibility(false));
    requiredStack.addFirst(new TopLevelValueResponsibility(false));
    while(_tokens.isNotEmpty) {
      Token token = _tokens.removeFirst();
      while(requiredStack.isNotEmpty) {
        Responsibility responsibility = requiredStack.removeFirst();
        if (responsibility.matches(token)) {
          if (!responsibility.required) {
            while(requiredStack.isNotEmpty && !requiredStack.first.required) {
              requiredStack.removeFirst();
            }
          }
          for (Responsibility r in responsibility.getNextResponsibilities()) {
            requiredStack.addFirst(r);
          }
          break;
        } else if (responsibility.required) {
          throw new ArgumentError("Unexpected token: ${token.value}");
        }
      }
    }
    return true;
  }
}

abstract class Responsibility {
  bool required;

  Responsibility(bool this.required);

  bool matches(Token token);

  List<Responsibility> getNextResponsibilities();
}

class BeginObjectResponsibility extends Responsibility {
  BeginObjectResponsibility(bool required) : super(required);

  @override
  bool matches(Token token) {
    if (token.type == "begin-object") {
      return true;
    }
    return false;
  }

  @override
  List<Responsibility> getNextResponsibilities() {
    return [
      new EndObjectResponsibility(true),
      new ObjectKeyResponsibility(false)
    ];
  }
}

class EndObjectResponsibility extends Responsibility {
  EndObjectResponsibility(bool required) : super(required);

  @override
  bool matches(Token token) {
    if (token.type == "end-object") {
      return true;
    }
    return false;
  }

  @override
  List<Responsibility> getNextResponsibilities() {
    if (requiredStack.length == 2) {
      return [];
    }

    return [
      new ValueSeparatorResponsibility(false)
    ];
  }
}

class BeginArrayResponsibility extends Responsibility {
  BeginArrayResponsibility(bool required) : super(required);

  @override
  bool matches(Token token) {
    if (token.type == "begin-array") {
      return true;
    }
    return false;
  }

  @override
  List<Responsibility> getNextResponsibilities() {
    return [
      new EndArrayResponsibility(true),
      new BeginArrayResponsibility(false),
      new ValueResponsibility(false),
      new BeginObjectResponsibility(false)
    ];
  }
}

class EndArrayResponsibility extends Responsibility {
  EndArrayResponsibility(bool required) : super(required);

  @override
  bool matches(Token token) {
    if (token.type == "end-array") {
      return true;
    }
    return false;
  }

  @override
  List<Responsibility> getNextResponsibilities() {
    if (requiredStack.length == 2) {
      return [];
    }
    return [
      new ValueSeparatorResponsibility(false)
    ];
  }
}

class ValueResponsibility extends Responsibility {
  ValueResponsibility(bool required) : super(required);

  @override
  bool matches(Token token) {
    if (token.type == "value") {
      return true;
    }
    return false;
  }

  @override
  List<Responsibility> getNextResponsibilities() {
    return [
      new ValueSeparatorResponsibility(false)
    ];
  }
}

class ObjectKeyResponsibility extends Responsibility {
  ObjectKeyResponsibility(bool required) : super(required);

  @override
  bool matches(Token token) {
    if (token.type == "value" && token.valueType == "string") {
      return true;
    }
    return false;
  }

  @override
  List<Responsibility> getNextResponsibilities() {
    return [
      new NameSeparatorResponsibility(true)
    ];
  }
}

class ErrorResponsibility extends Responsibility {
  ErrorResponsibility(bool required) : super(required);

  @override
  bool matches(Token token) {
    throw new ArgumentError("Unexpected token: ${token.value}");
  }

  @override
  List<Responsibility> getNextResponsibilities() {
    return [];
  }
}

class ValueSeparatorResponsibility extends Responsibility {
  ValueSeparatorResponsibility(bool required) : super(required);

  @override
  bool matches(Token token) {
    if (token.type == "value-separator") {
      return true;
    }
    return false;
  }

  @override
  List<Responsibility> getNextResponsibilities() {
    if (requiredStack.first is EndObjectResponsibility) {
      return [
        new ObjectKeyResponsibility(false)
      ];
    } else {
      return [
        new ValueResponsibility(false),
        new BeginObjectResponsibility(false),
        new BeginArrayResponsibility(false)
      ];
    }
  }
}

class NameSeparatorResponsibility extends Responsibility {
  NameSeparatorResponsibility(bool required) : super(required);

  @override
  bool matches(Token token) {
    if (token.type == "name-separator") {
      return true;
    }
    return false;
  }

  @override
  List<Responsibility> getNextResponsibilities() {
    return [
      new ValueResponsibility(false),
      new BeginObjectResponsibility(false),
      new BeginArrayResponsibility(false)
    ];
  }
}

class TopLevelValueResponsibility extends Responsibility {
  TopLevelValueResponsibility(bool required) : super(required);

  @override
  bool matches(Token token) {
    if (token.type == "value") {
      return true;
    }
    return false;
  }

  @override
  List<Responsibility> getNextResponsibilities() {
    if (requiredStack.length == 2) {
      return [];
    }

    return [
      new ValueSeparatorResponsibility(false)
    ];
  }
}

class EndOfInputResponsibility extends Responsibility {
  EndOfInputResponsibility(bool required) : super(required);

  @override
  bool matches(Token token) {
    if (token.type == "eof" && requiredStack.length == 1 && requiredStack.first is ErrorResponsibility) {
      requiredStack.clear();
      return true;
    }
    return false;
  }

  @override
  List<Responsibility> getNextResponsibilities() {
    return [];
  }
}
