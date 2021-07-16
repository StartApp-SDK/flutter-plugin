package com.startapp.flutter.sdk;

import android.content.res.Resources;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ColorFilter;
import android.graphics.DashPathEffect;
import android.graphics.Paint;
import android.graphics.PixelFormat;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.util.TypedValue;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

class StartAppErrorDrawable extends Drawable {
    @NonNull
    private final String text;

    @NonNull
    private final Paint paintRect;

    @NonNull
    private final Paint paintText;

    @NonNull
    private final Rect textBounds;

    private final float oneDp;

    StartAppErrorDrawable(@NonNull Resources resources, @NonNull String text) {
        this.text = text;

        oneDp = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 1, resources.getDisplayMetrics());

        paintRect = new Paint();
        paintRect.setColor(Color.RED);
        paintRect.setStyle(Paint.Style.STROKE);
        paintRect.setStrokeWidth(8 * oneDp);
        paintRect.setPathEffect(new DashPathEffect(new float[]{16 * oneDp, 4 * oneDp}, 0));

        paintText = new Paint();
        paintText.setColor(Color.RED);

        textBounds = new Rect();
    }

    @Override
    public void draw(@NonNull Canvas canvas) {
        Rect bounds = getBounds();
        paintText.setTextSize(Math.min(20 * oneDp, bounds.height() / 3f));
        paintText.getTextBounds(text, 0, text.length(), textBounds);

        canvas.drawRect(0, 0, bounds.width(), bounds.height(), paintRect);
        canvas.drawText(
                text,
                (bounds.width() - textBounds.width()) / 2f,
                (bounds.height() + textBounds.height()) / 2f,
                paintText
        );
    }

    @Override
    public void setAlpha(int alpha) {
        // none
    }

    @Override
    public void setColorFilter(@Nullable ColorFilter colorFilter) {
        // none
    }

    @Override
    public int getOpacity() {
        return PixelFormat.TRANSLUCENT;
    }
}
