package com.startapp.flutter.sdk;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Map;

import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class StartAppViewFactory<T extends StartAppView> extends PlatformViewFactory {
    @NonNull
    private final FactoryMethod<T> factory;

    public StartAppViewFactory(@NonNull FactoryMethod<T> factory) {
        super(StandardMessageCodec.INSTANCE);

        this.factory = factory;
    }

    @NonNull
    @Override
    @SuppressWarnings({"unchecked", "rawtypes"})
    public PlatformView create(@NonNull Context context, int id, @Nullable Object args) {
        final Map<String, Object> creationParams = (Map) args;

        T result = factory.newInstance();
        result.createView(context, id, creationParams);
        return result;
    }

    public interface FactoryMethod<T extends StartAppView> {
        @NonNull
        T newInstance();
    }
}
