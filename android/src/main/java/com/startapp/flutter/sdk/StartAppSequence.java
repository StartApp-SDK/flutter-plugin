package com.startapp.flutter.sdk;

class StartAppSequence {
    private int value;

    public synchronized int next() {
        return value < Integer.MAX_VALUE ? ++value : 0;
    }
}
