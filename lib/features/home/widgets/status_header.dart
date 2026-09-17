import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../../profile/views/profile_view.dart';

class StatusHeader extends StatelessWidget {
  const StatusHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authVm = context.watch<AuthViewModel>();
    final isAvailable = authVm.currentUser?.availableToHelp ?? false;

    return Column(
      children: [
        // Top row: App Name, Language Switcher, Profile
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.appName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                ),
              ],
            ),
            Row(
              children: [
                // Quick Language Toggle
                TextButton.icon(
                  onPressed: () {
                    final newLang = authVm.currentLocale.languageCode == 'en' ? 'ta' : 'en';
                    authVm.setLanguage(newLang);
                  },
                  icon: const Icon(Icons.translate, size: 18),
                  label: Text(
                    authVm.currentLocale.languageCode == 'en' ? 'தமிழ்' : 'English',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 4),
                // Profile Avatar Button
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileView()),
                    );
                  },
                  icon: const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, size: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Available to Help Toggle Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isAvailable ? AppColors.nearby.withOpacity(0.12) : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isAvailable ? AppColors.nearby.withOpacity(0.4) : Colors.grey.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isAvailable ? Icons.volunteer_activism : Icons.volunteer_activism_outlined,
                color: isAvailable ? AppColors.nearby : Colors.grey,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.availableToHelp,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isAvailable ? AppColors.nearby : null,
                          ),
                    ),
                    Text(
                      isAvailable ? l10n.enabled : l10n.disabled,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isAvailable,
                activeColor: AppColors.nearby,
                onChanged: (val) {
                  authVm.toggleAvailableToHelp(val);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Status Indicators Row: Location & Notifications
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.green),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${l10n.locationStatus}: ${l10n.enabled}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active, size: 16, color: Colors.blue),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${l10n.notificationStatus}: ${l10n.enabled}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
