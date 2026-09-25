package com.todoaw.todoaw.widget

import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import com.todoaw.todoaw.R

class PriorityWidget : BaseWidgetProvider() {
    override val layoutRes = R.layout.widget_priority

    override fun render(
        context: Context,
        views: RemoteViews,
        data: SharedPreferences,
        widgetId: Int,
    ) {
        val p = WidgetTheme.palette(data)
        WidgetTheme.applyRoot(views, p, R.id.widget_priority_root)

        val tasks = WidgetData.priorityTasks(data)
        views.setTextViewText(R.id.widget_priority_count, "${tasks.size} tugas")
        views.setTextColor(R.id.widget_priority_count, p.muted)

        val empty = tasks.isEmpty()
        views.setViewVisibility(
            R.id.widget_priority_empty,
            if (empty) View.VISIBLE else View.GONE,
        )
        views.setViewVisibility(
            R.id.widget_priority_rows,
            if (empty) View.GONE else View.VISIBLE,
        )

        for (i in 1..5) {
            val rowId = resId(context, "widget_priority_row_$i")
            val cbId = resId(context, "widget_priority_row_${i}_checkbox")
            val titleId = resId(context, "widget_priority_row_${i}_title")
            val badgeId = resId(context, "widget_priority_row_${i}_badge")
            val timeId = resId(context, "widget_priority_row_${i}_time")

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
            val isHigh = item.level == "high"
            views.setTextViewText(badgeId, if (isHigh) "High" else "Medium")
            views.setInt(
                badgeId,
                "setBackgroundColor",
                if (isHigh) p.danger else p.warn,
            )
            views.setTextColor(badgeId, 0xFFFFFFFF.toInt())
            views.setInt(
                cbId,
                "setBackgroundResource",
                if (item.done) R.drawable.widget_checkbox_done
                else R.drawable.widget_checkbox_todo,
            )
            views.setOnClickPendingIntent(cbId, togglePending(context, 4000 + i, item.uuid))
            views.setOnClickPendingIntent(
                rowId,
                activityPending(
                    context, 4500 + i, WidgetActionsNative.OPEN_TASK,
                    mapOf("uuid" to item.uuid),
                ),
            )
        }

        views.setOnClickPendingIntent(
            R.id.widget_priority_footer,
            activityPending(context, 4900, WidgetActionsNative.OPEN_TASKS_PRIORITY),
        )
    }

    private fun resId(context: Context, name: String): Int =
        context.resources.getIdentifier(name, "id", context.packageName)
}
