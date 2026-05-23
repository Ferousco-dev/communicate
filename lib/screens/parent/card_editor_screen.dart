import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/icon_catalog.dart';
import '../../data/ids.dart';
import '../../data/seed_data.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class CardEditorScreen extends StatefulWidget {
  const CardEditorScreen({super.key});

  @override
  State<CardEditorScreen> createState() => _CardEditorScreenState();
}

class _CardEditorScreenState extends State<CardEditorScreen> {
  final _label = TextEditingController();
  String _category = 'Wants';
  String? _imagePath;
  String _iconKey = 'star';
  Color _color = AppColors.teal;

  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? img = await _picker.pickImage(source: source, maxWidth: 800);
      if (img != null) setState(() => _imagePath = img.path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not open the camera/gallery on this device.')),
        );
      }
    }
  }

  Future<void> _save() async {
    final label = _label.text.trim();
    if (label.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a word for the card.')),
      );
      return;
    }
    await appState.addCard(CommCard(
      id: newId(),
      label: label,
      iconKey: _iconKey,
      color: _color,
      imagePath: _imagePath,
      category: _category,
    ));
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.tealDark,
        foregroundColor: Colors.white,
        title: const Text('New card'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _color.withValues(alpha: 0.5), width: 1.5),
              ),
              child: _imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(File(_imagePath!), fit: BoxFit.cover),
                    )
                  : Icon(IconCatalog.lookup(_iconKey), size: 64, color: _color),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Camera'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_outlined),
                label: const Text('Gallery'),
              ),
            ],
          ),
          if (_imagePath != null)
            Center(
              child: TextButton(
                onPressed: () => setState(() => _imagePath = null),
                child: const Text('Use an icon instead'),
              ),
            ),
          const SizedBox(height: 16),
          TextField(
            controller: _label,
            decoration: InputDecoration(
              labelText: 'Word / label',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            items: appState.categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _category = v ?? 'Wants'),
          ),
          const SizedBox(height: 16),
          if (_imagePath == null) ...[
            const Text('Pick an icon', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SeedData.editorIconChoices.map((key) {
                final selected = key == _iconKey;
                return GestureDetector(
                  onTap: () => setState(() => _iconKey = key),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.tealLight : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: selected ? AppColors.teal : AppColors.line,
                          width: selected ? 2 : 1),
                    ),
                    child: Icon(IconCatalog.lookup(key), color: _color),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Pick a colour', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: SeedData.editorColorChoices.map((col) {
                final selected = col == _color;
                return GestureDetector(
                  onTap: () => setState(() => _color = col),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: col,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: selected ? AppColors.ink : Colors.transparent, width: 2),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _save,
              child: const Text('Save card', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
