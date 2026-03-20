import 'package:aria2_api/src/_internal.dart';
import 'package:aria2_api/src/data.dart';
import 'package:aria2_api/src/object.dart';
import 'package:aria2_api/src/response.dart';

extension Aria2ClientResponseHelper on Aria2ClientResponse {
  Aria2FaultResponse? get asFault => asTOrNull<Aria2FaultResponse>();

  Aria2MethodResponse? get asMethod => asTOrNull<Aria2MethodResponse>();

  Aria2Notification? get asNotification => asTOrNull<Aria2Notification>();
}

extension Aria2ResponseDataHelper on Aria2ResponseData {
  Aria2IntegerResponseData? get asIntegerData =>
      asTOrNull<Aria2IntegerResponseData>();

  Aria2ListResponseData? get asListData => asTOrNull<Aria2ListResponseData>();

  Aria2NotificationResponseData? get asNotificationData =>
      asTOrNull<Aria2NotificationResponseData>();

  Aria2ObjectResponseData? get asObjectData =>
      asTOrNull<Aria2ObjectResponseData>();

  Aria2StringResponseData? get asStringData =>
      asTOrNull<Aria2StringResponseData>();
}

extension Aria2TypedObjectHelper on Aria2TypedObject {
  Aria2ErrorObject? get asErrorObject => asTOrNull<Aria2ErrorObject>();

  Aria2DownloadingFileObject? get asFileObject =>
      asTOrNull<Aria2DownloadingFileObject>();

  Aria2NotificationObject? get asNotificationObject =>
      asTOrNull<Aria2NotificationObject>();

  Aria2OptionObject? get asOptionObject => asTOrNull<Aria2OptionObject>();

  Aria2DownloadingPeerObject? get asPeerObject =>
      asTOrNull<Aria2DownloadingPeerObject>();

  Aria2LinkedServerObject? get asServerObject =>
      asTOrNull<Aria2LinkedServerObject>();

  Aria2SessionInfoObject? get asSessionInfoObject =>
      asTOrNull<Aria2SessionInfoObject>();

  Aria2GlobalStatObject? get asStatObject => asTOrNull<Aria2GlobalStatObject>();

  Aria2DownloadingStatusObject? get asStatusObject =>
      asTOrNull<Aria2DownloadingStatusObject>();

  Aria2DownloadingUriObject? get asUriObject =>
      asTOrNull<Aria2DownloadingUriObject>();

  Aria2VersionObject? get asVersionObject => asTOrNull<Aria2VersionObject>();
}

extension EnumByAlias<T extends AliasEnumMixin> on Iterable<T> {
  T byAlias(String alias) {
    for (final value in this) {
      if (value.alias == alias) return value;
    }
    throw ArgumentError.value(alias, "alias", "No enum value with that alias.");
  }
}
