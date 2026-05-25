import 'package:flutter/material.dart';

import '../../data/ids.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import 'link_code_share_screen.dart';

class ChildProfileSetupScreen extends StatefulWidget {
  final bool showLinkCodeOnSave;

  const ChildProfileSetupScreen({super.key, this.showLinkCodeOnSave = true});

  @override
  State<ChildProfileSetupScreen> createState() => _ChildProfileSetupScreenState();
}

class _ChildProfileSetupScreenState extends State<ChildProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();

  IconData _selectedAvatar = Icons.face;
  String _selectedAgeRange = '3 - 5';

  final List<IconData> _avatars = [
    Icons.face,
    Icons.cruelty_free,
    Icons.rocket_launch,
    Icons.toys,
    Icons.palette,
    Icons.pets,
    Icons.celebration,
    Icons.star,
    Icons.smart_toy,
    Icons.auto_awesome,
    Icons.music_note,
    Icons.sunny,
  ];

  final List<String> _ageRanges = [
    'Under 3',
    '3 - 5',
    '6 - 8',
    '9 - 12',
    '13+',
  ];

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // Map age range to a rough birth year to stay compatible with existing model
    int currentYear = DateTime.now().year;
    int birthYear = currentYear - 4; // Default to middle of 3-5
    if (_selectedAgeRange == 'Under 3') birthYear = currentYear - 2;
    if (_selectedAgeRange == '6 - 8') birthYear = currentYear - 7;
    if (_selectedAgeRange == '9 - 12') birthYear = currentYear - 10;
    if (_selectedAgeRange == '13+') birthYear = currentYear - 14;

    final child = ChildProfile(
      id: newId(),
      name: _name.text.trim(),
      birthYear: birthYear,
      // In a real app, we'd store the icon key. For now, we use a placeholder logic.
      avatarPath: 'icon:${_selectedAvatar.codePoint}',
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
      backgroundColor: const Color(0xFFF8FAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF006A63)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'New Profile',
          style: TextStyle(color: Color(0xFF006A63), fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: const Color(0xFFBEE9FF).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 24),
                  // Avatar Preview
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: Color(0xFF84D7FD),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                            ],
                          ),
                          child: Icon(_selectedAvatar, size: 50, color: const Color(0xFF005D79)),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Let's set up a space for your child to\ncommunicate and grow.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Color(0xFF3D4947)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Name Input
                  const Text('Child\'s Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF191C1D))),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _name,
                    decoration: InputDecoration(
                      hintText: 'What is their name?',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Enter a name' : null,
                  ),
                  const SizedBox(height: 32),

                  // Avatar Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Choose an Avatar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      Text('${_avatars.length} options', style: const TextStyle(fontSize: 12, color: Color(0xFF6D7A77))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemCount: _avatars.length,
                      itemBuilder: (context, index) {
                        final icon = _avatars[index];
                        final isSelected = icon == _selectedAvatar;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedAvatar = icon),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF8EF4E9) : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? const Color(0xFF006A63) : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Icon(icon, color: isSelected ? const Color(0xFF006A63) : const Color(0xFF3D4947)),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Age Selection
                  const Text('Child\'s Age (Optional)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _ageRanges.map((age) {
                        final isSelected = age == _selectedAgeRange;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ChoiceChip(
                            label: Text(age),
                            selected: isSelected,
                            onSelected: (s) => setState(() => _selectedAgeRange = age),
                            selectedColor: const Color(0xFF4DB6AC),
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF3D4947),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            side: BorderSide(color: isSelected ? const Color(0xFF006A63) : const Color(0xFFBDC9C6)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF71D7CD).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info, color: Color(0xFF006A63), size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This information helps us tailor the communication tiles and vocabulary complexity to your child\'s developmental stage.',
                            style: TextStyle(fontSize: 14, color: Color(0xFF00504A)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Space for fixed footer
                ],
              ),
            ),
          ),

          // Fixed Footer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -8)),
                ],
              ],
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006A63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Create Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.chevron_right),
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
