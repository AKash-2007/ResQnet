import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../view_models/nearby_view_model.dart';

class NearbySafetyView extends StatelessWidget {
  const NearbySafetyView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nearbyVm = context.watch<NearbyViewModel>();
    final stats = nearbyVm.stats;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nearbySafety),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: nearbyVm.loadNearbyStats,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Privacy Shield Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.nearby.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.nearby.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.nearby,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.privacy_tip, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location Privacy Protected',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.nearby,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.privacyAssurance,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Radius Selector (500m / 1km)
                Row(
                  children: [
                    Text(
                      'Radius:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: Text(l10n.radius500m),
                      selected: nearbyVm.selectedRadius == 500,
                      onSelected: (selected) {
                        if (selected) nearbyVm.setRadius(500);
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(l10n.radius1km),
                      selected: nearbyVm.selectedRadius == 1000,
                      onSelected: (selected) {
                        if (selected) nearbyVm.setRadius(1000);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Aggregated Statistics Card
                if (nearbyVm.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.peopleNearby,
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: Theme.of(context).hintColor,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                              ),
                              if (stats?.isDemo == true)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'SIMULATED',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Total Users Count
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${stats?.totalUsers ?? 0}',
                                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.nearby,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.totalResqnetUsers,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          const Divider(height: 32),

                          // Gender Aggregate Breakdown
                          Row(
                            children: [
                              // Male Count
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.male, color: Colors.blue, size: 28),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${stats?.maleCount ?? 0}',
                                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            l10n.male,
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Female Count
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.pink.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.female, color: Colors.pink, size: 28),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${stats?.femaleCount ?? 0}',
                                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            l10n.female,
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Community Guidelines / Privacy Rules reminder
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ResQnet Community Privacy Standard',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '• No individual user names, phone numbers, or photos are visible.\n'
                        '• No exact coordinates or markers are displayed on maps.\n'
                        '• Data is aggregated using privacy thresholds to prevent de-anonymization.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
