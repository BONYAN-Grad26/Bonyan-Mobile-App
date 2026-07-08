import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../pages/meals_tab.dart';
import '../pages/profile_page.dart';
import '../pages/settings_page.dart';
import '../pages/workouts_tab.dart';
import '../tabs/home_tab.dart';
import '../../../chatbot/presentation/pages/chat_page.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;
  int _lastMainPageIndex = 0; // Tracks the last visited main tab (Dashboard, Meals, or Workouts)
  bool _isVisible = true;
  late final PageController _pageController;

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _tabs = [
      HomeTab(
        onNavigate: (index) {
          _animateToPage(index);
        },
        onJump: (index) {
          _jumpToPage(index);
        },
      ),
      const MealsTab(),
      const WorkoutsTab(),
      ProfilePage(
        onBack: () {
          _jumpToPage(_lastMainPageIndex); // Return to last main page instantly
        },
        onNavigateToSettings: () {
          _animateToPage(4); // Go to Settings
        },
      ),
      SettingsPage(
        onBack: () {
          _animateToPage(3); // Go back to Profile
        },
      ),
      ChatPage(
        onBack: () {
          _animateToPage(_lastMainPageIndex); // Return to last main page with animation
        },
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateToPage(int index) {
    if (_currentIndex == index) return;
    
    // Update last main page index if we are navigating to Dashboard, Meals, or Workouts
    if (index >= 0 && index <= 2) {
      _lastMainPageIndex = index;
    }
    
    setState(() {
      _currentIndex = index;
      _isVisible = true;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _jumpToPage(int index) {
    if (_currentIndex == index) return;
    
    // Update last main page index if we are navigating to Dashboard, Meals, or Workouts
    if (index >= 0 && index <= 2) {
      _lastMainPageIndex = index;
    }

    setState(() {
      _currentIndex = index;
      _isVisible = true;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navBarBgColor = const Color(0xFF268FB1); // Dimmed Ocean Blue for both themes
    final navBarIconColor = Colors.white;

    return Scaffold(
      extendBody: true,
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.reverse) {
            if (_isVisible) setState(() => _isVisible = false);
          } else if (notification.direction == ScrollDirection.forward) {
            if (!_isVisible) setState(() => _isVisible = true);
          }
          return true;
        },
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // Disable swipe to avoid accidental page switches
          children: _tabs,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: (_isVisible && _currentIndex <= 2) ? Offset.zero : const Offset(0, 2),
        child: Container(
          margin: const EdgeInsets.fromLTRB(15.5, 0, 15.5, 24), // Adjusted margin to increase width by 9px total
          height: 70,
          decoration: BoxDecoration(
            color: navBarBgColor,
            borderRadius: BorderRadius.circular(35),
            border: isDark ? Border.all(color: colorScheme.outline, width: 1) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                indicatorColor: Colors.transparent,
                labelPadding: const EdgeInsets.only(top: 0),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final isSelected = states.contains(WidgetState.selected);
                  return TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? navBarIconColor
                        : navBarIconColor.withValues(alpha: 0.5),
                  );
                }),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  final isSelected = states.contains(WidgetState.selected);
                  return IconThemeData(
                    size: 24,
                    color: isSelected
                        ? navBarIconColor
                        : navBarIconColor.withValues(alpha: 0.5),
                  );
                }),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    padding: EdgeInsets.zero,
                    viewPadding: EdgeInsets.zero,
                  ),
                  child: NavigationBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    height: 70,
                    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                    selectedIndex: _currentIndex > 2 ? (_currentIndex == 5 ? 3 : 0) : _currentIndex,
                    onDestinationSelected: (index) {
                      if (index == 3) {
                        _animateToPage(5); // AI Chat Page
                      } else {
                        _animateToPage(index);
                      }
                    },
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.dashboard_outlined),
                        selectedIcon: Icon(Icons.dashboard_rounded),
                        label: 'Dashboard',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.restaurant_menu_outlined),
                        selectedIcon: Icon(Icons.restaurant_menu_rounded),
                        label: 'Meals',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.fitness_center_outlined),
                        selectedIcon: Icon(Icons.fitness_center_rounded),
                        label: 'Workouts',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.chat_bubble_outline),
                        selectedIcon: Icon(Icons.chat_bubble),
                        label: 'AI Chat',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
