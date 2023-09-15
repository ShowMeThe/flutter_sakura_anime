import 'package:json_annotation/json_annotation.dart';

part 'PlayUrlsCache.g.dart';

@JsonSerializable()
class PlayUrlsCache{
  String chapterUrl;
  String playUrl;

  PlayUrlsCache(this.chapterUrl, this.playUrl);


  factory PlayUrlsCache.fromJson(Map<String, dynamic> json) => _$PlayUrlsCacheFromJson(json);
  Map<String, dynamic> toJson() => _$PlayUrlsCacheToJson(this);
}