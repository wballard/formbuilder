import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/utils/grid_snap_calculator.dart';
import 'package:formbuilder/form_layout/models/grid_snap_settings.dart';
import 'dart:math';

void main() {
  group('GridSnapCalculator', () {
    late GridSnapCalculator calculator;
    const cellSize = Size(100.0, 80.0); // Cell dimensions

    setUp(() {
      calculator = GridSnapCalculator();
    });

    test('should snap to full grid cells with no subdivision', () {
      const settings = GridSnapSettings(
        snapToGrid: true,
        subdivisions: GridSubdivision.none,
      );

      // Test various positions
      expect(
        calculator.snapPosition(Point(45.0, 35.0), cellSize, settings),
        equals(Point(0.0, 0.0)),
      );
      expect(
        calculator.snapPosition(Point(55.0, 45.0), cellSize, settings),
        equals(Point(100.0, 80.0)),
      );
      expect(
        calculator.snapPosition(Point(150.0, 120.0), cellSize, settings),
        equals(Point(200.0, 160.0)),
      );
    });

    test('should snap to half cells with half subdivision', () {
      const settings = GridSnapSettings(
        snapToGrid: true,
        subdivisions: GridSubdivision.half,
      );

      // Test snapping to half positions
      expect(
        calculator.snapPosition(Point(25.0, 20.0), cellSize, settings),
        equals(Point(50.0, 40.0)), // Snaps to half cell
      );
      expect(
        calculator.snapPosition(Point(75.0, 60.0), cellSize, settings),
        equals(Point(100.0, 80.0)), // Snaps to nearest half cell
      );
      expect(
        calculator.snapPosition(Point(125.0, 100.0), cellSize, settings),
        equals(Point(150.0, 120.0)), // 1.5 cells
      );
    });

    test('should snap to quarter cells with quarter subdivision', () {
      const settings = GridSnapSettings(
        snapToGrid: true,
        subdivisions: GridSubdivision.quarter,
      );

      // Test snapping to quarter positions
      expect(
        calculator.snapPosition(Point(12.0, 10.0), cellSize, settings),
        equals(
          Point(0.0, 20.0),
        ), // X: 12/25=0.48->0, 0*25=0. Y: 10/20=0.5->1, 1*20=20
      );
      expect(
        calculator.snapPosition(Point(37.0, 30.0), cellSize, settings),
        equals(
          Point(25.0, 40.0),
        ), // X: 37/25=1.48->1, 1*25=25. Y: 30/20=1.5->2, 2*20=40
      );
      expect(
        calculator.snapPosition(Point(62.0, 50.0), cellSize, settings),
        equals(
          Point(50.0, 60.0),
        ), // X: 62/25=2.48->2, 2*25=50. Y: 50/20=2.5->3, 3*20=60
      );
    });

    test('should not snap when free positioning is enabled', () {
      const settings = GridSnapSettings(
        snapToGrid: false,
        freePositioning: true,
      );

      final position = Point(123.45, 67.89);
      expect(
        calculator.snapPosition(position, cellSize, settings),
        equals(position),
      );
    });

    test('should calculate grid coordinates with subdivisions', () {
      expect(
        calculator.positionToGridCoordinate(50.0, 100.0, GridSubdivision.half),
        equals(0.5),
      );
      expect(
        calculator.positionToGridCoordinate(
          75.0,
          100.0,
          GridSubdivision.quarter,
        ),
        equals(0.75),
      );
      expect(
        calculator.positionToGridCoordinate(250.0, 100.0, GridSubdivision.half),
        equals(2.5),
      );
    });

    test('should convert grid coordinates back to position', () {
      expect(
        calculator.gridCoordinateToPosition(0.5, 100.0, GridSubdivision.half),
        equals(50.0),
      );
      expect(
        calculator.gridCoordinateToPosition(
          1.75,
          100.0,
          GridSubdivision.quarter,
        ),
        equals(175.0),
      );
      expect(
        calculator.gridCoordinateToPosition(3.0, 100.0, GridSubdivision.none),
        equals(300.0),
      );
    });

    test('should detect snap points for widget edges', () {
      const settings = GridSnapSettings(
        snapToWidgets: true,
        snapThreshold: 10.0,
      );

      final existingWidgets = [
        Rectangle(100, 100, 200, 150), // Widget at (100,100) size (200x150)
        Rectangle(400, 100, 200, 150), // Widget at (400,100) size (200x150)
      ];

      // Moving widget near the right edge of first widget
      final movingWidget = Rectangle(295, 120, 100, 80);
      final snapPoint = calculator.detectWidgetSnapPoint(
        movingWidget,
        existingWidgets,
        settings,
      );

      expect(snapPoint, isNotNull);
      expect(
        snapPoint!.x,
        equals(300.0),
      ); // Snapped to right edge of first widget
    });

    test('should not detect snap points beyond threshold', () {
      const settings = GridSnapSettings(
        snapToWidgets: true,
        snapThreshold: 10.0,
      );

      final existingWidgets = [Rectangle(100, 100, 200, 150)];

      // Moving widget too far from any edge
      final movingWidget = Rectangle(350, 120, 100, 80);
      final snapPoint = calculator.detectWidgetSnapPoint(
        movingWidget,
        existingWidgets,
        settings,
      );

      expect(snapPoint, isNull);
    });
  });
}
