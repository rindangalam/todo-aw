package com.todoaw.todoaw.widget

import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import com.todoaw.todoaw.R
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class NotesTodayWidget : BaseWidgetProvider() {
    override val layoutRes = R.layout.widget_notes_today

    override fun render(
        context: Context,
        views: RemoteViews,
        data: SharedPreferences,
        widgetId: Int,
    ) {
        val p = WidgetTheme.palette(data)
        WidgetTheme.applyRoot(views, p, R.id.widget_notes_today_root)

        val dateFmt = SimpleDateFormat("EEE, d MMM", Locale("id", "ID"))
        views.setTextViewText(R.id.widget_notes_today_date, WidgetData.str(data, "dateLabel").ifBlank { dateFmt.format(Date()) })
        views.setTextColor(R.id.widget_notes_today_date, p.muted)

        val notes = WidgetData.notesToday(data)
        val empty = notes.isEmpty()
        views.setViewVisibility(
            R.id.widget_notes_today_empty,
            if (empty) View.VISIBLE else View.GONE,
        )
        views.setViewVisibility(
            R.id.widget_notes_today_cards,
            if (empty) View.GONE else View.VISIBLE,
        )

        for (i in 1..4) {
            val rootId = resId(context, "widget_notes_today_row_$i")
            val titleId = resId(context, "widget_notes_today_row_${i}_title")
            val previewId = resId(context, "widget_notes_today_row_${i}_preview")
            val timeId = resId(context, "widget_notes_today_row_${i}_time")
            val pinId = resId(context, "widget_notes_today_row_${i}_pin")

            val item = notes.getOrNull(i - 1)
            if (item == null) {
                views.setViewVisibility(rootId, View.GONE)
                continue
            }
            views.setViewVisibility(rootId, View.VISIBLE)
            views.setInt(rootId, "setBackgroundColor", p.card)
            views.setTextViewText(titleId, item.title)
            views.setTextColor(titleId, p.text)
            views.setTextViewText(previewId, item.preview)
            views.setTextColor(previewId, p.muted)
            views.setTextViewText(timeId, item.time)
            views.setTextColor(timeId, p.muted)
            views.setViewVisibility(pinId, if (item.pinned) View.VISIBLE else View.GONE)
            views.setOnClickPendingIntent(
                rootId,
                activityPending(
                    context, WidgetActionsNative.OPEN_NOTE,
                    mapOf("uuid" to item.uuid),
                ),
            )
        }

        views.setOnClickPendingIntent(
            R.id.widget_notes_today_date,
            activityPending(context, WidgetActionsNative.OPEN_NOTES),
        )
    }

    private fun resId(context: Context, name: String): Int =
        context.resources.getIdentifier(name, "id", context.packageName)
}
