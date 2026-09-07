package com.todoaw.todoaw

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class QuickNoteWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: android.appwidget.AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_quick_note)

            val textColor = WidgetUtils.parseColor(widgetData.getString("textColor", null), 0xFFFFFFFF)

            // Label
            views.setTextViewText(R.id.widget_quick_note_label, "Quick Note")
            views.setTextColor(R.id.widget_quick_note_label, textColor)

            // Click label → open notes list
            val notesIntent = Intent(context, MainActivity::class.java).apply {
                action = "open_notes"
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val notesPending = PendingIntent.getActivity(
                context, 80000, notesIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_quick_note_label, notesPending)

            // Click "+" → new note
            val newNoteIntent = Intent(context, MainActivity::class.java).apply {
                action = "new_note"
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val newNotePending = PendingIntent.getActivity(
                context, 80001, newNoteIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_quick_note_button, newNotePending)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
