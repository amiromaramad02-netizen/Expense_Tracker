import 'package:flutter/material.dart';
// Removed google_fonts to avoid runtime font downloads on platforms
// which may disallow network access. Falling back to default text theme.
import 'pages/home_page.dart';
import 'pages/categories_page.dart';
import 'pages/progress_page.dart';
import 'pages/settings_page.dart';
import 'pages/add_expense_page.dart';
import 'pages/login_page.dart';
import 'stores/auth_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  authStore.initialized; // Wait for auth state to load
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatefulWidget {
  const ExpenseTrackerApp({super.key});

  @override
  State<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  late final VoidCallback _authListener;

  @override
  void initState() {
    super.initState();
    // Listen to auth state changes and rebuild when auth state changes
    _authListener = () => setState(() {});
    authStore.addListener(_authListener);
  }

  @override
  void dispose() {
    authStore.removeListener(_authListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color.fromARGB(255, 77, 130, 255);       // vivid purple
    const primaryLight = Color.fromARGB(255, 231, 231, 235);  // very pale lilac bg
    final colorScheme = ColorScheme.fromSeed(seedColor: primary);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ExpenseLit',
      theme: ThemeData(
        colorScheme: colorScheme,
        primaryColor: const Color.fromARGB(255, 17, 31, 110),
        scaffoldBackgroundColor: const Color.fromARGB(255, 223, 223, 223),
        useMaterial3: true,
        // Use the default text theme to avoid network font fetches
        textTheme: Theme.of(context).textTheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: false,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 42, 13, 121),
          elevation: 8,
        ),
      ),
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (authStore.isAuthenticated) {
      return const _AuthenticatedGate(child: HomeShell());
    } else {
      return const LoginPage();
    }
  }
}

/// Wrapper that applies entrance animation when user authenticates
class _AuthenticatedGate extends StatefulWidget {
  final Widget child;
  const _AuthenticatedGate({required this.child});

  @override
  State<_AuthenticatedGate> createState() => _AuthenticatedGateState();
}

class _AuthenticatedGateState extends State<_AuthenticatedGate>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: widget.child,
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  static final _pages = [
    const HomePage(),
    const CategoriesPage(),
    const ProgressPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      // Use centered floating FAB (not docked) to avoid BottomAppBar notch clipping issues on desktop
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // Show the global FAB only when on the Home page. Other pages either
      // hide it or provide their own contextual add buttons (e.g., Progress).
      floatingActionButton: _index == 0
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'add_income',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpensePage(isIncome: true))),
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.attach_money, size: 22),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  heroTag: 'add_expense',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpensePage(isIncome: false))),
                  child: const Icon(Icons.add, size: 22),
                ),
              ],
            )
          : null,
      bottomNavigationBar: BottomAppBar(
        // No notch shape to avoid geometry access during hit testing on desktop
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                _NavButton(icon: Icons.home, label: 'Home', active: _index == 0, onTap: () => setState(() => _index = 0)),
                _NavButton(icon: Icons.category, label: 'Categories', active: _index == 1, onTap: () => setState(() => _index = 1)),
              ]),
              Row(children: [
                _NavButton(icon: Icons.show_chart, label: 'Progress', active: _index == 2, onTap: () => setState(() => _index = 2)),
                _NavButton(icon: Icons.settings, label: 'Settings', active: _index == 3, onTap: () => setState(() => _index = 3)),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.label, required this.active, required this.onTap});
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? Theme.of(context).primaryColor : Colors.grey.shade600;
    return MaterialButton(
      minWidth: 72,
      onPressed: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
