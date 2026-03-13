import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aria2_api/src/enum.dart';
import 'package:aria2_api/src/object.dart';
import 'package:aria2_api/src/response.dart';
import 'package:aria2_api/src/struct.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const _uuid = Uuid();

abstract class Aria2Client {
  /// {@macro aria2_api.add_metalink}
  Future<Aria2ClientResponse> addMetalink(
    String metalink, [
    Aria2InputFileOption? option,
    int? position,
  ]) {
    assert(() {
      if (position != null) return position >= 0;
      return true;
    }());
    final content = base64.encode(utf8.encode(metalink));
    return call(
      Aria2Method(
        Aria2MethodName.addMetalink,
        Aria2ParameterBuilder.normal([
          content,
          ?(option?.parametrized),
          ?position,
        ]),
      ),
    );
  }

  /// {@macro aria2_api.add_torrent}
  Future<Aria2ClientResponse> addTorrent(
    String torrent, [
    List<String>? uris,
    Aria2InputFileOption? option,
    int? position,
  ]) {
    assert(() {
      if (position != null) return position >= 0;
      return true;
    }());
    final content = base64.encode(utf8.encode(torrent));
    return call(
      Aria2Method(
        Aria2MethodName.addTorrent,
        Aria2ParameterBuilder.normal([
          content,
          ?uris,
          ?(option?.parametrized),
          ?position,
        ]),
      ),
    );
  }

  /// {@macro aria2_api.add_uri}
  Future<Aria2ClientResponse> addUri(
    List<String> uris, [
    Aria2InputFileOption? option,
    int? position,
  ]) {
    assert(() {
      if (position != null) return position >= 0;
      return true;
    }());
    return call(
      Aria2Method(
        Aria2MethodName.addUri,
        Aria2ParameterBuilder.normal([
          uris,
          ?(option?.parametrized),
          ?position,
        ]),
      ),
    );
  }

  Future<List<Aria2ClientResponse>> batchCall(List<Aria2Method> methods);

  Future<Aria2ClientResponse> call(Aria2Method method);

  /// {@macro aria2_api.change_global_option}
  Future<Aria2ClientResponse> changeGlobalOption(Aria2OptionObject option) {
    return call(
      Aria2Method(
        Aria2MethodName.changeGlobalOption,
        Aria2ParameterBuilder.normal([option.parametrized]),
      ),
    );
  }

  /// {@macro aria2_api.change_option}
  Future<Aria2ClientResponse> changeOption(
    String gid,
    Aria2OptionObject option,
  ) {
    return call(
      Aria2Method(
        Aria2MethodName.changeOption,
        Aria2ParameterBuilder.normal([gid, option.parametrized]),
      ),
    );
  }

  /// {@macro aria2_api.change_position}
  Future<Aria2ClientResponse> changePosition(
    String gid,
    int pos,
    Aria2PositionSymbol how,
  ) {
    return call(
      Aria2Method(
        Aria2MethodName.changePosition,
        Aria2ParameterBuilder.normal([gid, pos, how.alias]),
      ),
    );
  }

  /// {@macro aria2_api.change_uri}
  Future<Aria2ClientResponse> changeUri(
    String gid,
    int fileIndex,
    List<String> delUris,
    List<String> addUris, [
    int? position,
  ]) {
    return call(
      Aria2Method(
        Aria2MethodName.changeUri,
        Aria2ParameterBuilder.normal([
          gid,
          fileIndex,
          delUris,
          addUris,
          ?position,
        ]),
      ),
    );
  }

  // It should only be overridden when a long-lived connection needs to be created.
  FutureOr<void> disconnect({int? code, String? reason}) {}

  /// {@macro aria2_api.force_pause}
  Future<Aria2ClientResponse> forcePause(String gid) {
    return call(
      Aria2Method(
        Aria2MethodName.forcePause,
        Aria2ParameterBuilder.normal([gid]),
      ),
    );
  }

  /// {@macro aria2_api.force_pause_all}
  Future<Aria2ClientResponse> forcePauseAll() {
    return call(
      Aria2Method(Aria2MethodName.forcePauseAll, Aria2ParameterBuilder.empty()),
    );
  }

  /// {@macro aria2_api.force_remove}
  Future<Aria2ClientResponse> forceRemove(String gid) {
    return call(
      Aria2Method(
        Aria2MethodName.forceRemove,
        Aria2ParameterBuilder.normal([gid]),
      ),
    );
  }

  /// {@macro aria2_api.force_shutdown}
  Future<Aria2ClientResponse> forceShutdown() {
    return call(
      Aria2Method(Aria2MethodName.forceShutdown, Aria2ParameterBuilder.empty()),
    );
  }

  /// {@macro aria2_api.get_files}
  Future<Aria2ClientResponse> getFiles(String gid) {
    return call(
      Aria2Method(
        Aria2MethodName.getFiles,
        Aria2ParameterBuilder.normal([gid]),
      ),
    );
  }

  /// {@macro aria2_api.get_global_option}
  Future<Aria2ClientResponse> getGlobalOption() {
    return call(
      Aria2Method(
        Aria2MethodName.getGlobalOption,
        Aria2ParameterBuilder.empty(),
      ),
    );
  }

  /// {@macro aria2_api.get_global_stat}
  Future<Aria2ClientResponse> getGlobalStat() {
    return call(
      Aria2Method(Aria2MethodName.getGlobalStat, Aria2ParameterBuilder.empty()),
    );
  }

  /// {@macro aria2_api.get_option}
  Future<Aria2ClientResponse> getOption(String gid) {
    return call(
      Aria2Method(
        Aria2MethodName.getOption,
        Aria2ParameterBuilder.normal([gid]),
      ),
    );
  }

  /// {@macro aria2_api.get_peers}
  Future<Aria2ClientResponse> getPeers(String gid) {
    return call(
      Aria2Method(
        Aria2MethodName.getPeers,
        Aria2ParameterBuilder.normal([gid]),
      ),
    );
  }

  /// {@macro aria2_api.get_servers}
  Future<Aria2ClientResponse> getServers(String gid) {
    return call(
      Aria2Method(
        Aria2MethodName.getServers,
        Aria2ParameterBuilder.normal([gid]),
      ),
    );
  }

  /// {@macro aria2_api.get_session_info}
  Future<Aria2ClientResponse> getSessionInfo() {
    return call(
      Aria2Method(
        Aria2MethodName.getSessionInfo,
        Aria2ParameterBuilder.empty(),
      ),
    );
  }

  /// {@macro aria2_api.get_uris}
  Future<Aria2ClientResponse> getUris(String gid) {
    return call(
      Aria2Method(Aria2MethodName.getUris, Aria2ParameterBuilder.normal([gid])),
    );
  }

  /// {@macro aria2_api.get_version}
  Future<Aria2ClientResponse> getVersion() {
    return call(
      Aria2Method(Aria2MethodName.getVersion, Aria2ParameterBuilder.empty()),
    );
  }

  /// {@macro aria2_api.list_methods}
  Future<Aria2ClientResponse> listMethods() {
    return call(
      Aria2Method(Aria2MethodName.listMethods, Aria2ParameterBuilder.empty()),
    );
  }

  /// {@macro aria2_api.list_notifications}
  Future<Aria2ClientResponse> listNotifications() {
    return call(
      Aria2Method(
        Aria2MethodName.listNotifications,
        Aria2ParameterBuilder.empty(),
      ),
    );
  }

  /// {@macro aria2_api.multicall}
  Future<Aria2ClientResponse> multicall(List<Aria2Method> methods) {
    return call(
      Aria2Method(
        Aria2MethodName.multicall,
        Aria2ParameterBuilder.multicall(methods),
      ),
    );
  }

  /// {@macro aria2_api.pause}
  Future<Aria2ClientResponse> pause(String gid) {
    return call(
      Aria2Method(Aria2MethodName.pause, Aria2ParameterBuilder.normal([gid])),
    );
  }

  /// {@macro aria2_api.pause_all}
  Future<Aria2ClientResponse> pauseAll() {
    return call(
      Aria2Method(Aria2MethodName.pauseAll, Aria2ParameterBuilder.empty()),
    );
  }

  /// {@macro aria2_api.purge_download_result}
  Future<Aria2ClientResponse> purgeDownloadResult() {
    return call(
      Aria2Method(
        Aria2MethodName.purgeDownloadResult,
        Aria2ParameterBuilder.empty(),
      ),
    );
  }

  /// {@macro aria2_api.remove}
  Future<Aria2ClientResponse> remove(String gid) {
    return call(
      Aria2Method(Aria2MethodName.remove, Aria2ParameterBuilder.normal([gid])),
    );
  }

  /// {@macro aria2_api.remove_download_result}
  Future<Aria2ClientResponse> removeDownloadResult(String gid) {
    return call(
      Aria2Method(
        Aria2MethodName.removeDownloadResult,
        Aria2ParameterBuilder.normal([gid]),
      ),
    );
  }

  /// {@macro aria2_api.save_session}
  Future<Aria2ClientResponse> saveSession() {
    return call(
      Aria2Method(Aria2MethodName.saveSession, Aria2ParameterBuilder.empty()),
    );
  }

  /// {@macro aria2_api.shutdown}
  Future<Aria2ClientResponse> shutdown() {
    return call(
      Aria2Method(Aria2MethodName.shutdown, Aria2ParameterBuilder.empty()),
    );
  }

  /// {@macro aria2_api.tell_active}
  Future<Aria2ClientResponse> tellActive([List<String>? keys]) {
    return call(
      Aria2Method(
        Aria2MethodName.tellActive,
        Aria2ParameterBuilder.normal([?keys]),
      ),
    );
  }

  /// {@macro aria2_api.tell_status}
  Future<Aria2ClientResponse> tellStatus(String gid, [List<String>? keys]) {
    return call(
      Aria2Method(
        Aria2MethodName.tellStatus,
        Aria2ParameterBuilder.normal([gid, ?keys]),
      ),
    );
  }

  /// {@macro aria2_api.tell_stopped}
  Future<Aria2ClientResponse> tellStopped(
    int offset,
    int number, [
    List<String>? keys,
  ]) {
    return call(
      Aria2Method(
        Aria2MethodName.tellStopped,
        Aria2ParameterBuilder.normal([offset, number, ?keys]),
      ),
    );
  }

  /// {@macro aria2_api.tell_waiting}
  Future<Aria2ClientResponse> tellWaiting(
    int offset,
    int number, [
    List<String>? keys,
  ]) {
    return call(
      Aria2Method(
        Aria2MethodName.tellWaiting,
        Aria2ParameterBuilder.normal([offset, number, ?keys]),
      ),
    );
  }

  /// {@macro aria2_api.unpause}
  Future<Aria2ClientResponse> unpause(String gid) {
    return call(
      Aria2Method(Aria2MethodName.unpause, Aria2ParameterBuilder.normal([gid])),
    );
  }

  /// {@macro aria2_api.unpause_all}
  Future<Aria2ClientResponse> unpauseAll() {
    return call(
      Aria2Method(Aria2MethodName.unpauseAll, Aria2ParameterBuilder.empty()),
    );
  }
}

class Aria2HttpClient extends Aria2Client {
  final Uri _uri;
  final _client = http.Client();
  final Aria2HttpFunction func;
  final String? secret;

  Aria2HttpClient({
    required String host,
    int? port,
    String? path,
    bool ssl = false,
    required this.func,
    this.secret,
  }) : _uri = Uri(
         scheme: ssl ? 'https' : 'http',
         host: host,
         port: port,
         path: path,
       );

  @override
  Future<List<Aria2ClientResponse>> batchCall(List<Aria2Method> methods) async {
    final pending = <String, Aria2Method>{};
    final requests = <Map<String, dynamic>>[];
    for (final method in methods) {
      final id = _uuid.v4();
      pending[id] = method;
      requests.add(_buildRequest(id, method));
    }

    try {
      final http.Response httpResponse;
      switch (func) {
        case Aria2HttpFunction.get:
          httpResponse = await _client.get(
            _uri.replace(query: jsonEncode(requests)),
          );
          break;
        case Aria2HttpFunction.post:
          httpResponse = await _client.post(_uri, body: jsonEncode(requests));
          break;
      }
      final json = jsonDecode(httpResponse.body);
      final responses = <Aria2MethodResponse>[];
      for (final i in json) {
        final id = i['id'];
        final method = pending.remove(id);
        if (method != null) {
          responses.add(Aria2MethodResponse.fromJson(method, i));
        }
      }
      return responses;
    } on Exception catch (e) {
      final response = Aria2FaultResponse(e);
      return [response];
    }
  }

  @override
  Future<Aria2ClientResponse> call(Aria2Method method) async {
    final id = _uuid.v4();
    final request = _buildRequest(id, method);

    try {
      final http.Response httpResponse;
      switch (func) {
        case Aria2HttpFunction.get:
          httpResponse = await _client.get(
            _uri.replace(queryParameters: request),
          );
          break;
        case Aria2HttpFunction.post:
          httpResponse = await _client.post(_uri, body: jsonEncode(request));
          break;
      }
      final json = jsonDecode(httpResponse.body);
      final response = Aria2MethodResponse.fromJson(method, json);
      return response;
    } on Exception catch (e) {
      final response = Aria2FaultResponse(e);
      return response;
    }
  }

  Map<String, dynamic> _buildRequest(String id, Aria2Method method) {
    final params = method.methodName.noRequireSecret
        ? method.params.buildParamList()
        : method.params.buildParamList(secret);
    switch (func) {
      case Aria2HttpFunction.get:
        return {
          'id': id,
          'method': method.methodName.alias,
          'params': base64Encode(utf8.encode(jsonEncode(params))),
        };
      case Aria2HttpFunction.post:
        return {
          'jsonrpc': '2.0',
          'id': id,
          'method': method.methodName.alias,
          'params': params,
        };
    }
  }
}

class Aria2WebSocketClient extends Aria2Client {
  final Uri _uri;
  final StreamController<Aria2Notification> _notificationController;
  bool _isChannelInitialized = false;
  late final WebSocketChannel _channel;
  Exception? _lastException;
  final String? secret;
  final _pending = <String, Aria2WebSocketPacket>{};

  Aria2WebSocketClient({
    required String host,
    int? port,
    String? path,
    bool ssl = false,
    this.secret,
    bool broadcastNotification = true,
  }) : _uri = Uri(
         scheme: ssl ? 'wss' : 'ws',
         host: host,
         port: port,
         path: path,
       ),
       _notificationController = broadcastNotification
           ? StreamController.broadcast()
           : StreamController();

  Stream<Aria2Notification> get notification => _notificationController.stream;

  @override
  Future<List<Aria2ClientResponse>> batchCall(List<Aria2Method> methods) async {
    try {
      _buildChannel();
      await _channel.ready;
    } on Exception catch (e) {
      _updateLastException(e);
      return [Aria2FaultResponse(e)];
    }
    if (_lastException != null) return [Aria2FaultResponse(_lastException!)];

    final futures = <Future<Aria2ClientResponse>>[];
    final requests = <Map<String, dynamic>>[];

    for (final method in methods) {
      final id = _uuid.v4();
      final completer = Completer<Aria2ClientResponse>();
      _pending[id] = Aria2WebSocketPacket(method, completer);
      futures.add(completer.future);
      requests.add(_buildRequest(id, method));
    }
    _channel.sink.add(jsonEncode(requests));
    return Future.wait(futures);
  }

  @override
  Future<Aria2ClientResponse> call(Aria2Method method) async {
    try {
      _buildChannel();
      await _channel.ready;
    } on Exception catch (e) {
      _updateLastException(e);
      return Aria2FaultResponse(e);
    }
    if (_lastException != null) return Aria2FaultResponse(_lastException!);

    final id = _uuid.v4();
    final completer = Completer<Aria2ClientResponse>();
    _pending[id] = Aria2WebSocketPacket(method, completer);
    final request = _buildRequest(id, method);
    _channel.sink.add(jsonEncode(request));
    return completer.future;
  }

  @override
  FutureOr<void> disconnect({int? code, String? reason}) async {
    if (_isChannelInitialized) {
      await _channel.sink.close(code, reason);
    }
    if (!_notificationController.isClosed) {
      await _notificationController.close();
    }
    _cleanUpPending(
      WebSocketChannelException.from(const SocketException.closed()),
    );
  }

  void _buildChannel() {
    if (!_isChannelInitialized) {
      _channel = WebSocketChannel.connect(_uri);
      _isChannelInitialized = true;
      _channel.stream.listen(
        (rawJson) {
          final json = jsonDecode(rawJson);
          if (json is List) {
            for (final i in json) {
              if (i is Map<String, dynamic>) {
                _handleData(i);
              }
            }
          } else if (json is Map<String, dynamic>) {
            _handleData(json);
          }
        },
        onError: (o) {
          _updateLastException(o);
          _cleanUpPending(o);
        },
        onDone: () => _cleanUpPending(
          WebSocketChannelException.from(const SocketException.closed()),
        ),
      );
    }
  }

  Map<String, dynamic> _buildRequest(String id, Aria2Method method) {
    final params = method.methodName.noRequireSecret
        ? method.params.buildParamList()
        : method.params.buildParamList(secret);
    return {
      'jsonrpc': '2.0',
      'id': id,
      'method': method.methodName.alias,
      'params': params,
    };
  }

  void _cleanUpPending(Exception e) {
    for (final packet in _pending.values) {
      if (!packet.isCompleted) packet.errorComplete(e);
    }
    _pending.clear();
  }

  void _handleData(Map<String, dynamic> json) {
    if (json.containsKey('id')) {
      final packet = _pending.remove(json['id']);
      if (packet != null) packet.methodComplete(json);
    } else if (json.containsKey('method')) {
      _notificationController.add(Aria2Notification.fromJson(json));
    }
  }

  void _updateLastException(Exception e) {
    if (_lastException != e) _lastException = e;
  }
}
