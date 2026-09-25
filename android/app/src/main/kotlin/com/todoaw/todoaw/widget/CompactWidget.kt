package com.todoaw.todoaw.widget

import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import com.todoaw.todoaw.R

class CompactWidget : BaseWidgetProvider() {
    override val layoutRes = R.layout.widget_compact

    override fun render(
        context: Context,
        views: RemoteViews,
        data: SharedPreferences,
        widgetId: Int,
    ) {
        val p = WidgetTheme.palette(data)
        WidgetTheme.applyRoot(views, p, R.id.widget_compact_root)

        val completed = WidgetData.int(data, "completedCount")
        val total = WidgetData.int(data, "totalCount")
        views.setTextViewText(R.id.widget_compact_progress, "$completed/$total")
        views.setTextColor(R.id.widget_compact_progress, p.text)

        val nextTitle = WidgetData.str(data, "nextTaskTitle")
        val nextTime = WidgetData.str(data, "nextTaskTime")
        val nextUuid = WidgetData.str(data, "nextTaskUuid")
        if (nextTitle.isBlank()) {
            views.setTextViewText(R.id.widget_compact_next_title, "Tidak ada tugas berikutnya")
            views.setTextColor(R.id.widget_compact_next_title, p.muted)
            views.setTextViewText(R.id.widget_compact_next_time, "")
        } else {
            views.setTextViewText(
                R.id.widget_compact_next_title,
                "Berikutnya: $nextTitle",
            )
            views.setTextColor(R.id.widget_compact_next_title, p.text)
            views.setTextViewText(R.id.widget_compact_next_time, nextTime)
            views.setTextColor(R.id.widget_compact_next_time, p.muted)
        }

        val click = if (nextUuid.isNotBlank()) {
            activityPending(
                context, 3100, WidgetActionsNative.OPEN_TASK,
                mapOf("uuid" to nextUuid),
            )
        } else {
            activityPending(context, 3101, WidgetActionsNative.OPEN_HOME)
        }
        views.setOnClickPendingIntent(R.id.widget_compact_root, click)
    }
}
