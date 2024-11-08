// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_dialog.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DownloadChapter _$DownloadChapterFromJson(Map<String, dynamic> json) =>
    DownloadChapter(
      json['chapter'] as String,
      json['url'] as String,
      json['localCacheFileDir'] as String,
    )..state = (json['state'] as num).toInt();

Map<String, dynamic> _$DownloadChapterToJson(DownloadChapter instance) =>
    <String, dynamic>{
      'chapter': instance.chapter,
      'url': instance.url,
      'state': instance.state,
      'localCacheFileDir': instance.localCacheFileDir,
    };
