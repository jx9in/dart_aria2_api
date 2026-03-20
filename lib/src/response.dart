import 'package:aria2_api/src/_internal.dart';
import 'package:aria2_api/src/data.dart';
import 'package:aria2_api/src/enum.dart';
import 'package:aria2_api/src/helper.dart' show EnumByAlias;
import 'package:aria2_api/src/struct.dart';

sealed class Aria2ClientResponse with ClassConverterMixin<Aria2ClientResponse> {
  const Aria2ClientResponse();
}

class Aria2FaultResponse extends Aria2ClientResponse {
  final Exception exception;

  const Aria2FaultResponse(this.exception);

  @override
  String toString() {
    return (StringBuffer('$runtimeType(')
          ..write('exception: $exception')
          ..write(')'))
        .toString();
  }
}

class Aria2MethodResponse extends Aria2ClientResponse {
  final String id;
  final String jsonrpc;
  final Aria2ResponseData data;

  const Aria2MethodResponse({
    required this.id,
    required this.jsonrpc,
    required this.data,
  });

  factory Aria2MethodResponse.fromJson(
    Aria2Method method,
    Map<String, dynamic> json,
  ) {
    if (json.containsKey('id')) {
      if (json.containsKey('result')) {
        return Aria2MethodResponse(
          id: json['id'],
          jsonrpc: json['jsonrpc'] ?? '2.0',
          data: Aria2ResponseData.build(method, json['result']),
        );
      } else if (json.containsKey('error')) {
        return Aria2MethodResponse(
          id: json['id'],
          jsonrpc: json['jsonrpc'] ?? '2.0',
          data: Aria2ResponseData.build(method, json['error']),
        );
      }
    }

    throw FormatException('Wrong json data.', json);
  }

  @override
  String toString() {
    return (StringBuffer('$runtimeType(')
          ..writeAll(['id: $id', 'jsonrpc: $jsonrpc', 'value: $data'], ', ')
          ..write(')'))
        .toString();
  }
}

class Aria2Notification extends Aria2ClientResponse {
  final String jsonrpc;
  final Aria2NotificationName method;
  final Aria2NotificationResponseData data;

  const Aria2Notification({
    required this.jsonrpc,
    required this.method,
    required this.data,
  });

  factory Aria2Notification.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('method') && json.containsKey('params')) {
      return Aria2Notification(
        jsonrpc: json['jsonrpc'] ?? '2.0',
        method: Aria2NotificationName.values.byAlias(json['method']),
        data: Aria2NotificationResponseData.build(json['params']),
      );
    }

    throw FormatException('Wrong json data.', json);
  }

  @override
  String toString() {
    return (StringBuffer('$runtimeType(')
          ..writeAll([
            'jsonrpc: $jsonrpc',
            'method: $method',
            'data: $data',
          ], ', ')
          ..write(')'))
        .toString();
  }
}
