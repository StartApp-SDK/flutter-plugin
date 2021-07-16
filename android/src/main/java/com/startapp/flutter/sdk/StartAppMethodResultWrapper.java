package com.startapp.flutter.sdk;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.concurrent.atomic.AtomicReference;

import io.flutter.plugin.common.MethodChannel;

class StartAppMethodResultWrapper {
    @NonNull
    private final AtomicReference<MethodChannel.Result> ref;

    public StartAppMethodResultWrapper(@NonNull MethodChannel.Result result) {
        this.ref = new AtomicReference<>(result);
    }

    public void success(@Nullable Object value) {
        MethodChannel.Result result = ref.getAndSet(null);
        if (result != null) {
            result.success(value);
        }
    }

    public void error(@Nullable String errorCode, @Nullable String errorMessage) {
        MethodChannel.Result result = ref.getAndSet(null);
        if (result != null) {
            result.error(errorCode, errorMessage, null);
        }
    }
}
