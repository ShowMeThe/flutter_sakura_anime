/// This file is a part of media_kit (https://github.com/media-kit/media-kit).
///
/// Copyright © 2021 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
/// Use of this source code is governed by MIT license that can be found in the LICENSE file.
// ignore_for_file: library_private_types_in_public_api
import 'dart:io';
import 'dart:collection';
import 'dart:typed_data';
import 'package:uri_parser/uri_parser.dart';
import 'package:safe_local_storage/safe_local_storage.dart';

import 'package:media_kit/src/models/playable.dart';

import 'package:media_kit/src/player/native/utils/temp_file.dart';
import 'package:media_kit/src/player/native/utils/asset_loader.dart';
import 'package:media_kit/src/player/native/utils/android_content_uri_provider.dart';

/// {@template media}
///
/// Media
/// -----
///
/// A [Media] object to open inside a [Player] for playback.
///
/// ```dart
/// final player = Player();
/// final playable = Media('https://user-images.githubusercontent.com/28951144/229373695-22f88f13-d18f-4288-9bf1-c3e078d83722.mp4');
/// await player.open(playable);
/// ```
///
/// {@endtemplate}
class Media extends Playable {
  /// The [Finalizer] is invoked when the [Media] instance is garbage collected.
  /// This has been done to:
  /// 1. Evict the [Media] instance from [cache].
  /// 2. Close the file descriptor created by [AndroidContentUriProvider] to handle content:// URIs on Android.
  /// 3. Delete the temporary file created by [Media.memory].
  static final Finalizer<_MediaFinalizerContext> _finalizer =
      Finalizer<_MediaFinalizerContext>(
    (context) async {
      final uri = context.uri;
      final memory = context.memory;
      // Decrement reference count.
      ref[uri] = ((ref[uri] ?? 0) - 1).clamp(0, 1 << 32);
      // Remove [Media] instance from [cache] if reference count is 0.
      if (ref[uri] == 0) {
        cache.remove(uri);
      }
      // content:// : Close the possible file descriptor on Android.
      try {
        if (Platform.isAndroid) {
          final data = Uri.parse(uri);
          if (data.isScheme('FD')) {
            final fd = int.parse(data.authority);
            if (fd > 0) {
              await AndroidContentUriProvider.closeFileDescriptor(uri);
            }
          }
        }
      } catch (exeception, stacktrace) {
        print(exeception);
        print(stacktrace);
      }
      // Media.memory : Delete the temporary file.
      try {
        if (memory) {
          await File(uri).delete_();
        }
      } catch (exeception, stacktrace) {
        print(exeception);
        print(stacktrace);
      }
    },
  );

  /// URI of the [Media].
  final String uri;

  /// Additional optional user data.
  ///
  /// Default: `null`.
  final Map<String, dynamic>? extras;

  /// HTTP headers.
  ///
  /// Default: `null`.
  final Map<String, String>? httpHeaders;

  /// Start position.
  ///
  /// Default: `null`.
  final Duration? start;

  /// End position.
  ///
  /// Default: `null`.
  final Duration? end;

  /// Whether instance is instantiated from [Media.memory].
  bool _memory = false;

  /// {@macro media}
  Media(
    String resource, {
    Map<String, dynamic>? extras,
    Map<String, String>? httpHeaders,
    this.start,
    this.end,
  })  : uri = normalizeURI(resource),
        extras = extras ?? cache[normalizeURI(resource)]?.extras,
        httpHeaders =
            httpHeaders ?? cache[normalizeURI(resource)]?.httpHeaders {
    // Increment reference count.
    ref[uri] = ((ref[uri] ?? 0) + 1).clamp(0, 1 << 32);
    // Store [this] instance in [cache].
    cache[uri] = _MediaCache(
      extras: this.extras,
      httpHeaders: this.httpHeaders,
    );
    // Attach [this] instance to [Finalizer].
    _finalizer.attach(
      this,
      _MediaFinalizerContext(
        uri,
        _memory,
      ),
    );
  }

  /// Creates a [Media] instance from [Uint8List].
  ///
  /// The [type] parameter is optional and is used to specify the MIME type of the media on web.
  static Future<Media> memory(
    Uint8List data, {
    String? type,
  }) async {
    final file = await TempFile.create();
    await file.write_(data);
    final instance = Media(file.path);
    instance._memory = true;
    return instance;
  }

  /// Normalizes the passed URI.
  static String normalizeURI(String uri) {
    if (uri.startsWith(_kAssetScheme)) {
      // Handle asset:// scheme. Only for Flutter.
      return AssetLoader.load(uri);
    }
    // content:// URI support for Android.
    try {
      if (Platform.isAndroid) {
        if (Uri.parse(uri).isScheme('CONTENT')) {
          final fd = AndroidContentUriProvider.openFileDescriptorSync(uri);
          if (fd > 0) {
            return 'fd://$fd';
          }
        }
      }
    } catch (exception, stacktrace) {
      print(exception);
      print(stacktrace);
    }
    // Keep the resulting URI normalization same as used by libmpv internally.
    // [File] or network URIs.
    final parser = URIParser(uri);
    switch (parser.type) {
      case URIType.file:
        {
          return parser.file!.path;
        }
      case URIType.network:
        {
          return parser.uri!.toString();
        }
      default:
        return uri;
    }
  }

  /// For comparing with other [Media] instances.
  @override
  bool operator ==(Object other) {
    if (other is Media) {
      return other.uri == uri;
    }
    return false;
  }

  /// For comparing with other [Media] instances.
  @override
  int get hashCode => uri.hashCode;

  /// Creates a copy of [this] instance with the given fields replaced with the new values.
  Media copyWith({
    String? uri,
    Map<String, dynamic>? extras,
    Map<String, String>? httpHeaders,
    Duration? start,
    Duration? end,
  }) {
    return Media(
      uri ?? this.uri,
      extras: extras ?? this.extras,
      httpHeaders: httpHeaders ?? this.httpHeaders,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  @override
  String toString() =>
      'Media($uri, extras: $extras, httpHeaders: $httpHeaders, start: $start, end: $end)';

  /// URI scheme used to identify Flutter assets.
  static const String _kAssetScheme = 'asset://';

  /// Previously created [Media] instances.
  /// This [HashMap] is used to retrieve previously set [extras] & [httpHeaders].
  static final HashMap<String, _MediaCache> cache =
      HashMap<String, _MediaCache>();

  /// Previously created [Media] instances' reference count.
  static final HashMap<String, int> ref = HashMap<String, int>();
}

/// {@template _media_cache}
/// A simple class to pack optional arguments in [Media] together.
/// {@endtemplate}
class _MediaCache {
  /// Additional optional user data.
  ///
  /// Default: `null`.
  final Map<String, dynamic>? extras;

  /// HTTP headers.
  ///
  /// Default: `null`.
  final Map<String, String>? httpHeaders;

  /// {@macro _media_cache}
  const _MediaCache({
    this.extras,
    this.httpHeaders,
  });

  @override
  String toString() => '_MediaCache('
      'extras: $extras, '
      'httpHeaders: $httpHeaders'
      ')';
}

/// {@template _media_finalizer_context}
/// A simple class to pack the required attributes into [Finalizer] argument.
/// {@endtemplate}
class _MediaFinalizerContext {
  final String uri;
  final bool memory;

  const _MediaFinalizerContext(this.uri, this.memory);

  @override
  String toString() => '_MediaFinalizerContext(uri: $uri, memory: $memory)';
}
