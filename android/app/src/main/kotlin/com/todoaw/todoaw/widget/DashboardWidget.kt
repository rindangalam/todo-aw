package com.todoaw.todoaw.widget

import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import com.todoaw.todoaw.R

class DashboardWidget : BaseWidgetProvider() {
    override val layoutRes = R.layout.widget_dashboard

    override fun render(
        context: Context,
        views: RemoteViews,
        data: SharedPreferences,
        widgetId: Int,
    ) {
        val p = WidgetTheme.palette(data)
        WidgetTheme.applyRoot(views, p, R.id.widget_dashboard_root)

        views.setTextViewText(R.id.widget_dashboard_greeting, WidgetData.str(data, "greeting"))
        views.setTextColor(R.id.widget_dashboard_greeting, p.text)
        views.setTextColor(R.id.widget_dashboard_sub, p.muted)

        val completed = WidgetData.int(data, "completedCount")
        val total = WidgetData.int(data, "totalCount")
        views.setTextViewText(R.id.widget_dashboard_progress_text, "$completed/$total")
        views.setTextColor(R.id.widget_dashboard_progress_text, p.text)

        views.setInt(R.id.widget_dashboard_card_tasks, "setBackgroundColor", p.card)
        views.setInt(R.id.widget_dashboard_card_notes, "setBackgroundColor", p.card)
        views.setInt(R.id.widget_dashboard_card_total, "setBackgroundColor", p.card)

        views.setTextViewText(R.id.widget_dashboard_stat_tasks, WidgetData.str(data, "tasksTodayCount"))
        views.setTextColor(R.id.widget_dashboard_stat_tasks, p.accent)
        views.setTextViewText(R.id.widget_dashboard_stat_notes, WidgetData.str(data, "notesTodayCount"))
        views.setTextColor(R.id.widget_dashboard_stat_notes, p.success)
        views.setTextViewText(R.id.widget_dashboard_stat_total, WidgetData.str(data, "totalTodayCount"))
        views.setTextColor(R.id.widget_dashboard_stat_total, p.accent)

        val nextTitle = WidgetData.str(data, "nextTaskTitle")
        val nextTime = WidgetData.str(data, "nextTaskTime")
        val nextUuid = WidgetData.str(data, "nextTaskUuid")
        views.setTextViewText(
            R.id.widget_dashboard_next_title,
            if (nextTitle.isBlank()) "Berikutnya: —" else "Berikutnya: $nextTitle",
        )
        views.setTextColor(R.id.widget_dashboard_next_title, p.text)
        views.setTextViewText(R.id.widget_dashboard_next_time, nextTime)
        views.setTextColor(R.id.widget_dashboard_next_time, p.muted)
        views.setOnClickPendingIntent(
            R.id.widget_dashboard_next_title,
            activityPending(
                context,
                if (nextUuid.isNotBlank()) WidgetActionsNative.OPEN_TASK else WidgetActionsNative.OPEN_HOME,
                if (nextUuid.isNotBlank()) mapOf("uuid" to nextUuid) else emptyMap(),
            ),
        )

        views.setOnClickPendingIntent(
            R.id.widget_dashboard_btn_add_task,
            activityPendingClass(
                context, 5200, QuickInputActivity::class.java,
                QuickInputActivity.ACTION_MODE,
                mapOf(QuickInputActivity.EXTRA_MODE to QuickInputActivity.MODE_TASK),
            ),
        )
        views.setOnClickPendingIntent(
            R.id.widget_dashboard_btn_add_note,
            activityPendingClass(
                context, 5201, QuickInputActivity::class.java,
                QuickInputActivity.ACTION_MODE,
                mapOf(QuickInputActivity.EXTRA_MODE to QuickInputActivity.MODE_NOTE),
            ),
        )
        views.setOnClickPendingIntent(
            R.id.widget_dashboard_btn_view_all,
            activityPending(context, WidgetActionsNative.OPEN_HOME),
        )
        views.setOnClickPendingIntent(
            R.id.widget_dashboard_progress_text,
            activityPending(context, WidgetActionsNative.OPEN_DASHBOARD),
        )
    }
}
