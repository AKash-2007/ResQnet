import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../emergency/models/emergency_incident_model.dart';
import '../../emergency/view_models/emergency_view_model.dart';
import '../../emergency/views/active_emergency_view.dart';
import '../../nearby/views/nearby_safety_view.dart';
import '../widgets/emergency_card.dart';
import '../widgets/sos_button.dart';
import '../widgets/status_header.dart';

class HomeDashboardView extends StatelessWidget {
  const HomeDashboardView({super.key});

  Future<void> _callOfficialServices() async {
    final uri = Uri.parse('tel:112');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  void _showEmergencyConfirmation(
    BuildContext context, {
    required String title,
    required EmergencyType type,
    bool showOfficialCall = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final emergencyVm = context.read<EmergencyViewModel>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: type == EmergencyType.medical
                  ? AppColors.medical
                  : (type == EmergencyType.fire ? AppColors.fire : AppColors.accident),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.confirmEmergencyMessage),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Text(
                l10n.communityNotice,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            if (showOfficialCall) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _callOfficialServices,
                icon: const Icon(Icons.phone, color: AppColors.primary),
                label: Text(
                  l10n.callOfficialServices,
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await emergencyVm.triggerEmergency(type: type);
              if (success && context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ActiveEmergencyView()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: type == EmergencyType.medical
                  ? AppColors.medical
                  : (type == EmergencyType.fire ? AppColors.fire : AppColors.accident),
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.sendAlert),
          ),
        ],
      ),
    );
  }

  void _triggerSos(BuildContext context) async {
    final emergencyVm = context.read<EmergencyViewModel>();
    final success = await emergencyVm.triggerEmergency(type: EmergencyType.sos);
    if (success && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ActiveEmergencyView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Header
              const StatusHeader(),
              const SizedBox(height: 24),

              // SOS Press and Hold Button
              Center(
                child: SosButton(
                  label: l10n.pressAndHoldSos,
                  onTriggered: () => _triggerSos(context),
                ),
              ),
              const SizedBox(height: 24),

              // 1. Medical Emergency Card
              EmergencyCard(
                title: l10n.medicalEmergency,
                icon: Icons.medical_services_rounded,
                color: AppColors.medical,
                subtitle: 'Cardiac, injury, first-aid community alert',
                onTap: () => _showEmergencyConfirmation(
                  context,
                  title: l10n.confirmMedicalTitle,
                  type: EmergencyType.medical,
                ),
              ),
              const SizedBox(height: 14),

              // 2. Fire Emergency Card
              EmergencyCard(
                title: l10n.fireEmergency,
                icon: Icons.local_fire_department_rounded,
                color: AppColors.fire,
                subtitle: 'Nearby fire evacuation & safety assistance',
                onTap: () => _showEmergencyConfirmation(
                  context,
                  title: l10n.confirmFireTitle,
                  type: EmergencyType.fire,
                  showOfficialCall: true,
                ),
              ),
              const SizedBox(height: 14),

              // 3. Accident Emergency Card
              EmergencyCard(
                title: l10n.accidentEmergency,
                icon: Icons.car_crash_rounded,
                color: AppColors.accident,
                subtitle: 'Road collision, trauma response nearby',
                onTap: () => _showEmergencyConfirmation(
                  context,
                  title: l10n.confirmAccidentTitle,
                  type: EmergencyType.accident,
                  showOfficialCall: true,
                ),
              ),
              const SizedBox(height: 14),

              // 4. Nearby Safety Card
              EmergencyCard(
                title: l10n.nearbySafety,
                icon: Icons.people_outline_rounded,
                color: AppColors.nearby,
                subtitle: 'Aggregated community density & statistics',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NearbySafetyView()),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
