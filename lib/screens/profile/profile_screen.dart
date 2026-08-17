import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  bool _isProcessing = false;

  void _showChangePasswordModal() {
    final formKey = GlobalKey<FormState>();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;

    final user = _authService.currentUser;
    final isGoogleUser = user?.providerData.any((info) => info.providerId == 'google.com') ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Change Password',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isGoogleUser 
                        ? 'Google accounts must update their password through Google. Click below to receive a secure recovery email.'
                        : 'Verify your current password to apply updates safely.',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    if (!isGoogleUser) ...[
                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: obscureCurrent,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          prefixIcon: const Icon(Icons.lock_open_outlined),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(obscureCurrent ? Icons.visibility_off : Icons.visibility),
                            onPressed: () {
                              setModalState(() => obscureCurrent = !obscureCurrent);
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Current password is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                            onPressed: () {
                              setModalState(() => obscureNew = !obscureNew);
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'New password is required';
                          if (value.length < 6) return 'Must be at least 6 characters';
                          if (value == currentPasswordController.text) return 'Cannot match current password';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: _isProcessing
                          ? null
                          : () async {
                              if (!isGoogleUser && !formKey.currentState!.validate()) return;
                              Navigator.pop(context);
                              setState(() => _isProcessing = true);
                              try {
                                await _authService.updateUserPassword(
                                  currentPassword: currentPasswordController.text.trim(),
                                  newPassword: newPasswordController.text.trim(),
                                );
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Password updated successfully!'), backgroundColor: Colors.green),
                                );
                              } catch (e) {
                                if (!mounted) return;
                                String errorMsg = e.toString();
                                Color snackColor = Colors.red;
                                if (errorMsg.contains('google-user-reset-sent')) {
                                  errorMsg = 'Google reset link emailed! Check your inbox.';
                                  snackColor = Colors.orange.shade800;
                                } else if (errorMsg.contains('wrong-password') || errorMsg.contains('INVALID_LOGIN_CREDENTIALS')) {
                                  errorMsg = 'The current password you entered is incorrect.';
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(errorMsg), backgroundColor: snackColor),
                                );
                              } finally {
                                if (mounted) setState(() => _isProcessing = false);
                              }
                            },
                      child: Text(isGoogleUser ? 'Send Google Reset Link' : 'Update Password'),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.person, size: 40),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: const Text('Name'),
                      subtitle: Text(user?.displayName ?? 'N/A'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Email'),
                      subtitle: Text(user?.email ?? 'N/A'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to log out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _authService.signOut();
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.lock_reset),
                  title: const Text('Change Password'),
                  onTap: _isProcessing ? null : _showChangePasswordModal,
                ),
              ),
            ],
          ),
          if (_isProcessing)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
