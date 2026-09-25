package com.todoaw.todoaw.widget

import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import com.todoaw.todoaw.R

class TodayWidget : BaseWidgetProvider() {
    override val layoutRes = R.layout.widget_today

    override fun render(
        context: Context,
        views: RemoteViews,
        data: SharedPreferences,
        widgetId: Int,
    ) {
        val p = WidgetTheme.palette(data)
        WidgetTheme.applyRoot(views, p, R.id.widget_today_root)

        views.setTextViewText(R.id.widget_today_date, WidgetData.str(data, "dateLabel"))
        views.setTextColor(R.id.widget_today_date, p.muted)
        views.setTextViewText(R.id.widget_today_logo, "todoaw")
        views.setTextColor(R.id.widget_today_logo, p.text)

        val completed = WidgetData.int(data, "completedCount")
        val total = WidgetData.int(data, "totalCount")
        views.setTextViewText(R.id.widget_today_progress_text, "$completed/$total")
        views.setTextColor(R.id.widget_today_progress_text, p.text)

        val tasks = WidgetData.todayTasks(data)
        if (tasks.isEmpty()) {
            views.setViewVisibility(R.id.widget_today_empty, View.VISIBLE)
            views.setViewVisibility(R.id.widget_today_rows, View.GONE)
        } else {
            views.setViewVisibility(R.id.widget_today_empty, View.GONE)
            views.setViewVisibility(R.id.widget_today_rows, View.VISIBLE)
        }

        for (i in 1..5) {
            val rowId = resId(context, "widget_today_row_$i")
            val titleId = resId(context, "widget_today_row_${i}_title")
            val timeId = resId(context, "widget_today_row_${i}_time")
            val cbId = resId(context, "widget_today_row_${i}_checkbox")

            val item = tasks.getOrNull(i - 1)
            if (item == null) {
                views.setViewVisibility(rowId, View.GONE)
                continue
            }
            views.setViewVisibility(rowId, View.VISIBLE)
            views.setTextViewText(titleId, item.title)
            views.setTextColor(titleId, p.text)
            views.setTextViewText(timeId, item.time)
            views.setTextColor(timeId, p.muted)
            views.setInt(
                cbId,
                "setBackgroundResource",
                if (item.done) R.drawable.widget_checkbox_done
                else R.drawable.widget_checkbox_todo,
            )
            views.setOnClickPendingIntent(cbId, togglePending(context, 2000 + i, item.uuid))
            views.setOnClickPendingIntent(
                rowId,
                activityPending(
                    context, 1000 + i,
                    WidgetActionsNative.OPEN_TASK,
                    mapOf("uuid" to item.uuid),
                ),
            )
        }

        views.setOnClickPendingIntent(
            R.id.widget_today_logo,
            activityPending(context, 9000, WidgetActionsNative.OPEN_HOME),
        )
    }

    override fun applySafeEmpty(context: Context, views: RemoteViews, data: SharedPreferences) {
        WidgetTheme.applyRoot(views, WidgetTheme.palette(data), R.id.widget_today_root)
    }

    private fun resId(context: Context, name: String): Int =
        context.resources.getIdentifier(name, "id", context.packageName)
}
