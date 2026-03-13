mixin ClassConverter<P> {
  T? asTOrNull<T extends P>() => switch (this) {
    T f => f,
    _ => null,
  };
}

mixin ResponseValue<T> {
  T get value;
}

mixin AliasEnum on Enum {
  String get alias;
}
