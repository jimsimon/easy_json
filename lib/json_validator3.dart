library v3;

import "dart:collection";
import "package:json_tokenizer/json_tokenizer.dart";

Queue<Responsibility> requiredStack;
Set<Responsibility> optionalSet;

class JsonValidator {

  isValid(String json) {
    requiredStack = new Queue();
    optionalSet = new HashSet();
    Queue<Token> _tokens = new JsonTokenizer(json).tokens;

    requiredStack.addFirst(new ErrorResponsibility());
    requiredStack.addFirst(new EndOfInputResponsibility());
    optionalSet.add(new BeginObjectResponsibility());
    optionalSet.add(new BeginArrayResponsibility());
    optionalSet.add(new TopLevelValueResponsibility());
    while (_tokens.isNotEmpty) {
      Token token = _tokens.removeFirst();

      Responsibility responsibilityToLookFor = new Responsibility(token.type);
      Responsibility optionalResponsibility = optionalSet.lookup(responsibilityToLookFor);
      if (optionalResponsibility != null && optionalResponsibility.matches(token)) {
        optionalSet = optionalResponsibility.optionalResponsibilities;
        if (optionalResponsibility.requiredResponsibility != null) {
          requiredStack.addFirst(optionalResponsibility.requiredResponsibility);
        }
      } else if (optionalResponsibility == null) {
        Responsibility requiredResponsibility = requiredStack.removeFirst();
        if (requiredResponsibility.matches(token)) {
          optionalSet = requiredResponsibility.optionalResponsibilities;
          if (requiredResponsibility.requiredResponsibility != null) {
            requiredStack.addFirst(requiredResponsibility.requiredResponsibility);
          }
        } else {
          throw new ArgumentError("Unexpected token: ${token.value}");
        }
      } else {
        throw new ArgumentError("Unexpected token: ${token.value}");
      }
    }
    return true;
  }
}

class Responsibility {
  String tokenType;

  Responsibility(String this.tokenType);

  bool matches(Token token) {
    if (token.type == tokenType) {
      return true;
    }
    return false;
  }

  @override
  int get hashCode => tokenType.hashCode;

  @override
  bool operator ==(o) => this.tokenType == o.tokenType;

  HashSet<Responsibility> get optionalResponsibilities => new HashSet();

  Responsibility get requiredResponsibility => null;
}

class BeginObjectResponsibility extends Responsibility {
  BeginObjectResponsibility() : super("begin-object");

  @override
  HashSet<Responsibility> get optionalResponsibilities {
    return new HashSet()..add(new ObjectKeyResponsibility());
  }

  @override
  Responsibility get requiredResponsibility => new EndObjectResponsibility();
}

class EndObjectResponsibility extends Responsibility {
  EndObjectResponsibility() : super("end-object");

  @override
  HashSet<Responsibility> get optionalResponsibilities {
    if (requiredStack.length == 2) {
      return super.optionalResponsibilities;
    }

    return new HashSet()..add(new ValueSeparatorResponsibility());
  }
}

class BeginArrayResponsibility extends Responsibility {
  BeginArrayResponsibility() : super("begin-array");

  @override
  HashSet<Responsibility> get optionalResponsibilities {
    return new HashSet()
      ..add(new BeginArrayResponsibility())
      ..add(new ValueResponsibility())
    ..add(new BeginObjectResponsibility());
  }

  @override
  Responsibility get requiredResponsibility => new EndArrayResponsibility();
}

class EndArrayResponsibility extends Responsibility {
  EndArrayResponsibility() : super("end-array");

  @override
  HashSet<Responsibility> get optionalResponsibilities {
    if (requiredStack.length == 2) {
      return super.optionalResponsibilities;
    }
    return new HashSet()..add(new ValueSeparatorResponsibility());
  }
}

class ValueResponsibility extends Responsibility {
  ValueResponsibility() : super("value");

  @override
  HashSet<Responsibility> get optionalResponsibilities {
    return new HashSet()..add(new ValueSeparatorResponsibility());
  }
}

class ObjectKeyResponsibility extends Responsibility {
  ObjectKeyResponsibility() : super("value");

  @override
  bool matches(Token token) {
    if (token.type == tokenType && token.valueType == "string") {
      return true;
    }
    return false;
  }

  @override
  Responsibility get requiredResponsibility => new NameSeparatorResponsibility();
}

class ErrorResponsibility extends Responsibility {
  ErrorResponsibility() : super("error");

  @override
  bool matches(Token token) {
    throw new ArgumentError("Unexpected token: ${token.value}");
  }
}

class ValueSeparatorResponsibility extends Responsibility {
  ValueSeparatorResponsibility() : super("value-separator");

  @override
  HashSet<Responsibility> get optionalResponsibilities {
    if (requiredStack.first is EndObjectResponsibility) {
      return new HashSet()..add(new ObjectKeyResponsibility());
    } else {
      return new HashSet()
        ..add(new ValueResponsibility())
        ..add(new BeginObjectResponsibility())
        ..add(new BeginArrayResponsibility());
    }
  }
}

class NameSeparatorResponsibility extends Responsibility {
  NameSeparatorResponsibility() : super("name-separator");

  @override
  HashSet<Responsibility> get optionalResponsibilities {
    return new HashSet()
      ..add(new ValueResponsibility())
      ..add(new BeginObjectResponsibility())
      ..add(new BeginArrayResponsibility());
  }
}

class TopLevelValueResponsibility extends Responsibility {
  TopLevelValueResponsibility() : super("value");

  @override
  HashSet<Responsibility> get optionalResponsibilities {
    if (requiredStack.length == 2) {
      return super.optionalResponsibilities;
    }

    return new HashSet()..add(new ValueSeparatorResponsibility());
  }
}

class EndOfInputResponsibility extends Responsibility {
  EndOfInputResponsibility() : super("eof");

  @override
  bool matches(Token token) {
    if (token.type == tokenType && requiredStack.length == 1 && requiredStack.first is ErrorResponsibility) {
      requiredStack.clear();
      return true;
    }
    return false;
  }
}
