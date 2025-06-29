import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';

class MetricCardWidget extends StatelessWidget {
  final WidgetPlacement placement;
  final bool liveData;

  const MetricCardWidget({
    super.key,
    required this.placement,
    required this.liveData,
  });

  @override
  Widget build(BuildContext context) {
    final random = math.Random();
    final value = liveData 
        ? (10000 + random.nextInt(5000)).toStringAsFixed(0)
        : '12,345';
    final trend = liveData ? random.nextBool() : true;
    final percentage = liveData 
        ? (5 + random.nextDouble() * 10).toStringAsFixed(1)
        : '8.5';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Sales',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (liveData)
                Icon(
                  Icons.circle,
                  size: 8,
                  color: Colors.green,
                ),
            ],
          ),
          Text(
            '\$$value',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Icon(
                trend ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: trend ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                '$percentage%',
                style: TextStyle(
                  color: trend ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'vs last month',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DataTableWidget extends StatelessWidget {
  final WidgetPlacement placement;
  final bool liveData;

  const DataTableWidget({
    super.key,
    required this.placement,
    required this.liveData,
  });

  @override
  Widget build(BuildContext context) {
    final rows = _generateTableData();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Products',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (liveData)
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: Colors.green,
                  ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Product')),
                  DataColumn(label: Text('Sales'), numeric: true),
                  DataColumn(label: Text('Growth'), numeric: true),
                ],
                rows: rows.map((row) => DataRow(
                  cells: [
                    DataCell(Text(row['product'])),
                    DataCell(Text('\$${row['sales']}')),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            row['growth'] > 0 
                                ? Icons.arrow_upward 
                                : Icons.arrow_downward,
                            size: 14,
                            color: row['growth'] > 0 
                                ? Colors.green 
                                : Colors.red,
                          ),
                          Text(
                            '${row['growth']}%',
                            style: TextStyle(
                              color: row['growth'] > 0 
                                  ? Colors.green 
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateTableData() {
    final random = math.Random();
    final products = ['Widget A', 'Widget B', 'Widget C', 'Widget D', 'Widget E'];
    
    return products.map((product) => {
      'product': product,
      'sales': (1000 + random.nextInt(4000)).toString(),
      'growth': -10 + random.nextInt(30),
    }).toList();
  }
}

class ProgressCardWidget extends StatelessWidget {
  final WidgetPlacement placement;
  final bool liveData;

  const ProgressCardWidget({
    super.key,
    required this.placement,
    required this.liveData,
  });

  @override
  Widget build(BuildContext context) {
    final random = math.Random();
    final progress = liveData ? random.nextDouble() : 0.75;
    final percentage = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Goal',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (liveData)
                Icon(
                  Icons.circle,
                  size: 8,
                  color: Colors.green,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$percentage%',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Theme.of(context).dividerColor,
          ),
          const SizedBox(height: 8),
          Text(
            '\$${(progress * 50000).toStringAsFixed(0)} of \$50,000',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class StatusWidget extends StatelessWidget {
  final WidgetPlacement placement;
  final bool liveData;

  const StatusWidget({
    super.key,
    required this.placement,
    required this.liveData,
  });

  @override
  Widget build(BuildContext context) {
    final random = math.Random();
    final isOnline = liveData ? random.nextBool() : true;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isOnline ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOnline ? Icons.check : Icons.close,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'System Status',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  isOnline ? 'All Systems Operational' : 'Service Disruption',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isOnline ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (liveData)
            Icon(
              Icons.circle,
              size: 8,
              color: Colors.green,
            ),
        ],
      ),
    );
  }
}

class AlertWidget extends StatelessWidget {
  final WidgetPlacement placement;
  final bool liveData;

  const AlertWidget({
    super.key,
    required this.placement,
    required this.liveData,
  });

  @override
  Widget build(BuildContext context) {
    final random = math.Random();
    final alertCount = liveData ? random.nextInt(5) : 2;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alertCount > 0 
            ? Colors.orange.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: alertCount > 0 ? Colors.orange : Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        children: [
          Icon(
            alertCount > 0 ? Icons.warning : Icons.check_circle,
            color: alertCount > 0 ? Colors.orange : Colors.green,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  alertCount > 0 ? 'Active Alerts' : 'No Alerts',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  alertCount > 0 
                      ? '$alertCount issues require attention'
                      : 'Everything is running smoothly',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (liveData)
            Icon(
              Icons.circle,
              size: 8,
              color: Colors.green,
            ),
        ],
      ),
    );
  }
}