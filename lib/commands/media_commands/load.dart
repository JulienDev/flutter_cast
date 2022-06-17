import 'dart:convert';

import 'package:cast/cast.dart';

import 'enum/command_type.dart';

///Loads new content into the media player.
class CastLoadCommand extends CastMediaCommand {
  CastLoadCommand({
    this.media,
    this.requestId,
    this.autoplay,
    this.currentTime,
    this.customData,
    this.queueData,
  })  : assert((media == null) ^ (queueData == null),
            'You need specify a media or a queue data items'),
        super(type: MediaCommandType.LOAD);

  ///ID of the request, to correlate request and response
  final int? requestId;

  ///Metadata (including contentId) of the media to load
  final CastMediaInformation? media;

  ///optional (default is true) If the autoplay
  /// parameter is specified, the media player will
  ///  begin playing the content when it is loaded.
  ///  Even if autoplay is not specified, media player
  ///  implementation may choose to begin playback immediately.
  ///  If playback is started, the player state in the response
  ///  should be set to BUFFERING,
  ///  otherwise it should be set to PAUSED
  final bool? autoplay;

  ///optional Seconds since beginning of
  /// content. If the content is live content,
  ///  and position is not specifed, the
  ///  stream will start at the live position
  final Duration? currentTime;

  final CastQueueData? queueData;

  ///optional Application-specific blob of data defined by the sender application
  final Map<String, dynamic>? customData;

  CastLoadCommand copyWith({
    MediaCommandType? type,
    CastQueueData? queueData,
    int? requestId,
    CastMediaInformation? media,
    bool? autoplay,
    Duration? currentTime,
    Map<String, dynamic>? customData,
  }) {
    return CastLoadCommand(
      queueData: queueData ?? this.queueData,
      requestId: requestId ?? this.requestId,
      media: media ?? this.media,
      autoplay: autoplay ?? this.autoplay,
      currentTime: currentTime ?? this.currentTime,
      customData: customData ?? this.customData,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'requestId': requestId,
      'media': media?.toMap(),
      'autoplay': autoplay,
      'currentTime': currentTime?.inSeconds,
      'customData': customData,
      'queueData': queueData?.toMap(),
    }..removeWhere((key, value) => value == null);
  }

  String toJson() => json.encode(toMap());
}
