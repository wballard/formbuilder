# Dashboard Builder Example

This example demonstrates building interactive dashboards with various widget types including charts, data displays, and responsive layouts.

## Features

- Chart widgets (line, bar, pie charts)
- Data display widgets (cards, tables, metrics)
- Responsive grid layouts that adapt to screen size
- Real-time data updates with simulated data
- Export dashboard layouts

## Running the Example

```bash
flutter run -t examples/dashboard/lib/main.dart
```

## Key Components

- **DashboardBuilder**: Main widget for creating dashboards
- **Chart Widgets**: Various chart types for data visualization
- **Data Widgets**: Cards, metrics, and tables for displaying data
- **Responsive Layout**: Automatic adjustment for different screen sizes
- **Data Simulation**: Mock data generation for demonstration

## Usage

1. **Add Widgets**: Drag chart and data widgets from the toolbox
2. **Configure Data**: Set up data sources for each widget
3. **Resize & Position**: Arrange widgets on the responsive grid
4. **Preview**: See the dashboard with live data
5. **Export**: Save dashboard configuration for reuse

## Code Structure

```
dashboard/
├── lib/
│   ├── main.dart                  # Entry point
│   ├── dashboard_builder.dart     # Main dashboard builder widget
│   ├── models/
│   │   └── dashboard_data.dart    # Data models
│   └── widgets/
│       ├── chart_widgets/         # Chart components
│       ├── data_widgets/          # Data display components
│       └── dashboard_toolbox.dart # Widget toolbox
└── README.md
```

## Widget Types

### Charts
- Line Chart: Time series data
- Bar Chart: Categorical comparisons
- Pie Chart: Proportional data
- Area Chart: Cumulative values

### Data Display
- Metric Card: Single value with trend
- Data Table: Tabular information
- Progress Card: Goal tracking
- Status Widget: System status

## Best Practices Demonstrated

- Responsive design patterns
- Efficient data updates
- Clean widget architecture
- Performance optimization
- Accessibility support