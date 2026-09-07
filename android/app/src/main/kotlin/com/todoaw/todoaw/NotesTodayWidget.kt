package com.todoaw.todoaw

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

class NotesTodayWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: android.appwidget.AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_notes_today)

            val accentColor = WidgetUtils.parseColor(widgetData.getString("accentColor", null), 0xFF3B82F6)
            val textColor = WidgetUtils.parseColor(widgetData.getString("textColor", null), 0xFFFFFFFF)

            val notesListJson = widgetData.getString("notesList", null) ?: "[]"
            val notesUuidsJson = widgetData.getString("notesUuids", null) ?: "[]"

            val notesArray = try { JSONArray(notesListJson) } catch (_: Exception) { JSONArray() }
            val notesUuids = try { JSONArray(notesUuidsJson) } catch (_: Exception) { JSONArray() }

            // Header
            views.setTextViewText(R.id.widget_notes_title, "Notes")
            views.setTextColor(R.id.widget_notes_title, textColor)

            // Date text
            val dateFormat = SimpleDateFormat("EEE, d MMM", Locale.getDefault())
            views.setTextViewText(R.id.widget_notes_date, dateFormat.format(Date()))
            views.setTextColor(R.id.widget_notes_date, WidgetUtils.parseColor(null, 0xFF94A3B8))

            // Note list container
            val noteCount = minOf(notesArray.length(), 4)
            val rowIds = listOf(
                R.id.widget_notes_row_1,
                R.id.widget_notes_row_2,
                R.id.widget_notes_row_3,
                R.id.widget_notes_row_4
            )
            val titleIds = listOf(
                R.id.widget_notes_note_title_1,
                R.id.widget_notes_note_title_2,
                R.id.widget_notes_note_title_3,
                R.id.widget_notes_note_title_4
            )
            val previewIds = listOf(
                R.id.widget_notes_note_preview_1,
                R.id.widget_notes_note_preview_2,
                R.id.widget_notes_note_preview_3,
                R.id.widget_notes_note_preview_4
            )
            val timeIds = listOf(
                R.id.widget_notes_note_time_1,
                R.id.widget_notes_note_time_2,
                R.id.widget_notes_note_time_3,
                R.id.widget_notes_note_time_4
            )

            val now = Calendar.getInstance()
            val today = Calendar.getInstance().apply {
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }
            val yesterday = Calendar.getInstance().apply {
                add(Calendar.DAY_OF_YEAR, -1)
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }

            for (i in 0 until 4) {
                if (i < noteCount) {
                    views.setViewVisibility(rowIds[i], View.VISIBLE)

                    val noteObj = notesArray.optJSONObject(i) ?: JSONObject()
                    val title = noteObj.optString("title", "")
                    val content = noteObj.optString("content", "")
                    val createdAt = noteObj.optString("createdAt", "")
                    val uuid = notesUuids.optString(i, "")

                    views.setTextViewText(titleIds[i], title)
                    views.setTextColor(titleIds[i], textColor)

                    val preview = if (content.length > 60) content.substring(0, 60) + "..." else content
                    views.setTextViewText(previewIds[i], preview)
                    views.setTextColor(previewIds[i], WidgetUtils.parseColor(null, 0xFF94A3B8))

                    // Format time
                    val timeText = formatNoteTime(createdAt, now, today, yesterday)
                    views.setTextViewText(timeIds[i], timeText)
                    views.setTextColor(timeIds[i], WidgetUtils.parseColor(null, 0xFF94A3B8))

                    val noteIntent = Intent(context, MainActivity::class.java).apply {
                        action = "edit_note"
                        putExtra("note_uuid", uuid)
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    }
                    val notePending = PendingIntent.getActivity(
                        context, 70001 + i, noteIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    views.setOnClickPendingIntent(rowIds[i], notePending)
                } else {
                    views.setViewVisibility(rowIds[i], View.GONE)
                }
            }

            // Empty state
            if (noteCount == 0) {
                views.setViewVisibility(R.id.widget_notes_empty, View.VISIBLE)
                views.setTextViewText(R.id.widget_notes_empty, "Belum ada catatan hari ini")
                views.setTextColor(R.id.widget_notes_empty, WidgetUtils.parseColor(null, 0xFF94A3B8))
            } else {
                views.setViewVisibility(R.id.widget_notes_empty, View.GONE)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun formatNoteTime(createdAt: String, now: Calendar, today: Calendar, yesterday: Calendar): String {
        if (createdAt.isEmpty()) return ""
        return try {
            val inputFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
            val noteDate = inputFormat.parse(createdAt) ?: return ""
            val noteCal = Calendar.getInstance().apply { time = noteDate }

            val noteDay = Calendar.getInstance().apply {
                time = noteDate
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }

            when {
                noteDay == today -> SimpleDateFormat("HH:mm", Locale.getDefault()).format(noteDate)
                noteDay == yesterday -> "Yesterday"
                else -> SimpleDateFormat("d MMM", Locale.getDefault()).format(noteDate)
            }
        } catch (_: Exception) {
            ""
        }
    }
}
