package com.startapp.flutter.sdk;

import android.util.SparseArray;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class StartAppKeeper<T> {
    @NonNull
    private final StartAppSequence sequence;

    private final SparseArray<T> instances = new SparseArray<>();

    public StartAppKeeper(@NonNull StartAppSequence sequence) {
        this.sequence = sequence;
    }

    /**
     * @return positive number if an instance was added, otherwise return 0
     */
    public int add(@NonNull T instance) {
        int result = sequence.next();
        if (result > 0) {
            synchronized (instances) {
                instances.put(result, instance);
                return result;
            }
        }

        return 0;
    }

    @Nullable
    public T get(int id) {
        synchronized (instances) {
            return instances.get(id);
        }
    }

    public void remove(int id) {
        synchronized (instances) {
            instances.remove(id);
        }
    }
}
