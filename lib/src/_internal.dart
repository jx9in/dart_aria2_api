mixin ClassConverterMixin<P> {
  T? asTOrNull<T extends P>() => switch (this) {
    T f => f,
    _ => null,
  };
}

mixin ValueGetterMixin<T> {
  T get value;
}

mixin AliasEnumMixin on Enum {
  String get alias;
}
