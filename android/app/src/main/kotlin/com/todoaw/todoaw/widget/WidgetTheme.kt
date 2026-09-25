package com.todoaw.todoaw.widget

import android.content.SharedPreferences
import android.widget.RemoteViews

data class WidgetPalette(
    val bg: Int,
    val card: Int,
    val accent: Int,
    val text: Int,
    val muted: Int,
    val border: Int,
    val danger: Int,
    val warn: Int,
    val success: Int,
    val isDark: Boolean,
)

object WidgetTheme {
    fun parseColor(hex: String?, default: Int): Int {
        if (hex.isNullOrBlank()) return default
        return try {
            val clean = hex.replace("#", "").replace("0x", "")
            val full = if (clean.length == 6) "FF$clean" else clean
            full.toLong(16).toInt()
        } catch (_: Exception) {
            default
        }
    }

    fun palette(data: SharedPreferences): WidgetPalette {
        val isDark = data.getString("themeMode", "dark") != "light"
        return WidgetPalette(
            bg = parseColor(data.getString("bgColor", null), if (isDark) 0xFF0F1729.toInt() else 0xFFF8FAFC.toInt()),
            card = parseColor(data.getString("cardBgColor", null), if (isDark) 0xFF1A2540.toInt() else 0xFFFFFFFF.toInt()),
            accent = parseColor(data.getString("accentColor", null), 0xFF3B82F6.toInt()),
            text = parseColor(data.getString("textColor", null), if (isDark) 0xFFFFFFFF.toInt() else 0xFF0F172A.toInt()),
            muted = parseColor(data.getString("mutedColor", null), if (isDark) 0xFF94A3B8.toInt() else 0xFF64748B.toInt()),
            border = parseColor(data.getString("borderColor", null), if (isDark) 0xFF1E293B.toInt() else 0xFFE2E8F0.toInt()),
            danger = parseColor(data.getString("dangerColor", null), 0xFFEF4444.toInt()),
            warn = parseColor(data.getString("warnColor", null), 0xFFF59E0B.toInt()),
            success = parseColor(data.getString("successColor", null), 0xFF10B981.toInt()),
            isDark = isDark,
        )
    }

    fun applyRoot(views: RemoteViews, p: WidgetPalette, rootId: Int) {
        views.setInt(rootId, "setBackgroundColor", p.bg)
    }

    fun tintText(views: RemoteViews, id: Int, color: Int) {
        views.setTextColor(id, color)
    }
}
