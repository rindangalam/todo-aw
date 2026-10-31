package com.todoaw.todoaw.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import com.todoaw.todoaw.R

class TodayWidget : BaseWidgetProvider() {
    override val layoutRes = R.layout.widget_today

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        super.onUpdate(context, appWidgetManager, appWidgetIds, widgetData)
        // The adapter Intent is identical on every refresh, so the framework
        // would keep the cached RemoteViewsFactory and keep rendering the old
        // task snapshot. Ask each list to re-read the payload instead.
        for (id in appWidgetIds) {
            try {
                appWidgetManager.notifyAppWidgetViewDataChanged(id, R.id.widget_today_list)
            } catch (e: Exception) {
                android.util.Log.e("WidgetDebug", "TodayWidget notifyDataChanged failed id=$id", e)
            }
        }
    }

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
        views.setTextColor(R.id.widget_today_title, p.text)
        views.setTextColor(R.id.widget_today_subtitle, p.muted)
        views.setTextColor(R.id.widget_today_empty, p.muted)

        val completed = WidgetData.int(data, "completedCount")
        val total = WidgetData.int(data, "totalCount")
        views.setTextViewText(R.id.widget_today_progress_text, "$completed/$total")
        // Accent pill background — keep white text in both themes.
        views.setTextColor(R.id.widget_today_progress_text, 0xFFFFFFFF.toInt())

        // Adapter-backed so the list scrolls; the factory renders checked tasks
        // struck-through instead of dropping them.
        val serviceIntent = Intent(context, TodayWidgetRemoteViewsService::class.java).apply {
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
        }
        views.setRemoteAdapter(R.id.widget_today_list, serviceIntent)
        views.setEmptyView(R.id.widget_today_list, R.id.widget_today_empty)
        views.setPendingIntentTemplate(R.id.widget_today_list, toggleTemplatePending(context, widgetId))

        views.setOnClickPendingIntent(
            R.id.widget_today_logo,
            activityPending(context, WidgetActionsNative.OPEN_HOME),
        )
    }

    override fun applySafeEmpty(context: Context, views: RemoteViews, data: SharedPreferences) {
        WidgetTheme.applyRoot(views, WidgetTheme.palette(data), R.id.widget_today_root)
    }

    /**
     * One template PendingIntent serves every row. The task uuid is supplied
     * per row via `setOnClickFillInIntent`, so unlike [togglePending] this
     * MUST be mutable — FLAG_IMMUTABLE would discard the fill-in extras and
     * the receiver would never know which task to toggle.
     */
    private fun toggleTemplatePending(context: Context, widgetId: Int): PendingIntent {
        val intent = Intent(context, WidgetActionReceiver::class.java).apply {
            action = WidgetActionsNative.ACTION_TOGGLE_TASK
        }
        return PendingIntent.getBroadcast(
            context,
            3000 + widgetId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE,
        )
    }
}
