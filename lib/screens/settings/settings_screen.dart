import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // ADDED: Native device system launcher engine
import '../../services/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  String _modeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  // FIXED: Rewritten to natively trigger your phone's real Mail client application
  void _launchEmail(BuildContext context, String emailAddress) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      queryParameters: {
        'subject': 'Smart Habitat Support Inquiry', // Pre-fills the subject line professionally
      },
    );
    
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch mail client';
      }
    } catch (e) {
      // Graceful fallback dialog if running on an emulator without a configured email account
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Text(
              'Please manually copy and message our support team directly at:\n$emailAddress'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Dismiss'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _navigateToFAQPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const _FAQPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Section 1: Appearance
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10, top: 4),
          child: Text(
            'Appearance',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeController().themeMode,
              builder: (context, currentMode, _) {
                return Column(
                  children: ThemeMode.values.map((mode) {
                    return ListTileTheme(
                      horizontalTitleGap: 8,
                      child: RadioListTile<ThemeMode>(
                        value: mode,
                        groupValue: currentMode,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                        title: Text(
                          _modeLabel(mode),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                        secondary: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            mode == ThemeMode.light
                                ? Icons.light_mode_rounded
                                : mode == ThemeMode.dark
                                    ? Icons.dark_mode_rounded
                                    : Icons.brightness_auto_rounded,
                            size: 26,
                          ),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            ThemeController().setTheme(value);
                          }
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Section 2: About & Help
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'About & Help',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                const ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  leading: Icon(Icons.info_outline_rounded, size: 28),
                  title: Text(
                    'App Version',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text('Smart Habitat v1.0.0', style: TextStyle(fontSize: 14)),
                  ),
                ),
                const Divider(indent: 20, endIndent: 20),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  leading: const Icon(Icons.help_outline_rounded, size: 28),
                  title: const Text(
                    'Help & FAQ',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _navigateToFAQPage(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FAQPage extends StatelessWidget {
  const _FAQPage();

  @override
  Widget build(BuildContext context) {
    const settingsScreen = SettingsScreen();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & FAQ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Smart Habitat delivers real-time analytics for environmental temperature, '
                'humidity, and luminous intensity, supporting automated or manual hardware overrides '
                'via integrated smart devices.',
                style: TextStyle(fontSize: 15, height: 1.4, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Frequently Asked Questions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
            ),
          ),
          Card(
            child: Column(
              children: [
                _buildFAQTile(
                  question: 'How does Auto Mode control the LED lights?',
                  answer: 'Auto Mode uses dynamic ambient light intensity thresholds. When real-time sensors detect values dropping below safety targets, it automatically triggers the system to turn the lights on.',
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildFAQTile(
                  question: 'Can I change the data update time intervals?',
                  answer: 'Yes, navigate over to the Device Control tab and adjust the interval slider anywhere between 2 and 60 seconds to configure tracking updates.',
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _buildFAQTile(
                  question: 'Is my system history saved persistently?',
                  answer: 'Yes, all metrics records and log updates are safely backed up in real-time straight to your connected secure Firebase Cloud instances.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Still need assistance?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.contact_support_rounded, size: 28, color: Colors.teal),
                    title: const Text('Technical Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: const Text('Click to email technical support', style: TextStyle(fontSize: 14, color: Colors.grey)), // FIXED: Clear explanatory text label
                    trailing: const Icon(Icons.open_in_new_rounded, size: 20),
                    onTap: () => settingsScreen._launchEmail(context, 'jitu0001@std.uftb.ac.bd'), // Replace with your support email string
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.business_center_rounded, size: 28, color: Colors.teal),
                    title: const Text('General Inquiries', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: const Text('Click to email general inquiries', style: TextStyle(fontSize: 14, color: Colors.grey)), // FIXED: Clear explanatory text label
                    trailing: const Icon(Icons.open_in_new_rounded, size: 20),
                    onTap: () => settingsScreen._launchEmail(context, '2001024@iot.uftb.ac.bd'), // Replace with your general email string
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQTile({required String question, required String answer}) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
      shape: const Border(),
      collapsedShape: const Border(),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Text(
          answer,
          style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.3),
        ),
      ],
    );
  }
}
