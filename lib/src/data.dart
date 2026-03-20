import 'package:aria2_api/src/_internal.dart';
import 'package:aria2_api/src/enum.dart';
import 'package:aria2_api/src/object.dart';
import 'package:aria2_api/src/struct.dart';
import 'package:collection/collection.dart';

class Aria2IntegerResponseData extends Aria2ResponseData
    with ValueGetterMixin<int> {
  final int _value;

  const Aria2IntegerResponseData(this._value);

  @override
  int get value => _value;

  @override
  String toString() {
    return value.toString();
  }
}

class Aria2ListResponseData extends Aria2ResponseData
    with ValueGetterMixin<List<Aria2ResponseData>> {
  final List<Aria2ResponseData> _value;

  const Aria2ListResponseData(this._value);

  factory Aria2ListResponseData.build(Aria2Method method, List json) {
    switch (method.methodName) {
      case Aria2MethodName.multicall:
        final params = method.params.value;
        assert(params is List<Aria2Method>, 'Wrong params: $params.');
        return Aria2ListResponseData(
          IterableZip([
            params,
            json,
          ]).map((e) => Aria2ResponseData.build(e[0], e[1])).toList(),
        );
      case _:
        return Aria2ListResponseData(
          json.map((e) => Aria2ResponseData.build(method, e)).toList(),
        );
    }
  }

  @override
  List<Aria2ResponseData> get value => _value;

  @override
  String toString() {
    return value.toString();
  }
}

class Aria2NotificationResponseData extends Aria2ResponseData
    implements ValueGetterMixin<List<Aria2NotificationObject>> {
  final List<Aria2NotificationObject> _value;

  const Aria2NotificationResponseData(this._value);

  factory Aria2NotificationResponseData.build(List json) {
    return Aria2NotificationResponseData(
      json.map((e) => Aria2NotificationObject.fromJson(e)).toList(),
    );
  }

  @override
  List<Aria2NotificationObject> get value => _value;

  @override
  String toString() {
    return value.toString();
  }
}

class Aria2ObjectResponseData extends Aria2ResponseData
    with ValueGetterMixin<Aria2TypedObject> {
  final Aria2TypedObject _value;

  const Aria2ObjectResponseData(this._value);

  Aria2ObjectResponseData.build(Map<String, dynamic> json)
    : this(Aria2TypedObject.build(json));

  @override
  Aria2TypedObject get value => _value;

  @override
  String toString() {
    return value.toString();
  }
}

sealed class Aria2ResponseData with ClassConverterMixin<Aria2ResponseData> {
  const Aria2ResponseData();

  factory Aria2ResponseData.build(Aria2Method method, dynamic json) {
    switch (json) {
      case String e:
        return Aria2StringResponseData(e);
      case int e:
        return Aria2IntegerResponseData(e);
      case List e:
        return Aria2ListResponseData.build(method, e);
      case Map<String, dynamic> e:
        final needsAlias = const {
          Aria2MethodName.tellStatus,
          Aria2MethodName.tellActive,
          Aria2MethodName.tellWaiting,
          Aria2MethodName.tellStopped,
        }.contains(method.methodName);

        // Aria2DownloadingStatusObject 和 Aria2OptionObject 有部分key重合，需要起一个别名
        if (needsAlias) {
          if (e.containsKey('gid')) e['gid_alias'] = e.remove('gid');
          if (e.containsKey('dir')) e['dir_alias'] = e.remove('dir');
        }
        return Aria2ObjectResponseData.build(e);
      case _:
        throw FormatException('Wrong json data.', json);
    }
  }
}

class Aria2StringResponseData extends Aria2ResponseData
    with ValueGetterMixin<String> {
  final String _value;

  const Aria2StringResponseData(this._value);

  @override
  String get value => _value;

  @override
  String toString() {
    return value.toString();
  }
}
