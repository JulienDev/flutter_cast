import 'dart:convert';

import 'package:cast/common/rfc5646_language.dart';
import 'package:cast/common/text_track_type.dart';
import 'package:cast/common/track_type.dart';

///Describes track metadata information.
class Track {
  ///Custom application data.
  final Map<String, dynamic>? customData;

  ///Language tag as per RFC 5646. Mandatory when the subtype is SUBTITLES.
  final RFC5646_LANGUAGE? language;

  /// A descriptive, human-readable name for the track.
  ///  For example, “Spanish”. This can be used by the sender
  /// UI for example, to create a selection dialog.
  /// If the name is empty the dialog would contain an empty slot.

  final String? name;

  ///For text tracks, the type of text track.
  final TextTrackType? subtype;

  /// Identifier of the track’s content. It can be the
  ///  URL of the track or any other identifier that
  /// allows the receiver to find the content
  ///  (when the track is not inband or included in the manifest).
  ///  For example it can be the URL of a vtt file.

  final String? trackContentId;

  /// The MIME type of the track content. For example
  /// if the track is a vtt file it will be ‘text/vtt’.
  /// This field is needed for out of band tracks,
  /// so it is usually provided if a trackContentId
  ///  has also been provided. It is not mandatory
  ///  if the receiver has a way to identify the
  /// content from the trackContentId, but recommended.
  ///  The track content type, if provided, must be
  /// consistent with the track type.

  final String? trackContentType;

// Unique identifier of the track within the context
//of a chrome.cast.media.MediaInfo object.

  final int trackId;

  ///The type of track.
  final TrackType type;
  Track({
    this.customData,
    this.language,
    this.name,
    this.subtype,
    this.trackContentId,
    this.trackContentType,
    required this.trackId,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'customData': customData,
      'language': language?.toString(),
      'name': name,
      'subtype': subtype?.name,
      'trackContentId': trackContentId,
      'trackContentType': trackContentType,
      'trackId': trackId,
      'type': type.name,
    };
  }

  factory Track.fromMap(Map<String, dynamic> map) {
    return Track(
      customData: Map<String, dynamic>.from(map['customData'] ?? {}),
      language: map['language'] != null
          ? RFC5646_LANGUAGE.fromMap(map['language'])
          : null,
      name: map['name'],
      subtype:
          map['subtype'] != null ? TextTrackType.fromMap(map['subtype']) : null,
      trackContentId: map['trackContentId'],
      trackContentType: map['trackContentType'],
      trackId: map['trackId']?.toInt() ?? 0,
      type: TrackType.fromMap(map['type']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Track.fromJson(String source) => Track.fromMap(json.decode(source));
}
