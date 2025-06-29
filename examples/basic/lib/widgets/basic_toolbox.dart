import 'package:flutter/material.dart';
import 'package:formbuilder/form_layout/models/toolbox.dart';
import 'package:formbuilder/form_layout/models/toolbox_item.dart';
import 'contact_fields.dart';

CategorizedToolbox createBasicToolbox() {
  return CategorizedToolbox(
    categories: [
      ToolboxCategory(
        name: 'Text Fields',
        items: [
          ToolboxItem(
            name: 'name_field',
            displayName: 'Name Field',
            toolboxBuilder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(height: 4),
                const Text('Name', style: TextStyle(fontSize: 12)),
              ],
            ),
            gridBuilder: (context, placement) => NameField(placement: placement),
            defaultWidth: 2,
            defaultHeight: 1,
          ),
          ToolboxItem(
            name: 'email_field',
            displayName: 'Email Field',
            toolboxBuilder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.email, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(height: 4),
                const Text('Email', style: TextStyle(fontSize: 12)),
              ],
            ),
            gridBuilder: (context, placement) => EmailField(placement: placement),
            defaultWidth: 2,
            defaultHeight: 1,
          ),
          ToolboxItem(
            name: 'message_field',
            displayName: 'Message Field',
            toolboxBuilder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.message, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(height: 4),
                const Text('Message', style: TextStyle(fontSize: 12)),
              ],
            ),
            gridBuilder: (context, placement) => MessageField(placement: placement),
            defaultWidth: 3,
            defaultHeight: 2,
          ),
        ],
      ),
      ToolboxCategory(
        name: 'Buttons',
        items: [
          ToolboxItem(
            name: 'submit_button',
            displayName: 'Submit Button',
            toolboxBuilder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.send, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(height: 4),
                const Text('Submit', style: TextStyle(fontSize: 12)),
              ],
            ),
            gridBuilder: (context, placement) => SubmitButton(placement: placement),
            defaultWidth: 1,
            defaultHeight: 1,
          ),
          ToolboxItem(
            name: 'cancel_button',
            displayName: 'Cancel Button',
            toolboxBuilder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cancel, size: 24, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 4),
                const Text('Cancel', style: TextStyle(fontSize: 12)),
              ],
            ),
            gridBuilder: (context, placement) => CancelButton(placement: placement),
            defaultWidth: 1,
            defaultHeight: 1,
          ),
        ],
      ),
      ToolboxCategory(
        name: 'Options',
        items: [
          ToolboxItem(
            name: 'newsletter_checkbox',
            displayName: 'Newsletter Checkbox',
            toolboxBuilder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mail_outline, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(height: 4),
                const Text('Newsletter', style: TextStyle(fontSize: 12)),
              ],
            ),
            gridBuilder: (context, placement) => NewsletterCheckbox(placement: placement),
            defaultWidth: 2,
            defaultHeight: 1,
          ),
          ToolboxItem(
            name: 'terms_checkbox',
            displayName: 'Terms Checkbox',
            toolboxBuilder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.gavel, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(height: 4),
                const Text('Terms', style: TextStyle(fontSize: 12)),
              ],
            ),
            gridBuilder: (context, placement) => TermsCheckbox(placement: placement),
            defaultWidth: 3,
            defaultHeight: 1,
          ),
        ],
      ),
    ],
  );
}