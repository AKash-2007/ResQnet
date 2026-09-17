import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../emergency/models/emergency_incident_model.dart';
import '../../emergency/view_models/emergency_view_model.dart';

class ActivityView extends StatefulWidget {
  const ActivityView({super.key});

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmergencyViewModel>().loadHistory();
    });
  }

  Color _getStatusColor(EmergencyStatus status) {
    switch (status) {
      case EmergencyStatus.resolved:
        return AppColors.success;
      case EmergencyStatus.active:
      case EmergencyStatus.responding:
        return AppColors.sos;
      case EmergencyStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(EmergencyType type) {
    switch (type) {
      case EmergencyType.medical:
        return Icons.medical_services_rounded;
      case EmergencyType.fire:
        return Icons.local_fire_department_rounded;
      case EmergencyType.accident:
        return Icons.car_crash_rounded;
      case EmergencyType.sos:
        return Icons.warning_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final emergencyVm = context.watch<EmergencyViewModel>();
    final history = emergencyVm.incidentHistory;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navActivity),
      ),
      body: SafeArea(
        child: history.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_toggle_off, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No emergency incidents recorded',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: emergencyVm.loadHistory,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: history.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = history[index];
                    final statusColor = _getStatusColor(item.status);

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: statusColor.withOpacity(0.15),
                          child: Icon(_getTypeIcon(item.emergencyType), color: statusColor),
                        ),
                        title: Text(
                          item.emergencyType.name.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}  '
                          '${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}',
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: statusColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            item.status.name.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
