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
  String _iconKey = 'restaurant';
  Color _color = AppColors.teal;
  bool _busy = false;

  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? img = await _picker.pickImage(source: source, maxWidth: 800);
      if (img != null) setState(() => _imagePath = img.path);
    } catch (_) {}
  }

  Future<void> _save() async {
    final label = _label.text.trim();
    if (label.isEmpty) return;

    setState(() => _busy = true);
    await Future.delayed(const Duration(milliseconds: 600));

    await appState.addCard(CommCard(
      id: newId(),
      label: label,
      iconKey: _iconKey,
      color: _color,
      imagePath: _imagePath,
      category: _category,
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card saved successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF191C1D)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Create Card', style: TextStyle(color: Color(0xFF006A63), fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Live Preview
                const Text('PREVIEW', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Color(0xFF6D7A77))),
                const SizedBox(height: 16),
                _PreviewCard(
                  label: _label.text,
                  imagePath: _imagePath,
                  iconKey: _iconKey,
                  color: _color,
                ),
                const SizedBox(height: 48),

                // Label Input
                _EditorField(
                  label: 'Label Text',
                  child: TextFormField(
                    controller: _label,
                    onChanged: (v) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'e.g., Apple, Park, Sleep',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Card Image Selection
                _EditorField(
                  label: 'Card Image',
                  child: Row(
                    children: [
                      Expanded(
                        child: _UploadButton(
                          onTap: () => _pickImage(ImageSource.gallery),
                          icon: Icons.add_a_photo,
                          label: 'Upload Photo',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _IconButton(
                          onTap: () => setState(() => _imagePath = null),
                          active: _imagePath == null,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Icon Selector Grid
                if (_imagePath == null) ...[
                  _EditorField(
                    label: 'Select Icon',
                    child: Container(
                      height: 200,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFF2F4F4), borderRadius: BorderRadius.circular(20)),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                        itemCount: SeedData.editorIconChoices.length,
                        itemBuilder: (context, index) {
                          final key = SeedData.editorIconChoices[index];
                          final isSelected = key == _iconKey;
                          return GestureDetector(
                            onTap: () => setState(() => _iconKey = key),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF4DB6AC) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(IconCatalog.lookup(key), color: isSelected ? Colors.white : const Color(0xFF006A63)),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 120), // Bottom nav space
              ],
            ),
          ),

          // Fixed Save Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -8)),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: _busy ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006A63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    elevation: 0,
                  ),
                  child: _busy
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save),
                          SizedBox(width: 12),
                          Text('Save Communication Card', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final String label;
  final String? imagePath;
  final String iconKey;
  final Color color;

  const _PreviewCard({required this.label, this.imagePath, required this.iconKey, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF84D7FD).withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 12), spreadRadius: -8),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(File(imagePath!), width: 96, height: 96, fit: BoxFit.cover),
            )
          else
            Icon(IconCatalog.lookup(iconKey), size: 64, color: const Color(0xFF006A63)),
          const SizedBox(height: 16),
          Text(
            label.isEmpty ? 'Snack' : label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF005D79)),
          ),
        ],
      ),
    );
  }
}

class _EditorField extends StatelessWidget {
  final String label;
  final Widget child;
  const _EditorField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF3D4947))),
        ),
        child,
      ],
    );
  }
}

class _UploadButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  const _UploadButton({required this.onTap, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFBDC9C6), style: BorderStyle.solid, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF6D7A77)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF6D7A77), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool active;
  const _IconButton({required this.onTap, required this.active});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF4DB6AC).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? const Color(0xFF006A63) : const Color(0xFFBDC9C6), width: 2),
        ),
        child: Column(
          children: [
            Icon(Icons.grid_view, color: active ? const Color(0xFF006A63) : const Color(0xFF6D7A77)),
            const SizedBox(height: 8),
            Text('Use Icon', style: TextStyle(fontSize: 14, color: active ? const Color(0xFF006A63) : const Color(0xFF6D7A77), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
