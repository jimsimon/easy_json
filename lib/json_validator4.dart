library v4;

import "dart:collection";
import "package:json_tokenizer/json_tokenizer.dart";



class JsonValidator {

  static String valueSeparatorStateGenerator(Queue<String> requiredStack, Token token) {
    if (requiredStack.first == "end-object") {
      return "object-name";
    }
    return "value";
  }

  static bool isStringToken(Token token) => token.valueType == "string";

/*
  "state": {
    "optional": {
      "token": "new state"
    },
    "required": {
      "token": "new state"
    }
 */
  static const stateMap = const {
    "init": const {
      "optional": const {
        "begin-object": const {
          "state": "begin-object",
        },
        "begin-array": const {
          "state": "begin-array",
        },
        "value": const {
          "state": "value",
        }
      },
      "required": "eof"
    },
    "begin-object": const {
      "optional": const {
        "value": const {
          "state": "object-name",
          "validator": isStringToken
        }
      },
      "required": "end-object"
    },
    "object-name": const {
      "required": "name-separator"
    },
    "name-separator": const {
      "optional": const {
        "begin-object": const {
          "state": "begin-object",
        },
        "begin-array": const {
          "state": "begin-array",
        },
        "value": const {
          "state": "value",
        }
      }
    },
    "end-object": const {
      "optional": const {
        "value-separator": const {
          "state": "value-separator",
        }
      }
    },
    "begin-array": const {
      "optional": const {
        "begin-array": const {
          "state": "begin-array",
        },
        "value": const {
          "state": "value",
        },
        "begin-object": const {
          "state": "begin-object",
        }
      },
      "required": "end-array"
    },
    "end-array": const {
      "optional": const {
        "value-separator": const {
          "state": "value-separator",
        }
      }
    },
    "value": const {
      "optional": const {
        "value-separator": const {
          "state": "value-separator"
        }
      }
    },
    "value-separator": const {
      "optional": const {
        "value": const {
          "state": valueSeparatorStateGenerator,
        },
        "begin-object": const {
          "state": "begin-object",
        },
        "begin-array": const {
          "state": "begin-array",
        }
      }
    },
    "eof": const {}
  };

  isValid(String json) {
    String state = "init";
    Queue<String> requiredStack = new Queue();
    Queue<Token> _tokens = new JsonTokenizer(json).tokens;

    while (_tokens.isNotEmpty) {
      Token token = _tokens.removeFirst();

      if (_tokens.length == 1 && token.type == "value-separator") {
        throw new ArgumentError("Unexpected token: ${token.value}");
      }

      var stateOptions = stateMap[state];
      var required = stateOptions["required"];
      if (required != null) {
        requiredStack.addFirst(required);
      }
      var optional = stateOptions["optional"];
      if (optional != null && optional[token.type] != null && (optional[token.type]["validator"] == null || optional[token.type]["validator"](token))) {
        var nextState = optional[token.type]["state"];
        if (nextState is Function) {
          state = nextState(requiredStack, token);
        } else {
          state = nextState;
        }
      } else if (requiredStack.first == token.type){
        state = requiredStack.removeFirst();
      } else {
        throw new ArgumentError("Unexpected token: ${token.value}");
      }
    }
    return true;
  }
}