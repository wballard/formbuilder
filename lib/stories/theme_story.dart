import 'package:flutter/material.dart';
import 'dart:math';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'package:formbuilder/form_layout/widgets/grid_widget.dart';
import 'package:formbuilder/form_layout/widgets/toolbox_widget.dart';
import 'package:formbuilder/form_layout/widgets/placed_widget.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/theme/form_layout_theme.dart';

/// Storybook stories for FormLayoutTheme
Widget buildThemeStories() {
  return DefaultTabController(
    length: 5,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('FormLayout Theme Gallery'),
        bottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'Material'),
            Tab(text: 'Dark Material'),
            Tab(text: 'Cupertino'),
            Tab(text: 'High Contrast'),
            Tab(text: 'Custom'),
          ],
        ),
      ),
      body: const TabBarView(
        children: [
          _ThemeDemo(
            title: 'Material Design Theme',
            theme: null, // Uses default Material theme
          ),
          _ThemeDemo(
            title: 'Dark Material Theme',
            theme: null, // Uses default Material theme
            darkMode: true,
          ),
          _ThemeDemo(title: 'Cupertino Theme', theme: 'cupertino'),
          _ThemeDemo(title: 'High Contrast Theme', theme: 'highContrast'),
          _ThemeDemo(title: 'Custom Theme', theme: 'custom'),
        ],
      ),
    ),
  );
}

class _ThemeDemo extends StatelessWidget {
  final String title;
  final String? theme;
  final bool darkMode;

  const _ThemeDemo({required this.title, this.theme, this.darkMode = false});

  FormLayoutTheme _getTheme(BuildContext context) {
    switch (theme) {
      case 'cupertino':
        return FormLayoutTheme.cupertino();
      case 'highContrast':
        return FormLayoutTheme.highContrast();
      case 'custom':
        return const FormLayoutTheme(
          gridLineColor: Color(0xFF9C27B0),
          gridBackgroundColor: Color(0xFFF3E5F5),
          selectionBorderColor: Color(0xFF673AB7),
          dragHighlightColor: Color(0x4D673AB7),
          invalidDropColor: Color(0x4DFF5722),
          toolboxBackgroundColor: Color(0xFFE1BEE7),
          labelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A148C),
          ),
          widgetBorderRadius: BorderRadius.all(Radius.circular(12.0)),
          elevations: 3.0,
          defaultPadding: EdgeInsets.all(16.0),
        );
      default:
        final materialTheme = darkMode ? ThemeData.dark() : ThemeData.light();
        return FormLayoutTheme.fromThemeData(materialTheme);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formTheme = _getTheme(context);
    final materialTheme = darkMode ? ThemeData.dark() : ThemeData.light();

    return Theme(
      data: materialTheme,
      child: FormLayoutThemeWidget(
        theme: formTheme,
        child: Scaffold(
          backgroundColor: formTheme.gridBackgroundColor,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Theme title and description
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: formTheme.defaultPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: formTheme.labelStyle.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This demo shows how the form builder looks with different themes.',
                          style: formTheme.labelStyle,
                        ),
                      ],
                    ),
                  ),
                ),

                // Theme properties display
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: formTheme.defaultPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Theme Properties',
                          style: formTheme.labelStyle.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _PropertyRow(
                          'Grid Line Color',
                          formTheme.gridLineColor,
                        ),
                        _PropertyRow(
                          'Selection Border',
                          formTheme.selectionBorderColor,
                        ),
                        _PropertyRow(
                          'Drag Highlight',
                          formTheme.dragHighlightColor,
                        ),
                        _PropertyRow(
                          'Invalid Drop',
                          formTheme.invalidDropColor,
                        ),
                        _PropertyRow(
                          'Toolbox Background',
                          formTheme.toolboxBackgroundColor,
                        ),
                      ],
                    ),
                  ),
                ),

                // Live demo
                Expanded(
                  child: Row(
                    children: [
                      // Toolbox
                      SizedBox(
                        width: 120,
                        child: Card(
                          child: Column(
                            children: [
                              Padding(
                                padding: formTheme.defaultPadding,
                                child: Text(
                                  'Toolbox',
                                  style: formTheme.labelStyle,
                                ),
                              ),
                              Expanded(
                                child: ToolboxWidget(
                                  toolbox: Toolbox(
                                    items: [
                                      ToolboxItem(
                                        name: 'button',
                                        displayName: 'Button',
                                        defaultWidth: 1,
                                        defaultHeight: 1,
                                        toolboxBuilder: (context) =>
                                            ElevatedButton(
                                              onPressed: () {},
                                              child: const Text('Button'),
                                            ),
                                        gridBuilder: (context, placement) =>
                                            ElevatedButton(
                                              onPressed: () {},
                                              child: const Text('Button'),
                                            ),
                                      ),
                                      ToolboxItem(
                                        name: 'text',
                                        displayName: 'Text Field',
                                        defaultWidth: 2,
                                        defaultHeight: 1,
                                        toolboxBuilder: (context) =>
                                            const TextField(
                                              decoration: InputDecoration(
                                                hintText: 'Text',
                                              ),
                                            ),
                                        gridBuilder: (context, placement) =>
                                            const TextField(
                                              decoration: InputDecoration(
                                                hintText: 'Text',
                                              ),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Grid with placed widgets
                      Expanded(
                        child: Card(
                          child: Column(
                            children: [
                              Padding(
                                padding: formTheme.defaultPadding,
                                child: Text(
                                  'Form Builder',
                                  style: formTheme.labelStyle,
                                ),
                              ),
                              Expanded(
                                child: Stack(
                                  children: [
                                    GridWidget(
                                      dimensions: const GridDimensions(
                                        columns: 4,
                                        rows: 3,
                                      ),
                                      highlightedCells: {
                                        const Point(1, 1),
                                        const Point(2, 1),
                                      },
                                    ),
                                    Positioned(
                                      left: 100,
                                      top: 50,
                                      child: PlacedWidget(
                                        placement: WidgetPlacement(
                                          id: 'widget1',
                                          widgetName: 'button',
                                          column: 1,
                                          row: 0,
                                          width: 1,
                                          height: 1,
                                        ),
                                        isSelected: true,
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          child: const Text('Selected'),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 200,
                                      top: 120,
                                      child: PlacedWidget(
                                        placement: WidgetPlacement(
                                          id: 'widget2',
                                          widgetName: 'text',
                                          column: 2,
                                          row: 1,
                                          width: 1,
                                          height: 1,
                                        ),
                                        child: const TextField(
                                          decoration: InputDecoration(
                                            hintText: 'Normal',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PropertyRow extends StatelessWidget {
  final String label;
  final Color color;

  const _PropertyRow(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
