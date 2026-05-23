import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final sensory = appState.sensoryMode;
        final header = calmIf(sensory, AppColors.blue);
        final nowIndex = appState.nowIndex;
        final topInset = MediaQuery.of(context).padding.top;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(16, topInset + 14, 16, 16),
                decoration: BoxDecoration(
                  color: header,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('My day',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600)),
                        Text(
                            '${appState.scheduleDone} of ${appState.schedule.length} done',
                            style: const TextStyle(
                                color: Color(0xFFB5D4F4), fontSize: 12)),
                      ],
                    ),
                    const Icon(Icons.wb_sunny, color: Colors.white),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: appState.schedule.length,
                  itemBuilder: (_, i) {
                    final item = appState.schedule[i];
                    final isNow = i == nowIndex;
                    final accent = calmIf(sensory, AppColors.blue);

                    Color bg;
                    Border? border;
                    double opacity = 1;
                    if (item.done) {
                      bg = AppColors.tealLight;
                    } else if (isNow) {
                      bg = Colors.white;
                      border = Border.all(color: accent, width: 2);
                    } else {
                      bg = Colors.white;
                      border = Border.all(color: AppColors.line);
                      opacity = 0.7;
                    }

                    return Opacity(
                      opacity: opacity,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(16),
                          border: border,
                        ),
                        child: ListTile(
                          onTap: () => appState.toggleScheduleDone(item),
                          leading: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: item.done
                                  ? AppColors.tealMid
                                  : (isNow
                                      ? accent.withOpacity(0.2)
                                      : AppColors.tealBg),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(item.icon,
                                color: item.done
                                    ? const Color(0xFF04342C)
                                    : accent),
                          ),
                          title: Text(item.label,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink)),
                          subtitle: isNow
                              ? Text('now',
                                  style: TextStyle(color: accent, fontSize: 12))
                              : null,
                          trailing: Icon(
                            item.done
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: item.done ? AppColors.green : AppColors.line,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
