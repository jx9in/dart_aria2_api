import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
import 'package:path/path.dart' as p;
import 'package:aria2_api/aria2_api.dart';

const downloadLink = ''; // replace it before test
const host = '127.0.0.1';
const port = 6800;
const path = 'jsonrpc';
const secret = 'myaria2rpcpass';

final errorLink = Uri.https(
  'example.org',
  Uri.parse(downloadLink).pathSegments.last,
).toString();
final tmpDir = Directory(p.join(Directory.current.path, 'test', 'tmp'))
  ..createSync();
final option = Aria2InputFileOption(dir: tmpDir.path);

void main() {
  group('test method in http client', () {
    late Aria2HttpClient client;

    setUp(() {
      client = Aria2HttpClient(
        host: host,
        port: port,
        path: path,
        secret: secret,
        func: Aria2HttpFunction.post,
      );
    });

    tearDown(() async {
      await client.purgeDownloadResult();
      await client.disconnect();
      await Future.delayed(const Duration(milliseconds: 100));
      await tmpDir.list().forEach((e) async => await e.delete(recursive: true));
    });

    test('aria2.addUri', () async {
      final response = await client.addUri([downloadLink], option);
      expect(response.asMethod?.data.asStringData, isNotNull);
      final gid = response.asMethod!.data.asStringData!.value;
      await client.forceRemove(gid);
    });

    test('aria2.addTorrent', () {
      // TODO: implement
    }, skip: true);

    test('aria2.addMetalink', () async {
      // TODO: implement
    }, skip: true);

    test('aria2.remove', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.remove(addGid);
      expect(
        response.asMethod?.data.asStringData?.value,
        allOf(isNotNull, equals(addGid)),
      );
    });

    test('aria2.forceRemove', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.forceRemove(addGid);
      expect(
        response.asMethod?.data.asStringData?.value,
        allOf(isNotNull, equals(addGid)),
      );
    });

    test('aria2.pause', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.pause(addGid);
      expect(
        response.asMethod?.data.asStringData?.value,
        allOf(isNotNull, equals(addGid)),
      );
      await client.forceRemove(addGid);
    });

    test('aria2.pauseAll', () async {
      final response = await client.pauseAll();
      expect(response.asMethod?.data.asStringData, isNotNull);
    });

    test('aria2.forcePause', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.forcePause(addGid);
      expect(
        response.asMethod?.data.asStringData?.value,
        allOf(isNotNull, equals(addGid)),
      );
      await client.forceRemove(addGid);
    });

    test('aria2.forcePauseAll', () async {
      final response = await client.forcePauseAll();
      expect(response.asMethod?.data.asStringData, isNotNull);
    });

    test('aria2.unpause', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final fPause = await client.forcePause(addGid);
      expect(
        fPause.asMethod?.data.asStringData?.value,
        allOf(isNotNull, equals(addGid)),
      );
      final response = await client.unpause(addGid);
      expect(
        response.asMethod?.data.asStringData?.value,
        allOf(isNotNull, equals(addGid)),
      );
    });

    test('aria2.unpauseAll', () async {
      final response = await client.unpauseAll();
      expect(response.asMethod?.data.asStringData?.value, isNotNull);
    });

    test('aria2.tellStatus', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.tellStatus(
        addGid,
        Aria2DownloadingStatusObject.buildKeys(gid: true, status: true),
      );
      expect(
        response.asMethod?.data.asObjectData?.value.asStatusObject,
        isNotNull,
      );
      await client.forceRemove(addGid);
    });

    test('aria2.getUris', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.getUris(addGid);
      expect(
        response.asMethod?.data.asListData?.value,
        allOf(
          isNotNull,
          anyOf(
            isEmpty,
            everyElement(
              isA<Aria2ObjectResponseData>().having(
                (e) => e.value.asUriObject,
                'isNotNull',
                isNotNull,
              ),
            ),
          ),
        ),
      );
      await client.forceRemove(addGid);
    });

    test('aria2.getFiles', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.getFiles(addGid);
      expect(
        response.asMethod?.data.asListData?.value,
        allOf(
          isNotNull,
          anyOf(
            isEmpty,
            everyElement(
              isA<Aria2ObjectResponseData>().having(
                (e) => e.value.asFileObject,
                'isNotNull',
                isNotNull,
              ),
            ),
          ),
        ),
      );
      await client.forceRemove(addGid);
    });

    test('aria2.getPeers', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.getPeers(addGid);
      expect(
        response.asMethod?.data.asListData?.value,
        allOf(
          isNotNull,
          anyOf(
            isEmpty,
            everyElement(
              isA<Aria2ObjectResponseData>().having(
                (e) => e.value.asPeerObject,
                'isNotNull',
                isNotNull,
              ),
            ),
          ),
        ),
      );
      await client.forceRemove(addGid);
    });

    test('aria2.getServers', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.getServers(addGid);
      expect(
        response.asMethod?.data.asListData?.value,
        allOf(
          isNotNull,
          anyOf(
            isEmpty,
            everyElement(
              isA<Aria2ObjectResponseData>().having(
                (e) => e.value.asServerObject,
                'isNotNull',
                isNotNull,
              ),
            ),
          ),
        ),
      );
      await client.forceRemove(addGid);
    });

    test('aria2.tellActive', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.tellActive(
        Aria2DownloadingStatusObject.buildKeys(gid: true, status: true),
      );
      expect(
        response.asMethod?.data.asListData?.value,
        allOf(
          isNotNull,
          anyOf(
            isEmpty,
            everyElement(
              isA<Aria2ObjectResponseData>().having(
                (e) => e.value.asStatusObject,
                'isNotNull',
                isNotNull,
              ),
            ),
          ),
        ),
      );
      await client.forceRemove(addGid);
    });

    test('aria2.tellWaiting', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final fPause = await client.forcePause(addGid);
      expect(
        fPause.asMethod?.data.asStringData?.value,
        allOf(isNotNull, equals(addGid)),
      );
      final response = await client.tellWaiting(
        0,
        10,
        Aria2DownloadingStatusObject.buildKeys(gid: true, status: true),
      );
      expect(
        response.asMethod?.data.asListData?.value,
        allOf(
          isNotNull,
          anyOf(
            isEmpty,
            everyElement(
              isA<Aria2ObjectResponseData>().having(
                (e) => e.value.asStatusObject,
                'isNotNull',
                isNotNull,
              ),
            ),
          ),
        ),
      );
      await client.forceRemove(addGid);
    });

    test('aria2.tellStopped', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final fRemove = await client.forceRemove(addGid);
      expect(
        fRemove.asMethod?.data.asStringData?.value,
        allOf(isNotNull, equals(addGid)),
      );
      final response = await client.tellStopped(
        0,
        10,
        Aria2DownloadingStatusObject.buildKeys(gid: true, status: true),
      );
      expect(
        response.asMethod?.data.asListData?.value,
        allOf(
          isNotNull,
          anyOf(
            isEmpty,
            everyElement(
              isA<Aria2ObjectResponseData>().having(
                (e) => e.value.asStatusObject,
                'isNotNull',
                isNotNull,
              ),
            ),
          ),
        ),
      );
    });

    test('aria2.changePosition', () async {
      final globalOption = await client.getGlobalOption();
      expect(
        globalOption.asMethod?.data.asObjectData?.value.asOptionObject,
        isNotNull,
      );
      final concurrent = globalOption
          .asMethod
          ?.data
          .asObjectData
          ?.value
          .asOptionObject
          ?.maxConcurrentDownloads;

      await client.changeGlobalOption(
        Aria2OptionObject.global(maxConcurrentDownloads: 1),
      );

      final addList = await Future.wait([
        client.addUri([downloadLink], option),
        client.addUri([downloadLink], option),
        client.addUri([downloadLink], option),
        client.addUri([downloadLink], option),
        client.addUri([downloadLink], option),
      ]);

      final waiting = await client.tellWaiting(
        0,
        10,
        Aria2DownloadingStatusObject.buildKeys(gid: true),
      );
      expect(waiting.asMethod?.data.asListData?.value.firstOrNull, isNotNull);
      final waitingGid = waiting
          .asMethod!
          .data
          .asListData!
          .value
          .first
          .asObjectData!
          .value
          .asStatusObject!
          .gid!;

      final response = await client.changePosition(
        waitingGid,
        0,
        Aria2PositionSymbol.posSet,
      );
      expect(
        response.asMethod?.data.asIntegerData?.value,
        allOf(isNotNull, equals(0)),
      );

      await client.changeGlobalOption(
        Aria2OptionObject.global(maxConcurrentDownloads: concurrent),
      );
      for (final i in addList) {
        await client.forceRemove(i.asMethod!.data.asStringData!.value);
      }
    });

    test('aria2.changeUri', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      await Future.delayed(const Duration(seconds: 2));
      final response = await client.changeUri(
        addGid,
        1,
        [downloadLink, downloadLink],
        [errorLink],
      );
      expect(
        response.asMethod?.data.asListData?.value,
        allOf(isNotNull, hasLength(2)),
      );
      await client.forceRemove(addGid);
    });

    test('aria2.getOption', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.getOption(addGid);
      expect(
        response.asMethod?.data.asObjectData?.value.asOptionObject,
        isNotNull,
      );
      await client.forceRemove(addGid);
    });

    test('aria2.changeOption', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.changeOption(
        addGid,
        Aria2OptionObject(timeout: 30),
      );
      expect(response.asMethod?.data.asStringData, isNotNull);
      await client.forceRemove(addGid);
    });

    test('aria2.getGlobalOption', () async {
      final response = await client.getGlobalOption();
      expect(
        response.asMethod?.data.asObjectData?.value.asOptionObject,
        isNotNull,
      );
    });

    test('aria2.changeGlobalOption', () async {
      final response = await client.changeGlobalOption(
        Aria2OptionObject(timeout: 60),
      );
      expect(response.asMethod?.data.asStringData, isNotNull);
    });

    test('aria2.getGlobalStat', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.getGlobalStat();
      expect(
        response.asMethod?.data.asObjectData?.value.asStatObject,
        isNotNull,
      );
      await client.forceRemove(addGid);
    });

    test('aria2.purgeDownloadResult', () async {
      final response = await client.purgeDownloadResult();
      expect(response.asMethod?.data.asStringData, isNotNull);
    });

    test('aria2.removeDownloadResult', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final fRemove = await client.forceRemove(addGid);
      expect(
        fRemove.asMethod?.data.asStringData?.value,
        allOf(isNotNull, equals(addGid)),
      );
      final response = await client.removeDownloadResult(addGid);
      expect(response.asMethod?.data.asStringData, isNotNull);
    });

    test('aria2.getVersion', () async {
      final response = await client.getVersion();
      expect(
        response.asMethod?.data.asObjectData?.value.asVersionObject,
        isNotNull,
      );
    });

    test('aria2.getSessionInfo', () async {
      final response = await client.getSessionInfo();
      expect(
        response.asMethod?.data.asObjectData?.value.asSessionInfoObject,
        isNotNull,
      );
    });

    test('aria2.saveSession', () async {
      final response = await client.saveSession();
      expect(response.asMethod?.data.asStringData, isNotNull);
    });

    test('system.multicall', () async {
      final methods = [
        // error
        Aria2Method(Aria2MethodName.addTorrent, Aria2ParameterBuilder.empty()),
        // string
        Aria2Method(
          Aria2MethodName.addUri,
          Aria2ParameterBuilder.normal([
            [downloadLink],
            option.parametrized,
          ]),
        ),
        // object list
        Aria2Method(
          Aria2MethodName.tellStopped,
          Aria2ParameterBuilder.normal([
            0,
            20,
            Aria2DownloadingStatusObject.buildKeys(gid: true, status: true),
          ]),
        ),
        // object
        Aria2Method(Aria2MethodName.getVersion, Aria2ParameterBuilder.empty()),
      ];

      final response = await client.multicall(methods);
      expect(response.asMethod?.data.asListData?.value, isNotNull);
      final list = response.asMethod!.data.asListData!.value;
      expect(list, hasLength(methods.length));

      // error
      expect(list[0].asObjectData?.value.asErrorObject, isNotNull);
      // string
      expect(list[1].asListData?.value.firstOrNull?.asStringData, isNotNull);
      final addGid = list[1].asListData!.value.first.asStringData!.value;
      await client.forceRemove(addGid);
      // object list
      expect(
        list[2].asListData?.value.firstOrNull?.asListData?.value,
        allOf(
          isNotNull,
          anyOf(isEmpty, everyElement(isA<Aria2DownloadingStatusObject>())),
        ),
      );
      // object
      expect(
        list[3]
            .asListData
            ?.value
            .firstOrNull
            ?.asObjectData
            ?.value
            .asVersionObject,
        isNotNull,
      );
    });

    test('batch call', () async {
      final methods = [
        // error
        Aria2Method(Aria2MethodName.addTorrent, Aria2ParameterBuilder.empty()),
        // string
        Aria2Method(
          Aria2MethodName.addUri,
          Aria2ParameterBuilder.normal([
            [downloadLink],
            option.parametrized,
          ]),
        ),
        // object list
        Aria2Method(
          Aria2MethodName.tellStopped,
          Aria2ParameterBuilder.normal([
            0,
            20,
            Aria2DownloadingStatusObject.buildKeys(gid: true, status: true),
          ]),
        ),
        // object
        Aria2Method(Aria2MethodName.getVersion, Aria2ParameterBuilder.empty()),
      ];

      final list = await client.batchCall(methods);
      expect(list, hasLength(methods.length));

      // error
      expect(
        list[0].asMethod?.data.asObjectData?.value.asErrorObject,
        isNotNull,
      );
      // string
      expect(list[1].asMethod?.data.asStringData, isNotNull);
      final addGid = list[1].asMethod!.data.asStringData!.value;
      await client.forceRemove(addGid);
      // object list
      expect(
        list[2].asMethod?.data.asListData?.value,
        allOf(
          isNotNull,
          anyOf(
            isEmpty,
            everyElement(
              isA<Aria2ObjectResponseData>().having(
                (e) => e.value,
                'Aria2DownloadingStatusObject',
                isA<Aria2DownloadingStatusObject>(),
              ),
            ),
          ),
        ),
      );
      // object
      expect(
        list[3].asMethod?.data.asObjectData?.value.asVersionObject,
        isNotNull,
      );
    });

    test('system.listMethods', () async {
      final response = await client.listMethods();
      expect(
        response.asMethod?.data.asListData?.value,
        allOf(
          isNotNull,
          isNotEmpty,
          everyElement(isA<Aria2StringResponseData>()),
        ),
      );
    });

    test('system.listNotifications', () async {
      final response = await client.listNotifications();
      expect(
        response.asMethod?.data.asListData?.value,
        allOf(
          isNotNull,
          isNotEmpty,
          everyElement(isA<Aria2StringResponseData>()),
        ),
      );
    });

    // test('aria2.shutdown', () async {
    //   final response = await client.shutdown();
    //   expect(response.asMethod?.data.asStringData, isNotNull);
    // });

    // test('aria2.forceShutdown', () async {
    //   final response = await client.forceShutdown();
    //   expect(response.asMethod?.data.asStringData, isNotNull);
    // });
  });

  group('test method in websocket client', () {
    late Aria2WebSocketClient client;

    setUp(() {
      client = Aria2WebSocketClient(
        host: host,
        port: port,
        path: path,
        secret: secret,
      );
    });

    tearDown(() async {
      await client.purgeDownloadResult();
      await client.disconnect(code: 1000);
      await Future.delayed(const Duration(milliseconds: 100));
      await tmpDir.list().forEach((e) async => await e.delete(recursive: true));
    });

    test('aria2.addUri', () async {
      final response = await client.addUri([downloadLink], option);
      expect(response.asMethod?.data.asStringData, isNotNull);
      final gid = response.asMethod!.data.asStringData!.value;
      await client.forceRemove(gid);
    });

    test('aria2.addTorrent', () {
      // TODO: implement
    }, skip: true);

    test('aria2.addMetalink', () async {
      // TODO: implement
    }, skip: true);

    test('aria2.remove', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.remove(addGid);
      expect(
        response.asMethod?.data.asStringData?.value,
        allOf(isNotNull, equals(addGid)),
      );
    });

    test('aria2.forceRemove', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.forceRemove(addGid);
      expect(
        response.asMethod?.data.asStringData?.value,
        allOf(isNotNull, equals(addGid)),
      );
    });

    test('aria2.pause', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.pause(addGid);
      expect(
        response.asMethod?.data.asStringData?.value,
        allOf(isNotNull, equals(addGid)),
      );
      await client.forceRemove(addGid);
    });

    test('aria2.pauseAll', () async {
      final response = await client.pauseAll();
      expect(response.asMethod?.data.asStringData, isNotNull);
    });

    test('aria2.forcePause', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.forcePause(addGid);
      expect(
        response.asMethod?.data.asStringData?.value,
        allOf(isNotNull, equals(addGid)),
      );
      await client.forceRemove(addGid);
    });

    test('aria2.forcePauseAll', () async {
      final response = await client.forcePauseAll();
      expect(response.asMethod?.data.asStringData, isNotNull);
    });

    test('aria2.unpause', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final fPause = await client.forcePause(addGid);
      expect(
        fPause.asMethod?.data.asStringData?.value,
        allOf(isNotNull, equals(addGid)),
      );
      final response = await client.unpause(addGid);
      expect(
        response.asMethod?.data.asStringData?.value,
        allOf(isNotNull, equals(addGid)),
      );
    });

    test('aria2.unpauseAll', () async {
      final response = await client.unpauseAll();
      expect(response.asMethod?.data.asStringData?.value, isNotNull);
    });

    test('aria2.tellStatus', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.tellStatus(
        addGid,
        Aria2DownloadingStatusObject.buildKeys(gid: true, status: true),
      );
      expect(
        response.asMethod?.data.asObjectData?.value.asStatusObject,
        isNotNull,
      );
      await client.forceRemove(addGid);
    });

    test('aria2.getUris', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.getUris(addGid);
      expect(
        response.asMethod?.data.asListData?.value,
        allOf(
          isNotNull,
          anyOf(
            isEmpty,
            everyElement(
              isA<Aria2ObjectResponseData>().having(
                (e) => e.value.asUriObject,
                'isNotNull',
                isNotNull,
              ),
            ),
          ),
        ),
      );
      await client.forceRemove(addGid);
    });

    test('aria2.getFiles', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.getFiles(addGid);
      expect(
        response.asMethod?.data.asListData?.value,
        allOf(
          isNotNull,
          anyOf(
            isEmpty,
            everyElement(
              isA<Aria2ObjectResponseData>().having(
                (e) => e.value.asFileObject,
                'isNotNull',
                isNotNull,
              ),
            ),
          ),
        ),
      );
      await client.forceRemove(addGid);
    });

    test('aria2.getPeers', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.getPeers(addGid);
      expect(
        response.asMethod?.data.asListData?.value,
        allOf(
          isNotNull,
          anyOf(
            isEmpty,
            everyElement(
              isA<Aria2ObjectResponseData>().having(
                (e) => e.value.asPeerObject,
                'isNotNull',
                isNotNull,
              ),
            ),
          ),
        ),
      );
      await client.forceRemove(addGid);
    });

    test('aria2.getServers', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.getServers(addGid);
      expect(
        response.asMethod?.data.asListData?.value,
        allOf(
          isNotNull,
          anyOf(
            isEmpty,
            everyElement(
              isA<Aria2ObjectResponseData>().having(
                (e) => e.value.asServerObject,
                'isNotNull',
                isNotNull,
              ),
            ),
          ),
        ),
      );
      await client.forceRemove(addGid);
    });

    test('aria2.tellActive', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.tellActive(
        Aria2DownloadingStatusObject.buildKeys(gid: true, status: true),
      );
      expect(
        response.asMethod?.data.asListData?.value,
        allOf(
          isNotNull,
          anyOf(
            isEmpty,
            everyElement(
              isA<Aria2ObjectResponseData>().having(
                (e) => e.value.asStatusObject,
                'isNotNull',
                isNotNull,
              ),
            ),
          ),
        ),
      );
      await client.forceRemove(addGid);
    });

    test('aria2.tellWaiting', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final fPause = await client.forcePause(addGid);
      expect(
        fPause.asMethod?.data.asStringData?.value,
        allOf(isNotNull, equals(addGid)),
      );
      final response = await client.tellWaiting(
        0,
        10,
        Aria2DownloadingStatusObject.buildKeys(gid: true, status: true),
      );
      expect(
        response.asMethod?.data.asListData?.value,
        allOf(
          isNotNull,
          anyOf(
            isEmpty,
            everyElement(
              isA<Aria2ObjectResponseData>().having(
                (e) => e.value.asStatusObject,
                'isNotNull',
                isNotNull,
              ),
            ),
          ),
        ),
      );
      await client.forceRemove(addGid);
    });

    test('aria2.tellStopped', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final fRemove = await client.forceRemove(addGid);
      expect(
        fRemove.asMethod?.data.asStringData?.value,
        allOf(isNotNull, equals(addGid)),
      );
      final response = await client.tellStopped(
        0,
        10,
        Aria2DownloadingStatusObject.buildKeys(gid: true, status: true),
      );
      expect(
        response.asMethod?.data.asListData?.value,
        allOf(
          isNotNull,
          anyOf(
            isEmpty,
            everyElement(
              isA<Aria2ObjectResponseData>().having(
                (e) => e.value.asStatusObject,
                'isNotNull',
                isNotNull,
              ),
            ),
          ),
        ),
      );
    });

    test('aria2.changePosition', () async {
      final globalOption = await client.getGlobalOption();
      expect(
        globalOption.asMethod?.data.asObjectData?.value.asOptionObject,
        isNotNull,
      );
      final concurrent = globalOption
          .asMethod
          ?.data
          .asObjectData
          ?.value
          .asOptionObject
          ?.maxConcurrentDownloads;

      await client.changeGlobalOption(
        Aria2OptionObject.global(maxConcurrentDownloads: 1),
      );

      final addList = await Future.wait([
        client.addUri([downloadLink], option),
        client.addUri([downloadLink], option),
        client.addUri([downloadLink], option),
        client.addUri([downloadLink], option),
        client.addUri([downloadLink], option),
      ]);

      final waiting = await client.tellWaiting(
        0,
        10,
        Aria2DownloadingStatusObject.buildKeys(gid: true),
      );
      expect(waiting.asMethod?.data.asListData?.value.firstOrNull, isNotNull);
      final waitingGid = waiting
          .asMethod!
          .data
          .asListData!
          .value
          .first
          .asObjectData!
          .value
          .asStatusObject!
          .gid!;

      final response = await client.changePosition(
        waitingGid,
        0,
        Aria2PositionSymbol.posSet,
      );
      expect(
        response.asMethod?.data.asIntegerData?.value,
        allOf(isNotNull, equals(0)),
      );

      await client.changeGlobalOption(
        Aria2OptionObject.global(maxConcurrentDownloads: concurrent),
      );
      for (final i in addList) {
        await client.forceRemove(i.asMethod!.data.asStringData!.value);
      }
    });

    test('aria2.changeUri', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      await Future.delayed(const Duration(seconds: 2));
      final response = await client.changeUri(
        addGid,
        1,
        [downloadLink, downloadLink],
        [errorLink],
      );
      expect(
        response.asMethod?.data.asListData?.value,
        allOf(isNotNull, hasLength(2)),
      );
      await client.forceRemove(addGid);
    });

    test('aria2.getOption', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.getOption(addGid);
      expect(
        response.asMethod?.data.asObjectData?.value.asOptionObject,
        isNotNull,
      );
      await client.forceRemove(addGid);
    });

    test('aria2.changeOption', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.changeOption(
        addGid,
        Aria2OptionObject(timeout: 30),
      );
      expect(response.asMethod?.data.asStringData, isNotNull);
      await client.forceRemove(addGid);
    });

    test('aria2.getGlobalOption', () async {
      final response = await client.getGlobalOption();
      expect(
        response.asMethod?.data.asObjectData?.value.asOptionObject,
        isNotNull,
      );
    });

    test('aria2.changeGlobalOption', () async {
      final response = await client.changeGlobalOption(
        Aria2OptionObject(timeout: 60),
      );
      expect(response.asMethod?.data.asStringData, isNotNull);
    });

    test('aria2.getGlobalStat', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final response = await client.getGlobalStat();
      expect(
        response.asMethod?.data.asObjectData?.value.asStatObject,
        isNotNull,
      );
      await client.forceRemove(addGid);
    });

    test('aria2.purgeDownloadResult', () async {
      final response = await client.purgeDownloadResult();
      expect(response.asMethod?.data.asStringData, isNotNull);
    });

    test('aria2.removeDownloadResult', () async {
      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      final fRemove = await client.forceRemove(addGid);
      expect(
        fRemove.asMethod?.data.asStringData?.value,
        allOf(isNotNull, equals(addGid)),
      );
      final response = await client.removeDownloadResult(addGid);
      expect(response.asMethod?.data.asStringData, isNotNull);
    });

    test('aria2.getVersion', () async {
      final response = await client.getVersion();
      expect(
        response.asMethod?.data.asObjectData?.value.asVersionObject,
        isNotNull,
      );
    });

    test('aria2.getSessionInfo', () async {
      final response = await client.getSessionInfo();
      expect(
        response.asMethod?.data.asObjectData?.value.asSessionInfoObject,
        isNotNull,
      );
    });

    test('aria2.saveSession', () async {
      final response = await client.saveSession();
      expect(response.asMethod?.data.asStringData, isNotNull);
    });

    test('system.multicall', () async {
      final methods = [
        // error
        Aria2Method(Aria2MethodName.addTorrent, Aria2ParameterBuilder.empty()),
        // string
        Aria2Method(
          Aria2MethodName.addUri,
          Aria2ParameterBuilder.normal([
            [downloadLink],
            option.parametrized,
          ]),
        ),
        // object list
        Aria2Method(
          Aria2MethodName.tellStopped,
          Aria2ParameterBuilder.normal([
            0,
            20,
            Aria2DownloadingStatusObject.buildKeys(gid: true, status: true),
          ]),
        ),
        // object
        Aria2Method(Aria2MethodName.getVersion, Aria2ParameterBuilder.empty()),
      ];

      final response = await client.multicall(methods);
      expect(response.asMethod?.data.asListData?.value, isNotNull);
      final list = response.asMethod!.data.asListData!.value;
      expect(list, hasLength(methods.length));

      // error
      expect(list[0].asObjectData?.value.asErrorObject, isNotNull);
      // string
      expect(list[1].asListData?.value.firstOrNull?.asStringData, isNotNull);
      final addGid = list[1].asListData!.value.first.asStringData!.value;
      await client.forceRemove(addGid);
      // object list
      expect(
        list[2].asListData?.value.firstOrNull?.asListData?.value,
        allOf(
          isNotNull,
          anyOf(isEmpty, everyElement(isA<Aria2DownloadingStatusObject>())),
        ),
      );
      // object
      expect(
        list[3]
            .asListData
            ?.value
            .firstOrNull
            ?.asObjectData
            ?.value
            .asVersionObject,
        isNotNull,
      );
    });

    test('batch call', () async {
      final methods = [
        // error
        Aria2Method(Aria2MethodName.addTorrent, Aria2ParameterBuilder.empty()),
        // string
        Aria2Method(
          Aria2MethodName.addUri,
          Aria2ParameterBuilder.normal([
            [downloadLink],
            option.parametrized,
          ]),
        ),
        // object list
        Aria2Method(
          Aria2MethodName.tellStopped,
          Aria2ParameterBuilder.normal([
            0,
            20,
            Aria2DownloadingStatusObject.buildKeys(gid: true, status: true),
          ]),
        ),
        // object
        Aria2Method(Aria2MethodName.getVersion, Aria2ParameterBuilder.empty()),
      ];

      final list = await client.batchCall(methods);
      expect(list, hasLength(methods.length));

      // error
      expect(
        list[0].asMethod?.data.asObjectData?.value.asErrorObject,
        isNotNull,
      );
      // string
      expect(list[1].asMethod?.data.asStringData, isNotNull);
      final addGid = list[1].asMethod!.data.asStringData!.value;
      await client.forceRemove(addGid);
      // object list
      expect(
        list[2].asMethod?.data.asListData?.value,
        allOf(
          isNotNull,
          anyOf(
            isEmpty,
            everyElement(
              isA<Aria2ObjectResponseData>().having(
                (e) => e.value,
                'Aria2DownloadingStatusObject',
                isA<Aria2DownloadingStatusObject>(),
              ),
            ),
          ),
        ),
      );
      // object
      expect(
        list[3].asMethod?.data.asObjectData?.value.asVersionObject,
        isNotNull,
      );
    });

    test('system.listMethods', () async {
      final response = await client.listMethods();
      expect(
        response.asMethod?.data.asListData?.value,
        allOf(
          isNotNull,
          isNotEmpty,
          everyElement(isA<Aria2StringResponseData>()),
        ),
      );
    });

    test('system.listNotifications', () async {
      final response = await client.listNotifications();
      expect(
        response.asMethod?.data.asListData?.value,
        allOf(
          isNotNull,
          isNotEmpty,
          everyElement(isA<Aria2StringResponseData>()),
        ),
      );
    });

    // test('aria2.shutdown', () async {
    //   final response = await client.shutdown();
    //   expect(response.asMethod?.data.asStringData, isNotNull);
    // });

    // test('aria2.forceShutdown', () async {
    //   final response = await client.forceShutdown();
    //   expect(response.asMethod?.data.asStringData, isNotNull);
    // });
  });

  group('test error', () {
    test('http client error', () async {
      final client = Aria2HttpClient(
        host: '127.0.0.1',
        port: 10020,
        func: Aria2HttpFunction.post,
      );
      final response = await client.addUri([downloadLink]);
      expect(response.asFault, isNotNull);
      await client.disconnect();
    });

    test('websocket client error', () async {
      final client = Aria2WebSocketClient(host: '127.0.0.1', port: 10020);
      final response = await client.addUri([downloadLink]);
      expect(response.asFault, isNotNull);
      await client.disconnect();
    });

    test('aria2 error', () async {
      final client = Aria2HttpClient(
        host: host,
        port: port,
        path: path,
        secret: secret,
        func: Aria2HttpFunction.post,
      );
      final response = await client.addUri([]);
      expect(
        response.asMethod?.data.asObjectData?.value.asErrorObject,
        isNotNull,
      );
      await client.disconnect();
    });
  });

  group('test notification', () {
    late Aria2WebSocketClient client;

    setUp(() {
      client = Aria2WebSocketClient(
        host: host,
        port: port,
        path: path,
        secret: secret,
      );
    });

    tearDown(() async {
      await client.purgeDownloadResult();
      await client.disconnect();
      await tmpDir.list().forEach((e) async => await e.delete(recursive: true));
    });

    test('aria2.onDownloadStart', () async {
      final storage = <String>[];
      final subscription = client.notification.listen((e) {
        if (e.method == Aria2NotificationName.onDownloadStart) {
          final list = e.data.asNotificationData?.value
              .map((f) => f.gid)
              .toList();
          if (list != null) storage.addAll(list);
        }
      });

      final response = await client.addUri([downloadLink], option);
      expect(response.asMethod?.data.asStringData, isNotNull);
      final gid = response.asMethod!.data.asStringData!.value;
      await Future.delayed(const Duration(milliseconds: 200));
      expect(storage, contains(gid));

      await subscription.cancel();
      await client.forceRemove(gid);
    });

    test('aria2.onDownloadPause', () async {
      final storage = <String>[];
      final subscription = client.notification.listen((e) {
        if (e.method == Aria2NotificationName.onDownloadPause) {
          final list = e.data.asNotificationData?.value
              .map((f) => f.gid)
              .toList();
          if (list != null) storage.addAll(list);
        }
      });

      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      await Future.delayed(const Duration(milliseconds: 200));
      final pause = await client.pause(addGid);
      expect(pause.asMethod?.data.asStringData, isNotNull);
      final pauseGid = pause.asMethod!.data.asStringData!.value;
      await Future.delayed(const Duration(milliseconds: 200));
      expect(storage, contains(pauseGid));

      await subscription.cancel();
      await client.forceRemove(addGid);
    });

    test('aria2.onDownloadStop', () async {
      final storage = <String>[];
      final subscription = client.notification.listen((e) {
        if (e.method == Aria2NotificationName.onDownloadStop) {
          final list = e.data.asNotificationData?.value
              .map((f) => f.gid)
              .toList();
          if (list != null) storage.addAll(list);
        }
      });

      final add = await client.addUri([downloadLink], option);
      expect(add.asMethod?.data.asStringData, isNotNull);
      final addGid = add.asMethod!.data.asStringData!.value;
      await Future.delayed(const Duration(milliseconds: 200));
      final remove = await client.remove(addGid);
      expect(remove.asMethod?.data.asStringData, isNotNull);
      final removeGid = remove.asMethod!.data.asStringData!.value;
      await Future.delayed(const Duration(milliseconds: 200));
      expect(storage, contains(removeGid));

      await subscription.cancel();
      await client.forceRemove(addGid);
    });

    test('aria2.onDownloadComplete', () async {
      final completer = Completer<void>();
      String? addGid;
      final subscription = client.notification.listen((e) {
        final list =
            e.data.asNotificationData?.value.map((f) => f.gid).toList() ??
            const [];
        if (addGid == null || !list.contains(addGid)) return;
        if (e.method == Aria2NotificationName.onDownloadComplete) {
          if (!completer.isCompleted) completer.complete();
        } else if (e.method == Aria2NotificationName.onDownloadError) {
          if (!completer.isCompleted) completer.completeError('Error');
        }
      });

      try {
        final add = await client.addUri([downloadLink], option);
        addGid = add.asMethod?.data.asStringData?.value;
        expect(addGid, isNotNull);

        await completer.future.timeout(const Duration(seconds: 30));
      } finally {
        await subscription.cancel();
      }
    });

    test('aria2.onDownloadError', () async {
      final completer = Completer<void>();
      String? addGid;
      final subscription = client.notification.listen((e) {
        final list =
            e.data.asNotificationData?.value.map((f) => f.gid).toList() ??
            const [];
        if (addGid == null || !list.contains(addGid)) return;
        if (e.method == Aria2NotificationName.onDownloadError) {
          if (!completer.isCompleted) completer.complete();
        } else if (e.method == Aria2NotificationName.onDownloadComplete) {
          if (!completer.isCompleted) completer.completeError('Not a error');
        }
      });

      try {
        final add = await client.addUri([downloadLink], option);
        expect(add.asMethod?.data.asStringData, isNotNull);
        addGid = add.asMethod!.data.asStringData!.value;
        await Future.delayed(const Duration(seconds: 2));
        final changeUri = await client.changeUri(
          addGid,
          1,
          [downloadLink, downloadLink],
          [errorLink],
        );
        // print(await client.tellStatus(addGid));
        expect(
          changeUri.asMethod?.data.asListData?.value,
          allOf(isNotNull, hasLength(2)),
        );

        await completer.future.timeout(const Duration(seconds: 30));
        await client.forceRemove(addGid);
      } finally {
        await subscription.cancel();
      }
    });

    test('aria2.onBtDownloadComplete', () {
      // TODO: implement
    }, skip: true);
  });
}
