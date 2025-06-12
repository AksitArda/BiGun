import 'package:flutter/material.dart';
import 'package:bigun/core/theme/app_theme.dart';
import 'package:bigun/screens/auth/login_screen.dart';

class SettingsBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 32),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Bildirim Ayarları',
            onTap: () {
              // TODO: Implement notification settings
              Navigator.pop(context);
            },
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Gizlilik Ayarları',
            onTap: () {
              // TODO: Implement privacy settings
              Navigator.pop(context);
            },
          ),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Yardım ve Destek',
            onTap: () {
              // TODO: Implement help and support
              Navigator.pop(context);
            },
          ),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'Hakkında',
            onTap: () {
              // TODO: Implement about screen
              Navigator.pop(context);
            },
          ),
          Divider(color: Colors.white24, height: 32),
          _buildSettingsTile(
            icon: Icons.logout,
            title: 'Çıkış Yap',
            textColor: Colors.red,
            onTap: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppTheme.cardColor,
                  title: Text(
                    'Çıkış Yap',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: Text(
                    'Çıkış yapmak istediğinize emin misiniz?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'İptal',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Implement logout logic
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                          (route) => false,
                        );
                      },
                      child: Text(
                        'Çıkış Yap',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: textColor ?? Colors.white70),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.white54),
      onTap: onTap,
    );
  }
}
