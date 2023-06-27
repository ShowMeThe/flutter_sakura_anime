package io.flutter.plugins.videoplayer;

import android.content.Context;

import com.google.android.exoplayer2.database.StandaloneDatabaseProvider;
import com.google.android.exoplayer2.upstream.cache.LeastRecentlyUsedCacheEvictor;
import com.google.android.exoplayer2.upstream.cache.SimpleCache;

import java.io.File;

public class CacheUtil {

    private static volatile SimpleCache cache;

    static SimpleCache get(Context context, File cacheDirectory) {
        if (cache == null) {
            synchronized (CacheUtil.class) {
                if (cache == null) {
                    cache = new SimpleCache(
                            cacheDirectory,
                            new LeastRecentlyUsedCacheEvictor(1024L * 1024L * 512L),
                            new StandaloneDatabaseProvider(context)
                    );
                }
            }
        }
        return cache;
    }

}

