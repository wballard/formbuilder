import 'dart:convert';
import 'package:formbuilder/form_layout/models/layout_state.dart';

/// Utility class for serializing and deserializing layout states
class LayoutSerializer {
  /// Convert a LayoutState to a JSON string
  static String toJsonString(LayoutState layout) {
    try {
      final json = layout.toJson();
      return jsonEncode(json);
    } catch (e) {
      // If serialization fails, return empty JSON
      return '{}';
    }
  }

  /// Convert a JSON string to a LayoutState
  /// Returns null if the JSON is invalid or cannot be deserialized
  static LayoutState? fromJsonString(String jsonString) {
    if (jsonString.isEmpty) {
      return null;
    }

    try {
      final dynamic jsonData = jsonDecode(jsonString);
      
      if (jsonData is! Map<String, dynamic>) {
        return null;
      }

      // Validate that required fields exist
      if (!_validateRequiredFields(jsonData)) {
        return null;
      }

      // Attempt to create LayoutState
      final layout = LayoutState.fromJson(jsonData);
      
      // Validate the created layout for data integrity
      if (!_validateDataIntegrity(layout)) {
        return null;
      }

      return layout;
    } catch (e) {
      // Return null for any parsing errors
      return null;
    }
  }

  /// Validate that required fields exist in the JSON data
  static bool _validateRequiredFields(Map<String, dynamic> json) {
    // Check for dimensions
    if (!json.containsKey('dimensions')) {
      return false;
    }
    
    final dimensions = json['dimensions'];
    if (dimensions is! Map<String, dynamic>) {
      return false;
    }
    
    if (!dimensions.containsKey('columns') || !dimensions.containsKey('rows')) {
      return false;
    }

    // Check for widgets array
    if (!json.containsKey('widgets')) {
      return false;
    }
    
    if (json['widgets'] is! List) {
      return false;
    }

    return true;
  }

  /// Validate data integrity of the layout
  static bool _validateDataIntegrity(LayoutState layout) {
    try {
      // Check that all widgets fit in the grid
      for (final widget in layout.widgets) {
        if (!widget.fitsInGrid(layout.dimensions)) {
          return false;
        }
      }

      // Check for duplicate widget IDs
      final ids = layout.widgets.map((w) => w.id).toSet();
      if (ids.length != layout.widgets.length) {
        return false;
      }

      // Check for overlapping widgets
      for (int i = 0; i < layout.widgets.length; i++) {
        for (int j = i + 1; j < layout.widgets.length; j++) {
          if (layout.widgets[i].overlaps(layout.widgets[j])) {
            return false;
          }
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Export a layout state with additional metadata
  static Map<String, dynamic> exportLayout(LayoutState layout) {
    final json = layout.toJson();
    
    // Add export-specific metadata
    json['exportMetadata'] = {
      'exportedAt': DateTime.now().toIso8601String(),
      'exportVersion': '1.0.0',
      'description': 'Form layout exported from Form Builder',
    };

    return json;
  }

  /// Import a layout state with validation
  static LayoutState? importLayout(Map<String, dynamic> json) {
    try {
      // Remove export-specific metadata if present
      final cleanJson = Map<String, dynamic>.from(json);
      cleanJson.remove('exportMetadata');

      // Validate and import
      final jsonString = jsonEncode(cleanJson);
      return fromJsonString(jsonString);
    } catch (e) {
      return null;
    }
  }

  /// Get version from JSON string
  static String? getVersion(String jsonString) {
    try {
      final dynamic jsonData = jsonDecode(jsonString);
      if (jsonData is Map<String, dynamic>) {
        return jsonData['version'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if a JSON string represents a valid layout
  static bool isValidLayout(String jsonString) {
    final layout = fromJsonString(jsonString);
    return layout != null;
  }

  /// Get layout statistics from JSON string without full deserialization
  static Map<String, dynamic>? getLayoutStats(String jsonString) {
    try {
      final dynamic jsonData = jsonDecode(jsonString);
      if (jsonData is! Map<String, dynamic>) {
        return null;
      }

      final metadata = jsonData['metadata'] as Map<String, dynamic>?;
      final widgets = jsonData['widgets'] as List?;
      final dimensions = jsonData['dimensions'] as Map<String, dynamic>?;

      return {
        'version': jsonData['version'],
        'timestamp': jsonData['timestamp'],
        'widgetCount': metadata?['widgetCount'] ?? widgets?.length ?? 0,
        'gridSize': metadata?['gridSize'] ?? 
            (dimensions != null ? 
                (dimensions['columns'] as int? ?? 0) * (dimensions['rows'] as int? ?? 0) : 0),
        'totalArea': metadata?['totalArea'] ?? 0,
      };
    } catch (e) {
      return null;
    }
  }

  /// Migrate layout from older version to current version
  static LayoutState? migrateLayout(String jsonString, String fromVersion) {
    // For now, we only support version 1.0.0, so migration is just validation
    // Future versions could implement actual migration logic here
    
    try {
      final layout = fromJsonString(jsonString);
      if (layout != null) {
        // Re-serialize with current version to update metadata
        final currentJson = layout.toJson();
        final currentJsonString = jsonEncode(currentJson);
        return fromJsonString(currentJsonString);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}