package com.todoaw.todoaw.widget

import android.content.Intent
import android.graphics.Paint
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import com.todoaw.todoaw.R
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Backs the scrollable task list in [TodayWidget].
 *
 * A plain RemoteViews layout cannot scroll, so the list is adapter-backed and
 * this service supplies one row per task from the `todayTaskList` snapshot.
 * The payload already carries completed tasks: they stay in chronological
 * position and render struck-through + dimmed so done-vs-not-done is obvious
 * at a glance.
 */
class TodayWidgetRemoteViewsService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory =
        TodayWidgetRemoteViewsFactory(applicationContext, intent)
}

class TodayWidgetRemoteViewsFactory(
    private val context: android.content.Context,
    @Suppress("unused") private val intent: Intent,
) : RemoteViewsService.RemoteViewsFactory {

    private var items: List<WidgetTaskItem> = emptyList()

    // Replaced on every onDataSetChanged; only a sane default before the first
    // data pass (the system calls onDataSetChanged before any getViewAt).
    private var palette: WidgetPalette = WidgetTheme.palette(HomeWidgetPlugin.getData(context))

    override fun onCreate() = Unit

    override fun onDataSetChanged() {
        val data = HomeWidgetPlugin.getData(context)
        palette = WidgetTheme.palette(data)
        items = WidgetData.todayTasks(data)
    }

    override fun onDestroy() {
        items = emptyList()
    }

    override fun getCount(): Int = items.size

    override fun getViewAt(position: Int): RemoteViews {
        val item = items[position]
        val views = RemoteViews(context.packageName, R.layout.widget_today_row)

        views.setTextViewText(R.id.widget_today_row_title, item.title)
        views.setTextViewText(R.id.widget_today_row_time, item.time)
        views.setTextColor(R.id.widget_today_row_time, palette.muted)

        if (item.done) {
            // Checked: strike the title out and dim both labels so finished
            // items read as "done" while staying in their time slot.
            views.setInt(
                R.id.widget_today_row_title,
                "setPaintFlags",
                Paint.STRIKE_THRU_TEXT_FLAG or Paint.ANTI_ALIAS_FLAG,
            )
            views.setTextColor(R.id.widget_today_row_title, palette.muted)
            views.setInt(
                R.id.widget_today_row_checkbox,
                "setBackgroundResource",
                R.drawable.widget_checkbox_done,
            )
        } else {
            // RemoteViews re-inflate the row from the layout each time, so the
            // flags must be reset explicitly or a recycled row stays struck.
            views.setInt(R.id.widget_today_row_title, "setPaintFlags", Paint.ANTI_ALIAS_FLAG)
            views.setTextColor(R.id.widget_today_row_title, palette.text)
            views.setInt(
                R.id.widget_today_row_checkbox,
                "setBackgroundResource",
                R.drawable.widget_checkbox_todo,
            )
        }

        // One template PendingIntent covers the whole list (set in TodayWidget);
        // the per-row uuid travels here as a fill-in extra.
        val fillIn = Intent().apply { putExtra("uuid", item.uuid) }
        views.setOnClickFillInIntent(R.id.widget_today_row_root, fillIn)

        return views
    }

    override fun getViewTypeCount(): Int = 1

    override fun getLoadingView(): RemoteViews? = null

    override fun hasStableIds(): Boolean = true

    override fun getItemId(position: Int): Long = items[position].uuid.hashCode().toLong()
}
