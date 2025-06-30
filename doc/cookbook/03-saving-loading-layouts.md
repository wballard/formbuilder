# Saving and Loading Layouts

Learn how to persist form layouts locally and remotely.

## Overview

FormBuilder layouts can be serialized to JSON, making it easy to:
- Save layouts locally using SharedPreferences
- Store layouts in a database
- Sync layouts with a backend API
- Export/import layouts between devices

## Local Storage with SharedPreferences

### Basic Save and Load

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LayoutPersistence {
  static const String _layoutKey = 'saved_form_layout';

  /// Save a layout to local storage
  static Future<bool> saveLayout(LayoutState layout) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = layout.toJson();
      final jsonString = jsonEncode(json);
      return await prefs.setString(_layoutKey, jsonString);
    } catch (e) {
      print('Error saving layout: $e');
      return false;
    }
  }

  /// Load a layout from local storage
  static Future<LayoutState?> loadLayout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_layoutKey);
      
      if (jsonString == null) {
        return null;
      }
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return LayoutState.fromJson(json);
    } catch (e) {
      print('Error loading layout: $e');
      return null;
    }
  }

  /// Delete saved layout
  static Future<bool> deleteLayout() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_layoutKey);
  }
}
```

### Integration with FormLayout

```dart
class PersistentFormBuilder extends StatefulWidget {
  @override
  _PersistentFormBuilderState createState() => _PersistentFormBuilderState();
}

class _PersistentFormBuilderState extends State<PersistentFormBuilder> {
  LayoutState? _initialLayout;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedLayout();
  }

  Future<void> _loadSavedLayout() async {
    final layout = await LayoutPersistence.loadLayout();
    setState(() {
      _initialLayout = layout;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Form Builder'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await _showDeleteConfirmation();
              if (confirmed) {
                await LayoutPersistence.deleteLayout();
                setState(() {
                  _initialLayout = null;
                });
              }
            },
            tooltip: 'Clear Layout',
          ),
        ],
      ),
      body: FormLayout(
        toolbox: createToolbox(),
        initialLayout: _initialLayout,
        onLayoutChanged: (layout) {
          // Save automatically with debouncing
          _debouncedSave(layout);
        },
      ),
    );
  }

  Timer? _saveTimer;
  
  void _debouncedSave(LayoutState layout) {
    _saveTimer?.cancel();
    _saveTimer = Timer(Duration(milliseconds: 500), () {
      LayoutPersistence.saveLayout(layout);
    });
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Layout?'),
        content: Text('This will delete the current form layout.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }
}
```

## Multiple Layout Management

Save and manage multiple layouts:

```dart
class LayoutManager {
  static const String _layoutsKey = 'form_layouts';
  
  /// Save a layout with a specific name
  static Future<void> saveNamedLayout(String name, LayoutState layout) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing layouts
    final layoutsJson = prefs.getString(_layoutsKey);
    final layouts = layoutsJson != null 
        ? Map<String, dynamic>.from(jsonDecode(layoutsJson))
        : <String, dynamic>{};
    
    // Add/update layout
    layouts[name] = {
      'name': name,
      'layout': layout.toJson(),
      'savedAt': DateTime.now().toIso8601String(),
    };
    
    // Save back
    await prefs.setString(_layoutsKey, jsonEncode(layouts));
  }
  
  /// Get all saved layouts
  static Future<Map<String, SavedLayout>> getAllLayouts() async {
    final prefs = await SharedPreferences.getInstance();
    final layoutsJson = prefs.getString(_layoutsKey);
    
    if (layoutsJson == null) {
      return {};
    }
    
    final layoutsMap = Map<String, dynamic>.from(jsonDecode(layoutsJson));
    final result = <String, SavedLayout>{};
    
    layoutsMap.forEach((key, value) {
      try {
        result[key] = SavedLayout.fromJson(value);
      } catch (e) {
        print('Error loading layout $key: $e');
      }
    });
    
    return result;
  }
  
  /// Delete a named layout
  static Future<void> deleteNamedLayout(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final layoutsJson = prefs.getString(_layoutsKey);
    
    if (layoutsJson == null) return;
    
    final layouts = Map<String, dynamic>.from(jsonDecode(layoutsJson));
    layouts.remove(name);
    
    await prefs.setString(_layoutsKey, jsonEncode(layouts));
  }
}

class SavedLayout {
  final String name;
  final LayoutState layout;
  final DateTime savedAt;
  
  SavedLayout({
    required this.name,
    required this.layout,
    required this.savedAt,
  });
  
  factory SavedLayout.fromJson(Map<String, dynamic> json) {
    return SavedLayout(
      name: json['name'],
      layout: LayoutState.fromJson(json['layout']),
      savedAt: DateTime.parse(json['savedAt']),
    );
  }
}
```

### Layout Selection UI

```dart
class LayoutSelectionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, SavedLayout>>(
      future: LayoutManager.getAllLayouts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        
        final layouts = snapshot.data!;
        
        if (layouts.isEmpty) {
          return AlertDialog(
            title: Text('No Saved Layouts'),
            content: Text('Create and save a layout first.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        }
        
        return AlertDialog(
          title: Text('Select Layout'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: layouts.length,
              itemBuilder: (context, index) {
                final entry = layouts.entries.elementAt(index);
                final layout = entry.value;
                
                return ListTile(
                  title: Text(layout.name),
                  subtitle: Text(
                    'Saved ${_formatDate(layout.savedAt)} • '
                    '${layout.layout.widgets.length} widgets',
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await LayoutManager.deleteNamedLayout(entry.key);
                      Navigator.of(context).pop();
                      // Refresh dialog
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).pop(layout.layout);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
```

## Backend Storage

Store layouts on a server:

```dart
class LayoutApiService {
  final String baseUrl;
  final http.Client client;
  
  LayoutApiService({
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();
  
  /// Save layout to backend
  Future<String?> saveLayout({
    required String userId,
    required String formName,
    required LayoutState layout,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/layouts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          'userId': userId,
          'formName': formName,
          'layout': layout.toJson(),
          'version': '1.0.0',
          'createdAt': DateTime.now().toIso8601String(),
        }),
      );
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id']; // Return layout ID
      } else {
        print('Failed to save layout: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error saving layout: $e');
      return null;
    }
  }
  
  /// Load layout from backend
  Future<LayoutState?> loadLayout(String layoutId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/layouts/$layoutId'),
        headers: {
          'Authorization': 'Bearer $userToken',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LayoutState.fromJson(data['layout']);
      } else {
        print('Failed to load layout: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error loading layout: $e');
      return null;
    }
  }
  
  /// List user's layouts
  Future<List<LayoutSummary>> listLayouts(String userId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/users/$userId/layouts'),
        headers: {
          'Authorization': 'Bearer $userToken',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => LayoutSummary.fromJson(item)).toList();
      } else {
        print('Failed to list layouts: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error listing layouts: $e');
      return [];
    }
  }
}

class LayoutSummary {
  final String id;
  final String formName;
  final int widgetCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  LayoutSummary({
    required this.id,
    required this.formName,
    required this.widgetCount,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory LayoutSummary.fromJson(Map<String, dynamic> json) {
    return LayoutSummary(
      id: json['id'],
      formName: json['formName'],
      widgetCount: json['widgetCount'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}
```

## Export/Import Features

Add export and import functionality:

```dart
class ExportImportExample extends StatelessWidget {
  final LayoutState currentLayout;
  
  const ExportImportExample({required this.currentLayout});
  
  @override
  Widget build(BuildContext context) {
    return FormLayout(
      toolbox: createToolbox(),
      initialLayout: currentLayout,
      onExportLayout: (jsonString) async {
        // Option 1: Copy to clipboard
        await Clipboard.setData(ClipboardData(text: jsonString));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Layout copied to clipboard')),
        );
        
        // Option 2: Share via platform share
        await Share.share(
          jsonString,
          subject: 'Form Layout Export',
        );
        
        // Option 3: Save to file
        if (kIsWeb) {
          // Web download
          final bytes = utf8.encode(jsonString);
          final blob = html.Blob([bytes]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement()
            ..href = url
            ..download = 'form_layout.json';
          anchor.click();
          html.Url.revokeObjectUrl(url);
        } else {
          // Mobile file save
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/form_layout.json');
          await file.writeAsString(jsonString);
        }
      },
      onImportLayout: (layout, error) {
        if (error != null) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Import Failed'),
              content: Text(error),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } else if (layout != null) {
          // Successfully imported
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Layout imported: ${layout.widgets.length} widgets',
              ),
            ),
          );
        }
      },
    );
  }
}
```

## Best Practices

### 1. Error Handling
Always handle serialization errors gracefully:
```dart
try {
  final layout = LayoutState.fromJson(json);
  return layout;
} catch (e) {
  // Log error and return default or show message
  debugPrint('Invalid layout data: $e');
  return LayoutState.empty();
}
```

### 2. Version Management
Include version information for compatibility:
```dart
final layoutData = {
  'version': '1.0.0',
  'layout': layout.toJson(),
  'metadata': {
    'createdWith': 'FormBuilder v1.0.0',
    'platform': Platform.operatingSystem,
  },
};
```

### 3. Data Validation
Validate layouts after loading:
```dart
bool isValidLayout(LayoutState layout) {
  // Check for required properties
  if (layout.widgets.isEmpty) {
    return true; // Empty layouts are valid
  }
  
  // Validate each widget
  for (final widget in layout.widgets) {
    if (!widget.fitsInGrid(layout.dimensions)) {
      return false;
    }
  }
  
  return true;
}
```

### 4. Compression
For large layouts, consider compression:
```dart
import 'dart:io';

String compressLayout(String jsonString) {
  final bytes = utf8.encode(jsonString);
  final compressed = gzip.encode(bytes);
  return base64.encode(compressed);
}

String decompressLayout(String compressed) {
  final bytes = base64.decode(compressed);
  final decompressed = gzip.decode(bytes);
  return utf8.decode(decompressed);
}
```

## Next Steps

- [Implement auto-save](../advanced/auto-save.md) with conflict resolution
- [Add version control](../advanced/versioning.md) for layout history
- [Create backup strategies](../advanced/backup.md) for important forms