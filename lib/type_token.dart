part of easy_json;

class TypeToken<T> {
  Type get type => reflectType(T).reflectedType;
}