import 'package:flutter/material.dart';
import 'package:expense_tracker/stores/expense_store.dart';
import 'package:expense_tracker/stores/auth_store.dart';
import 'package:expense_tracker/utils/responsive_utils.dart';
import 'package:expense_tracker/stores/settings_store.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Currency is persisted in SettingsStore
  bool darkMode = false;
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final isMobile = ResponsiveUtils.isMobile(context);
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final userName = authStore.currentName ?? 'User';
    final userEmail = authStore.currentEmail ?? 'Not logged in';

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            Container(
              padding: EdgeInsets.all(padding),
              color: primary.withOpacity(0.1),
              child: Column(
                children: [
                  if (!isMobile) const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: isMobile ? 32 : 40,
                              backgroundColor: primary.withOpacity(0.2),
                              child: Text(
                                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userEmail,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: isMobile ? 12 : 14,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showLogoutDialog(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.logout, color: Colors.red, size: 18),
                              const SizedBox(width: 6),
                              Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: isMobile ? 10 : 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!isMobile) const SizedBox(height: 16),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // App Settings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('App Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 12),
                  
                  // Currency
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Currency', style: TextStyle(fontWeight: FontWeight.w600)),
                            SizedBox(height: 4),
                            Text('Choose display currency', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        AnimatedBuilder(
                          animation: settingsStore,
                          builder: (context, _) {
                            return DropdownButton<String>(
                              value: settingsStore.currencyCode,
                              items: const [
                                DropdownMenuItem(value: 'INR', child: Text('₹ INR')),
                                DropdownMenuItem(value: 'USD', child: Text('\u0024 USD')),
                                DropdownMenuItem(value: 'EUR', child: Text('€ EUR')),
                                DropdownMenuItem(value: 'GBP', child: Text('£ GBP')),
                                DropdownMenuItem(value: 'JPY', child: Text('¥ JPY')),
                                DropdownMenuItem(value: 'RUB', child: Text('₽ RUB')),
                                DropdownMenuItem(value: 'MZN', child: Text('MZN')),
                                DropdownMenuItem(value: 'ZAR', child: Text('R ZAR')),
                              ],
                              onChanged: (code) async {
                                if (code == null) return;
                                await settingsStore.setCurrency(code);
                                // Notify the app to rebuild where necessary
                                setState(() {});
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Dark Mode
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                            SizedBox(height: 4),
                            Text('Coming soon', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        Switch(
                          value: darkMode,
                          onChanged: (val) => setState(() => darkMode = val),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Notifications
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Notifications ', style: TextStyle(fontWeight: FontWeight.w600)),
                            SizedBox(height: 4),
                            Text('Coming soon', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        Switch(
                          value: notificationsEnabled,
                          onChanged: (val) => setState(() => notificationsEnabled = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Data Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Data Management', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 12),

                  // Export Data
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Export Data', style: TextStyle(fontWeight: FontWeight.w600)),
                            SizedBox(height: 4),
                            Text('Coming soon', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        Icon(Icons.download, color: primary),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Clear Data
                  GestureDetector(
                    onTap: () => _showClearDataDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Clear All Data', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                              SizedBox(height: 4),
                              Text('Delete all expenses (cannot be undone)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          const Icon(Icons.delete, color: Colors.red),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // About Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('App Version', style: TextStyle(fontWeight: FontWeight.w600)),
                            Text('1.0.1', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Developer', style: TextStyle(fontWeight: FontWeight.w600)),
                            Text('Amir Omar', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This action cannot be undone. All your expenses will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              expenseStore.clearAll();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('You will be logged out of your account and returned to the login screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await authStore.logout();
              if (context.mounted) {
                Navigator.pop(ctx);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (_) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
