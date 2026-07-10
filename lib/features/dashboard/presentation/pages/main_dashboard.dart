import 'dart:ui';
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
  bool _shouldAnimate = true;
  bool _isReverse = false;

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
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
      const SizedBox.shrink(),
      ProfilePage(
        onBack: () {
          _jumpToPage(_lastMainPageIndex); // Return to last main page instantly
        },
        onNavigateToSettings: () {
          _animateToPage(5); // Go to Settings
        },
      ),
      SettingsPage(
        onBack: () {
          _animateToPage(4); // Go back to Profile
        },
      ),
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _animateToPage(int index) {
    if (index == 3) {
      _pushChatPage();
      return;
    }
    if (_currentIndex == index) return;
    
    // Update last main page index if we are navigating to Dashboard, Meals, or Workouts
    if (index >= 0 && index <= 2) {
      _lastMainPageIndex = index;
    }
    
    setState(() {
      _isReverse = index < _currentIndex;
      _shouldAnimate = true;
      _currentIndex = index;
      _isVisible = true;
    });
  }

  void _jumpToPage(int index) {
    if (index == 3) {
      _pushChatPage();
      return;
    }
    if (_currentIndex == index) return;
    
    // Update last main page index if we are navigating to Dashboard, Meals, or Workouts
    if (index >= 0 && index <= 2) {
      _lastMainPageIndex = index;
    }

    setState(() {
      _isReverse = index < _currentIndex;
      _shouldAnimate = false;
      _currentIndex = index;
      _isVisible = true;
    });
  }

  void _pushChatPage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ChatPage(
          onBack: () => Navigator.pop(context),
        ),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBarBgColor = const Color(0xFF268FB1); // Dimmed Ocean Blue

    return Scaffold(
      extendBody: true,
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          // Only respond to vertical scroll notifications
          if (notification.metrics.axis != Axis.vertical) return false;

          if (notification.direction == ScrollDirection.reverse) {
            if (_isVisible) setState(() => _isVisible = false);
          } else if (notification.direction == ScrollDirection.forward) {
            if (!_isVisible) setState(() => _isVisible = true);
          }
          return true;
        },
        child: AnimatedSwitcher(
          duration: _shouldAnimate ? const Duration(milliseconds: 300) : Duration.zero,
          transitionBuilder: (Widget child, Animation<double> animation) {
            if (!_shouldAnimate) return child;

            final isIncoming = child.key == ValueKey<int>(_currentIndex);
            final Offset begin = _isReverse
                ? (isIncoming ? const Offset(-1.0, 0.0) : const Offset(1.0, 0.0))
                : (isIncoming ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0));

            return SlideTransition(
              position: animation.drive(
                Tween<Offset>(begin: begin, end: Offset.zero).chain(
                  CurveTween(curve: Curves.easeInOutCubic),
                ),
              ),
              child: child,
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(_currentIndex),
            child: _tabs[_currentIndex],
          ),
        ),
      ),
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: (_isVisible && (_currentIndex <= 2 || _currentIndex == 4)) ? Offset.zero : const Offset(0, 2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.fromLTRB(25, 0, 25, 24),
          height: 72, // Increased from 62 to make it more visible
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      navBarBgColor.withValues(alpha: 0.80),
                      navBarBgColor.withValues(alpha: 0.95),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(
                    color: isDark 
                        ? colorScheme.outline.withValues(alpha: 0.3) 
                        : const Color(0xFF1B242C).withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildNavItem(
                      index: 0,
                      icon: Icons.dashboard_outlined,
                      selectedIcon: Icons.dashboard_rounded,
                      label: 'Dashboard',
                    ),
                    _buildNavItem(
                      index: 1,
                      icon: Icons.restaurant_menu_outlined,
                      selectedIcon: Icons.restaurant_menu_rounded,
                      label: 'Meals',
                    ),
                    _buildNavItem(
                      index: 2,
                      icon: Icons.fitness_center_outlined,
                      selectedIcon: Icons.fitness_center_rounded,
                      label: 'Workouts',
                    ),
                    _buildNavItem(
                      index: 4,
                      icon: Icons.person_outline_rounded,
                      selectedIcon: Icons.person_rounded,
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    bool badge = false,
  }) {
    final isSelected = (_currentIndex == 5 ? 4 : _currentIndex) == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _animateToPage(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 72,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(36),
            border: isSelected 
                ? Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Badge(
                isLabelVisible: badge,
                smallSize: 9,
                backgroundColor: const Color(0xFFF09033),
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                  size: 26, // Increased from 24
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
