import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';

/// Menu widget for app navigation
class MenuWidget extends StatelessWidget {
  const MenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Menu', style: Theme.of(context).textTheme.headlineLarge),

          const SizedBox(height: 32),

          // Menu items
          _buildMenuItem(
            context,
            icon: Icons.explore,
            title: 'Explore Characters',
            subtitle: 'Search and explore Chinese characters',
            onTap: () {
              context.read<AppStateProvider>().switchToState(AppState.main);
            },
          ),

          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            title: 'FAQ',
            subtitle: 'Frequently asked questions',
            onTap: () {
              context.read<AppStateProvider>().switchToState(AppState.faq);
            },
          ),

          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'About HanziGraph',
            onTap: () {
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('About HanziGraph'),
            content: const Text(
              'HanziGraph is a Chinese character learning app that helps you explore '
              'character relationships through interactive graph visualization.\n\n'
              'Built with Flutter, transpiled from the original JavaScript version.',
            ),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
          ),
    );
  }
}
