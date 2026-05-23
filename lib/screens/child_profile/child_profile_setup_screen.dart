import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/ids.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/primary_button.dart';
import 'link_code_share_screen.dart';

/// First-run (or "add another child") screen for the parent. Captures the
/// minimum we need to personalise the child's app: name, year of birth,
/// optional avatar.
class ChildProfileSetupScreen extends StatefulWidget {
  /// When true, the screen replaces itself with the link-code share screen
  /// on save (first-run flow). When false, it just pops back to the caller
  /// (e.g. Children tab adding a sibling).
  final bool showLinkCodeOnSave;

  const ChildProfileSetupScreen({super.key, this.showLinkCodeOnSave = true});

  @override
  State<ChildProfileSetupScreen> createState() =>
      _ChildProfileSetupScreenState();
}

class _ChildProfileSetupScreenState extends State<ChildProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _birthYear = TextEditingController();
  String? _avatarPath;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _name.dispose();
    _birthYear.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final img = await _picker.pickImage(
          source: ImageSource.gallery, maxWidth: 600);
      if (img != null) setState(() => _avatarPath = img.path);
    } catch (_) {/* swallow — gallery isn't available on every emulator */}
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final child = ChildProfile(
      id: newId(),
      name: _name.text.trim(),
      birthYear: int.tryParse(_birthYear.text.trim()),
      avatarPath: _avatarPath,
    );
    appState.addChildProfile(child);

    if (!mounted) return;
    if (widget.showLinkCodeOnSave) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LinkCodeShareScreen(child: child, isFirstSetup: true),
        ),
      );
    } else {
      Navigator.pop(context, child);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tealBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.tealDark,
        elevation: 0,
        title: const Text('About your child'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              const Text(
                "We'll personalise the app for your child. You can change "
                "any of this later in the Parent area.",
                style: TextStyle(color: AppColors.muted, height: 1.5),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: AppColors.tealLight,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _avatarPath != null
                        ? Image.file(File(_avatarPath!), fit: BoxFit.cover)
                        : const Icon(Icons.add_a_photo_outlined,
                            size: 44, color: AppColors.tealDark),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text("Tap to add a photo (optional)",
                    style: TextStyle(fontSize: 12, color: AppColors.muted)),
              ),
              const SizedBox(height: 24),
              AuthTextField(
                controller: _name,
                label: "Child's name",
                icon: Icons.child_care,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter a name'
                    : null,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _birthYear,
                label: "Year of birth (optional)",
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final n = int.tryParse(v.trim());
                  final year = DateTime.now().year;
                  if (n == null || n < year - 25 || n > year) {
                    return 'Please check the year';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              PrimaryButton(label: 'Save', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
