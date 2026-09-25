package com.todoaw.todoaw.widget

import android.content.SharedPreferences
import org.json.JSONArray

data class WidgetTaskItem(
    val uuid: String,
    val title: String,
    val time: String,
    val done: Boolean,
    val level: String,
)

data class WidgetNoteItem(
    val uuid: String,
    val title: String,
    val preview: String,
    val time: String,
    val pinned: Boolean,
)

object WidgetData {
    fun schemaOk(data: SharedPreferences): Boolean {
        val v = data.getString("schemaVersion", "1")?.toIntOrNull() ?: 1
        return v == 1
    }

    fun int(data: SharedPreferences, key: String, default: Int = 0): Int =
        data.getString(key, null)?.toIntOrNull() ?: default

    fun str(data: SharedPreferences, key: String): String =
        data.getString(key, null) ?: ""

    fun boolFlag(data: SharedPreferences, key: String): Boolean =
        data.getString(key, "0") == "1"

    private fun parseTaskArray(json: String?): List<WidgetTaskItem> {
        if (json.isNullOrBlank()) return emptyList()
        return try {
            val arr = JSONArray(json)
            (0 until arr.length()).mapNotNull { i ->
                val o = arr.optJSONObject(i) ?: return@mapNotNull null
                WidgetTaskItem(
                    uuid = o.optString("uuid"),
                    title = o.optString("title"),
                    time = o.optString("time"),
                    done = o.optBoolean("done", false),
                    level = o.optString("level"),
                )
            }
        } catch (_: Exception) {
            emptyList()
        }
    }

    private fun parseNoteArray(json: String?): List<WidgetNoteItem> {
        if (json.isNullOrBlank()) return emptyList()
        return try {
            val arr = JSONArray(json)
            (0 until arr.length()).mapNotNull { i ->
                val o = arr.optJSONObject(i) ?: return@mapNotNull null
                WidgetNoteItem(
                    uuid = o.optString("uuid"),
                    title = o.optString("title"),
                    preview = o.optString("preview"),
                    time = o.optString("time"),
                    pinned = o.optBoolean("pinned", false),
                )
            }
        } catch (_: Exception) {
            emptyList()
        }
    }

    fun todayTasks(data: SharedPreferences): List<WidgetTaskItem> =
        parseTaskArray(data.getString("todayTaskList", null))

    fun priorityTasks(data: SharedPreferences): List<WidgetTaskItem> =
        parseTaskArray(data.getString("priorityTaskList", null))

    fun notesToday(data: SharedPreferences): List<WidgetNoteItem> =
        parseNoteArray(data.getString("notesTodayList", null))
}
