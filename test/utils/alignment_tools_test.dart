import 'package:flutter_test/flutter_test.dart';
import 'package:formbuilder/form_layout/utils/alignment_tools.dart';
import 'package:formbuilder/form_layout/models/widget_placement.dart';
import 'package:formbuilder/form_layout/models/grid_dimensions.dart';

void main() {
  group('AlignmentTools', () {
    late AlignmentTools alignmentTools;
    const gridDimensions = GridDimensions(columns: 10, rows: 10);

    setUp(() {
      alignmentTools = AlignmentTools();
    });

    group('align widgets', () {
      test('should align widgets to left', () {
        final widgets = [
          WidgetPlacement(
            id: '1',
            widgetName: 'widget1',
            column: 2,
            row: 1,
            width: 2,
            height: 1,
          ),
          WidgetPlacement(
            id: '2',
            widgetName: 'widget2',
            column: 3,
            row: 3,
            width: 2,
            height: 1,
          ),
          WidgetPlacement(
            id: '3',
            widgetName: 'widget3',
            column: 1,
            row: 5,
            width: 2,
            height: 1,
          ),
        ];

        final aligned = alignmentTools.alignWidgets(
          widgets: widgets,
          alignment: WidgetAlignment.left,
          gridDimensions: gridDimensions,
        );

        // All widgets should have the same left edge (column 1)
        expect(aligned[0].column, equals(1));
        expect(aligned[1].column, equals(1));
        expect(aligned[2].column, equals(1));
      });

      test('should align widgets to right', () {
        final widgets = [
          WidgetPlacement(
            id: '1',
            widgetName: 'widget1',
            column: 2,
            row: 1,
            width: 2,
            height: 1,
          ),
          WidgetPlacement(
            id: '2',
            widgetName: 'widget2',
            column: 3,
            row: 3,
            width: 3,
            height: 1,
          ),
        ];

        final aligned = alignmentTools.alignWidgets(
          widgets: widgets,
          alignment: WidgetAlignment.right,
          gridDimensions: gridDimensions,
        );

        // All widgets should have the same right edge
        expect(
          aligned[0].column + aligned[0].width,
          equals(6),
        ); // Widget 2's right edge
        expect(aligned[1].column + aligned[1].width, equals(6));
      });

      test('should align widgets to center horizontally', () {
        final widgets = [
          WidgetPlacement(
            id: '1',
            widgetName: 'widget1',
            column: 1,
            row: 1,
            width: 2,
            height: 1,
          ),
          WidgetPlacement(
            id: '2',
            widgetName: 'widget2',
            column: 5,
            row: 3,
            width: 4,
            height: 1,
          ),
        ];

        final aligned = alignmentTools.alignWidgets(
          widgets: widgets,
          alignment: WidgetAlignment.centerHorizontal,
          gridDimensions: gridDimensions,
        );

        // All widgets should have the same center X
        final center1 = aligned[0].column + aligned[0].width / 2.0;
        final center2 = aligned[1].column + aligned[1].width / 2.0;
        expect(center1, equals(center2));
      });

      test('should align widgets to top', () {
        final widgets = [
          WidgetPlacement(
            id: '1',
            widgetName: 'widget1',
            column: 1,
            row: 2,
            width: 2,
            height: 1,
          ),
          WidgetPlacement(
            id: '2',
            widgetName: 'widget2',
            column: 4,
            row: 1,
            width: 2,
            height: 1,
          ),
        ];

        final aligned = alignmentTools.alignWidgets(
          widgets: widgets,
          alignment: WidgetAlignment.top,
          gridDimensions: gridDimensions,
        );

        // All widgets should have the same top edge
        expect(aligned[0].row, equals(1));
        expect(aligned[1].row, equals(1));
      });
    });

    group('distribute widgets', () {
      test('should distribute widgets evenly horizontally', () {
        final widgets = [
          WidgetPlacement(
            id: '1',
            widgetName: 'widget1',
            column: 0,
            row: 1,
            width: 1,
            height: 1,
          ),
          WidgetPlacement(
            id: '2',
            widgetName: 'widget2',
            column: 2,
            row: 1,
            width: 1,
            height: 1,
          ),
          WidgetPlacement(
            id: '3',
            widgetName: 'widget3',
            column: 6,
            row: 1,
            width: 1,
            height: 1,
          ),
        ];

        final distributed = alignmentTools.distributeWidgets(
          widgets: widgets,
          distribution: DistributionType.horizontalEvenly,
          gridDimensions: gridDimensions,
        );

        // Check that spacing between widgets is equal
        final spacing1 =
            distributed[1].column -
            (distributed[0].column + distributed[0].width);
        final spacing2 =
            distributed[2].column -
            (distributed[1].column + distributed[1].width);
        expect(spacing1, equals(spacing2));
      });

      test('should distribute widgets evenly vertically', () {
        final widgets = [
          WidgetPlacement(
            id: '1',
            widgetName: 'widget1',
            column: 1,
            row: 0,
            width: 1,
            height: 1,
          ),
          WidgetPlacement(
            id: '2',
            widgetName: 'widget2',
            column: 1,
            row: 2,
            width: 1,
            height: 1,
          ),
          WidgetPlacement(
            id: '3',
            widgetName: 'widget3',
            column: 1,
            row: 6,
            width: 1,
            height: 1,
          ),
        ];

        final distributed = alignmentTools.distributeWidgets(
          widgets: widgets,
          distribution: DistributionType.verticalEvenly,
          gridDimensions: gridDimensions,
        );

        // Check that spacing between widgets is equal
        final spacing1 =
            distributed[1].row - (distributed[0].row + distributed[0].height);
        final spacing2 =
            distributed[2].row - (distributed[1].row + distributed[1].height);
        expect(spacing1, equals(spacing2));
      });
    });

    group('match sizes', () {
      test('should match widget widths to largest', () {
        final widgets = [
          WidgetPlacement(
            id: '1',
            widgetName: 'widget1',
            column: 0,
            row: 0,
            width: 2,
            height: 1,
          ),
          WidgetPlacement(
            id: '2',
            widgetName: 'widget2',
            column: 0,
            row: 2,
            width: 4,
            height: 1,
          ),
          WidgetPlacement(
            id: '3',
            widgetName: 'widget3',
            column: 0,
            row: 4,
            width: 3,
            height: 1,
          ),
        ];

        final matched = alignmentTools.matchSizes(
          widgets: widgets,
          sizeType: SizeMatchType.width,
          gridDimensions: gridDimensions,
        );

        // All widgets should have width 4 (the largest)
        expect(matched[0].width, equals(4));
        expect(matched[1].width, equals(4));
        expect(matched[2].width, equals(4));
      });

      test('should match widget heights to largest', () {
        final widgets = [
          WidgetPlacement(
            id: '1',
            widgetName: 'widget1',
            column: 0,
            row: 0,
            width: 2,
            height: 1,
          ),
          WidgetPlacement(
            id: '2',
            widgetName: 'widget2',
            column: 3,
            row: 0,
            width: 2,
            height: 3,
          ),
          WidgetPlacement(
            id: '3',
            widgetName: 'widget3',
            column: 6,
            row: 0,
            width: 2,
            height: 2,
          ),
        ];

        final matched = alignmentTools.matchSizes(
          widgets: widgets,
          sizeType: SizeMatchType.height,
          gridDimensions: gridDimensions,
        );

        // All widgets should have height 3 (the largest)
        expect(matched[0].height, equals(3));
        expect(matched[1].height, equals(3));
        expect(matched[2].height, equals(3));
      });

      test('should match both dimensions', () {
        final widgets = [
          WidgetPlacement(
            id: '1',
            widgetName: 'widget1',
            column: 0,
            row: 0,
            width: 2,
            height: 1,
          ),
          WidgetPlacement(
            id: '2',
            widgetName: 'widget2',
            column: 3,
            row: 0,
            width: 3,
            height: 2,
          ),
        ];

        final matched = alignmentTools.matchSizes(
          widgets: widgets,
          sizeType: SizeMatchType.both,
          gridDimensions: gridDimensions,
        );

        // All widgets should have width 3 and height 2
        expect(matched[0].width, equals(3));
        expect(matched[0].height, equals(2));
        expect(matched[1].width, equals(3));
        expect(matched[1].height, equals(2));
      });
    });

    group('group operations', () {
      test('should perform group alignment maintaining relative positions', () {
        final widgets = [
          WidgetPlacement(
            id: '1',
            widgetName: 'widget1',
            column: 2,
            row: 1,
            width: 2,
            height: 1,
          ),
          WidgetPlacement(
            id: '2',
            widgetName: 'widget2',
            column: 4,
            row: 2,
            width: 2,
            height: 1,
          ),
        ];

        final aligned = alignmentTools.groupAlign(
          widgets: widgets,
          alignment: GroupAlignment.topLeft,
          gridDimensions: gridDimensions,
        );

        // Group should move to top-left while maintaining relative positions
        expect(aligned[0].column, equals(0));
        expect(aligned[0].row, equals(0));
        expect(aligned[1].column, equals(2)); // Maintains 2-column offset
        expect(aligned[1].row, equals(1)); // Maintains 1-row offset
      });
    });
  });

  group('Enums', () {
    test('WidgetAlignment should have all alignment values', () {
      expect(WidgetAlignment.values, contains(WidgetAlignment.left));
      expect(WidgetAlignment.values, contains(WidgetAlignment.right));
      expect(
        WidgetAlignment.values,
        contains(WidgetAlignment.centerHorizontal),
      );
      expect(WidgetAlignment.values, contains(WidgetAlignment.top));
      expect(WidgetAlignment.values, contains(WidgetAlignment.bottom));
      expect(WidgetAlignment.values, contains(WidgetAlignment.centerVertical));
    });

    test('DistributionType should have all distribution values', () {
      expect(
        DistributionType.values,
        contains(DistributionType.horizontalEvenly),
      );
      expect(
        DistributionType.values,
        contains(DistributionType.verticalEvenly),
      );
    });

    test('SizeMatchType should have all size match values', () {
      expect(SizeMatchType.values, contains(SizeMatchType.width));
      expect(SizeMatchType.values, contains(SizeMatchType.height));
      expect(SizeMatchType.values, contains(SizeMatchType.both));
    });

    test('GroupAlignment should have all group alignment values', () {
      expect(GroupAlignment.values, contains(GroupAlignment.topLeft));
      expect(GroupAlignment.values, contains(GroupAlignment.topRight));
      expect(GroupAlignment.values, contains(GroupAlignment.bottomLeft));
      expect(GroupAlignment.values, contains(GroupAlignment.bottomRight));
      expect(GroupAlignment.values, contains(GroupAlignment.center));
    });
  });
}
