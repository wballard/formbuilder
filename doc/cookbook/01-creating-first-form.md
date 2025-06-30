# Creating Your First Form

This guide walks you through creating your first form with FormBuilder.

## What You'll Build

A simple contact form with:
- Name field
- Email field
- Message text area
- Submit button

## Step 1: Set Up Your Project

First, add FormBuilder to your project:

```yaml
dependencies:
  formbuilder: ^1.0.0
```

## Step 2: Create the Basic Structure

```dart
import 'package:flutter/material.dart';
import 'package:formbuilder/formbuilder.dart';

class ContactFormBuilder extends StatefulWidget {
  @override
  _ContactFormBuilderState createState() => _ContactFormBuilderState();
}

class _ContactFormBuilderState extends State<ContactFormBuilder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Form Builder'),
      ),
      body: FormLayout(
        toolbox: _createToolbox(),
        onLayoutChanged: (layout) {
          print('Form updated with ${layout.widgets.length} widgets');
        },
      ),
    );
  }
}
```

## Step 3: Define Your Toolbox

Create a toolbox with the widgets users can add:

```dart
CategorizedToolbox _createToolbox() {
  return CategorizedToolbox(
    categories: [
      ToolboxCategory(
        name: 'Text Inputs',
        icon: Icons.text_fields,
        items: [
          ToolboxItem(
            name: 'text_field',
            icon: Icons.short_text,
            label: 'Text Field',
            defaultWidth: 2,
            defaultHeight: 1,
            gridBuilder: (context, placement) => _buildTextField(placement),
          ),
          ToolboxItem(
            name: 'text_area',
            icon: Icons.notes,
            label: 'Text Area',
            defaultWidth: 3,
            defaultHeight: 2,
            gridBuilder: (context, placement) => _buildTextArea(placement),
          ),
        ],
      ),
      ToolboxCategory(
        name: 'Actions',
        icon: Icons.touch_app,
        items: [
          ToolboxItem(
            name: 'button',
            icon: Icons.smart_button,
            label: 'Button',
            defaultWidth: 1,
            defaultHeight: 1,
            gridBuilder: (context, placement) => _buildButton(placement),
          ),
        ],
      ),
    ],
  );
}
```

## Step 4: Create Widget Builders

Define how each widget type should be rendered:

```dart
Widget _buildTextField(WidgetPlacement placement) {
  return Padding(
    padding: EdgeInsets.all(8.0),
    child: TextFormField(
      key: ValueKey(placement.id),
      decoration: InputDecoration(
        labelText: placement.properties['label'] ?? 'Text Field',
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    ),
  );
}

Widget _buildTextArea(WidgetPlacement placement) {
  return Padding(
    padding: EdgeInsets.all(8.0),
    child: TextFormField(
      key: ValueKey(placement.id),
      maxLines: 4,
      decoration: InputDecoration(
        labelText: placement.properties['label'] ?? 'Message',
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    ),
  );
}

Widget _buildButton(WidgetPlacement placement) {
  return Padding(
    padding: EdgeInsets.all(8.0),
    child: ElevatedButton(
      key: ValueKey(placement.id),
      onPressed: () {
        print('Button clicked: ${placement.id}');
      },
      style: ElevatedButton.styleFrom(
        minimumSize: Size.expand,
      ),
      child: Text(
        placement.properties['label'] ?? 'Submit',
        style: TextStyle(fontSize: 16),
      ),
    ),
  );
}
```

## Step 5: Add Persistence

Save the form layout when it changes:

```dart
class _ContactFormBuilderState extends State<ContactFormBuilder> {
  LayoutState? _savedLayout;

  @override
  void initState() {
    super.initState();
    _loadSavedLayout();
  }

  Future<void> _loadSavedLayout() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('contact_form_layout');
    
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString);
        setState(() {
          _savedLayout = LayoutState.fromJson(json);
        });
      } catch (e) {
        print('Failed to load layout: $e');
      }
    }
  }

  Future<void> _saveLayout(LayoutState layout) async {
    final prefs = await SharedPreferences.getInstance();
    final json = layout.toJson();
    await prefs.setString('contact_form_layout', jsonEncode(json));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Form Builder'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _savedLayout = null;
              });
            },
            tooltip: 'Reset Form',
          ),
        ],
      ),
      body: FormLayout(
        toolbox: _createToolbox(),
        initialLayout: _savedLayout,
        onLayoutChanged: (layout) {
          _saveLayout(layout);
        },
      ),
    );
  }
}
```

## Step 6: Try It Out

1. Run your app
2. Drag widgets from the toolbox to the grid
3. Arrange them to create your contact form
4. The layout automatically saves as you make changes
5. Restart the app to see your saved layout restored

## Next Steps

- [Add custom properties](02-adding-custom-widgets.md) to your widgets
- [Implement validation](04-implementing-validation.md) for form fields
- [Create a form renderer](09-form-submission.md) to display the final form

## Complete Example

Find the complete example in our [GitHub repository](https://github.com/yourusername/formbuilder/tree/main/examples/contact_form).

## Tips

- Start with a 4x4 grid for simple forms
- Use consistent widget sizes for better alignment
- Test your form on different screen sizes
- Save layouts frequently during development