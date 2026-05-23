import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'tabs/cards_tab.dart';
import 'tabs/children_tab.dart';
import 'tabs/progress_tab.dart';
import 'tabs/settings_tab.dart';

/// Parent dashboard shell — just the AppBar + tab routing. Each tab lives in
/// its own file under `tabs/` so this stays readable as the app grows.
class ParentArea extends StatelessWidget {
  const ParentArea({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.tealDark,
          foregroundColor: Colors.white,
          title: const Text('Parent dashboard'),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.tealMid,
            labelColor: Colors.white,
            unselectedLabelColor: Color(0xFF9FE1CB),
            tabs: [
              Tab(text: 'Progress'),
              Tab(text: 'Children'),
              Tab(text: 'Cards'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ProgressTab(),
            ChildrenTab(),
            CardsTab(),
            SettingsTab(),
          ],
        ),
      ),
    );
  }
}
