import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../providers/notification_provider.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_settings_screen.dart';
import '../support/support_home_screen.dart';
import '../transactions/transaction_history_screen.dart';
import 'home_screen.dart';

/// The five-tab shell behind the bottom navigation bar in the designs:
/// Home · Activity · Support · Inbox · More.
///
/// SRP: this widget owns tab selection only. Each tab is an independent
/// screen that knows nothing about the shell, so any tab can also be pushed
/// as a full route.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _tabs = <Widget>[
    HomeScreen(),
    TransactionHistoryScreen(embedded: true),
    SupportHomeScreen(embedded: true),
    NotificationsScreen(embedded: true),
    ProfileSettingsScreen(embedded: true),
  ];

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<NotificationProvider>().unreadCount;

    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurface
              : AppColors.white,
          indicatorColor: AppColors.primary,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: states.contains(WidgetState.selected)
                  ? AppColors.navy
                  : AppColors.textSecondary,
            ),
          ),
        ),
        child: NavigationBar(
          height: 68,
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home'),
            const NavigationDestination(
                icon: Icon(Icons.swap_horiz), label: 'Activity'),
            const NavigationDestination(
                icon: Icon(Icons.headset_mic_outlined), label: 'Support'),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: unread > 0,
                label: Text('$unread'),
                child: const Icon(Icons.notifications_none),
              ),
              label: 'Inbox',
            ),
            const NavigationDestination(
                icon: Icon(Icons.grid_view_rounded), label: 'More'),
          ],
        ),
      ),
    );
  }
}
