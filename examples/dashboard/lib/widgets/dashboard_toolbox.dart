import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/toolbox.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'chart_widgets/chart_widgets.dart';
import 'data_widgets/data_widgets.dart';

CategorizedToolbox createDashboardToolbox(bool liveData) {
  return CategorizedToolbox(
    categories: [
      ToolboxCategory(
        name: 'Charts',
        items: [
          ToolboxItem(
            name: 'line_chart',
            displayName: 'Line Chart',
            toolboxBuilder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.show_chart, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(height: 4),
                const Text('Line', style: TextStyle(fontSize: 11)),
              ],
            ),
            gridBuilder: (context, placement) => LineChartWidget(
              placement: placement,
              liveData: liveData,
            ),
            defaultWidth: 3,
            defaultHeight: 2,
          ),
          ToolboxItem(
            name: 'bar_chart',
            displayName: 'Bar Chart',
            toolboxBuilder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bar_chart, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(height: 4),
                const Text('Bar', style: TextStyle(fontSize: 11)),
              ],
            ),
            gridBuilder: (context, placement) => BarChartWidget(
              placement: placement,
              liveData: liveData,
            ),
            defaultWidth: 3,
            defaultHeight: 2,
          ),
          ToolboxItem(
            name: 'pie_chart',
            displayName: 'Pie Chart',
            toolboxBuilder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pie_chart, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(height: 4),
                const Text('Pie', style: TextStyle(fontSize: 11)),
              ],
            ),
            gridBuilder: (context, placement) => PieChartWidget(
              placement: placement,
              liveData: liveData,
            ),
            defaultWidth: 2,
            defaultHeight: 2,
          ),
        ],
      ),
      ToolboxCategory(
        name: 'Data Display',
        items: [
          ToolboxItem(
            name: 'metric_card',
            displayName: 'Metric Card',
            toolboxBuilder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.analytics, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(height: 4),
                const Text('Metric', style: TextStyle(fontSize: 11)),
              ],
            ),
            gridBuilder: (context, placement) => MetricCardWidget(
              placement: placement,
              liveData: liveData,
            ),
            defaultWidth: 2,
            defaultHeight: 1,
          ),
          ToolboxItem(
            name: 'data_table',
            displayName: 'Data Table',
            toolboxBuilder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.table_chart, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(height: 4),
                const Text('Table', style: TextStyle(fontSize: 11)),
              ],
            ),
            gridBuilder: (context, placement) => DataTableWidget(
              placement: placement,
              liveData: liveData,
            ),
            defaultWidth: 4,
            defaultHeight: 3,
          ),
          ToolboxItem(
            name: 'progress_card',
            displayName: 'Progress Card',
            toolboxBuilder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.donut_large, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(height: 4),
                const Text('Progress', style: TextStyle(fontSize: 11)),
              ],
            ),
            gridBuilder: (context, placement) => ProgressCardWidget(
              placement: placement,
              liveData: liveData,
            ),
            defaultWidth: 2,
            defaultHeight: 1,
          ),
        ],
      ),
      ToolboxCategory(
        name: 'Status',
        items: [
          ToolboxItem(
            name: 'status_widget',
            displayName: 'Status Widget',
            toolboxBuilder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(height: 4),
                const Text('Status', style: TextStyle(fontSize: 11)),
              ],
            ),
            gridBuilder: (context, placement) => StatusWidget(
              placement: placement,
              liveData: liveData,
            ),
            defaultWidth: 2,
            defaultHeight: 1,
          ),
          ToolboxItem(
            name: 'alert_widget',
            displayName: 'Alert Widget',
            toolboxBuilder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber, size: 24, color: Colors.orange),
                const SizedBox(height: 4),
                const Text('Alert', style: TextStyle(fontSize: 11)),
              ],
            ),
            gridBuilder: (context, placement) => AlertWidget(
              placement: placement,
              liveData: liveData,
            ),
            defaultWidth: 3,
            defaultHeight: 1,
          ),
        ],
      ),
    ],
  );
}