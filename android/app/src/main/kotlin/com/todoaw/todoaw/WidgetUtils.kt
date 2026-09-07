package com.todoaw.todoaw

import android.graphics.Color

object WidgetUtils {
    fun parseColor(hex: String?, default: Long): Int {
        if (hex == null) return default.toInt()
        return try {
            val clean = hex.replace("#", "").replace("0x", "")
            val full = if (clean.length == 6) "FF$clean" else clean
            java.lang.Long.parseLong(full, 16).toInt()
        } catch (_: Exception) { default.toInt() }
    }

    fun dimColor(color: Int, factor: Float): Int {
        return Color.argb(
            (Color.alpha(color) * factor).toInt(),
            Color.red(color),
            Color.green(color),
            Color.blue(color)
        )
    }
}
