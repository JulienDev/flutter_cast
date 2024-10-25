import 'dart:convert';

import 'package:cast/common/media_metadata/cast_media_metadata.dart';

class CastPhotoMediaMetadata extends CastMediaMetadata {
  CastPhotoMediaMetadata({
    this.title,
    this.artist,
    this.location,
    this.latitude,
    this.longitude,
    this.width,
    this.height,
    this.creationDateTime,
    required super.metadataType,
  });

  ///string 	optional Title of the photograph.
  /// Player can independently retrieve title
  ///  using content_id or it can be given by the sender in the Load message
  final String? title;

  ///string 	optional Name of the photographer.
  /// Player can independently retrieve artist
  /// using content_id or it can be given by
  /// the sender in the Load message
  final String? artist;

  ///string 	optional Verbal location where
  /// the photograph was taken; for example,
  /// "Madrid, Spain." Player can independently
  ///  retrieve location using content_id or it
  ///  can be given by the sender in the Load message
  final String? location;

  ///double 	optional Geographical latitude
  /// value for the location where the
  /// photograph was taken. Player can independently
  ///  retrieve latitude using content_id or
  /// it can be given by the sender in the Load message
  final double? latitude;

  ///double 	optional Geographical longitude
  ///value for the location where the photograph
  /// was taken. Player can independently retrieve
  /// longitude using content_id or it can be
  ///  given by the sender in the Load message
  final double? longitude;

  ///integer 	optional Width in pixels of the photograph.
  /// Player can independently retrieve width using
  ///  content_id or it can be given by the sender
  ///  in the Load message
  final int? width;

  ///integer 	optional Height in pixels of the photograph.
  /// Player can independently retrieve height using
  ///  content_id or it can be given by the sender
  ///  in the Load message
  final int? height;

  ///string (ISO 8601) 	optional ISO 8601 date
  ///and time this photograph was taken. Player
  /// can independently retrieve creationDateTime
  ///  using content_id or it can be given by
  /// the sender in the Load message
  final DateTime? creationDateTime;

  @override
  Map<String, dynamic> toMap() {
    return {
      'metadataType': metadataType.value,
      'title': title,
      'artist': artist,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'width': width,
      'height': height,
      'creationDateTime': creationDateTime?.toIso8601String(),
    };
  }

  factory CastPhotoMediaMetadata.fromMap(Map<String, dynamic> map) {
    return CastPhotoMediaMetadata(
      metadataType: map['metadataType'],
      title: map['title'],
      artist: map['artist'],
      location: map['location'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      width: map['width']?.toInt(),
      height: map['height']?.toInt(),
      creationDateTime: map['creationDateTime'] != null
          ? DateTime.tryParse(map['creationDateTime'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CastPhotoMediaMetadata.fromJson(String source) =>
      CastPhotoMediaMetadata.fromMap(json.decode(source));
}
