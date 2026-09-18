import 'package:flutter/material.dart';
import '../../../models/trip_model.dart';
import '../../../utils/app_theme.dart';

class DriverTripsTab extends StatefulWidget {
  final TripInfo? activeTrip;
  final List<TripInfo> completedTrips;
  final VoidCallback onNextStopReached;
  final VoidCallback onFinishTrip;

  const DriverTripsTab({
    super.key,
    required this.activeTrip,
    required this.completedTrips,
    required this.onNextStopReached,
    required this.onFinishTrip,
  });

  @override
  State<DriverTripsTab> createState() => _DriverTripsTabState();
}

class _DriverTripsTabState extends State<DriverTripsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.customsBlue,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: AppTheme.customsBlue,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(
                icon: Icon(Icons.alt_route_rounded, size: 20),
                text: 'Active Transit Corridor',
              ),
              Tab(
                icon: Icon(Icons.history_rounded, size: 20),
                text: 'Completed Customs Runs',
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildActiveCorridorView(context),
              _buildCompletedCorridorsView(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveCorridorView(BuildContext context) {
    final trip = widget.activeTrip;

    if (trip == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.route_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'No Active Transit Corridor Assigned',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Start your shift from the Overview tab to load the next Customs container dispatch.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Route Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.slate200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.customsBlue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        trip.routeNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined,
                            size: 16, color: AppTheme.customsBlue),
                        const SizedBox(width: 4),
                        Text(
                          trip.containerNumber,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.slate800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  trip.routeName,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.slate800),
                ),
                const SizedBox(height: 6),
                Text(
                  'From: ${trip.origin}\nTo:   ${trip.destination}',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade700, height: 1.4),
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildRouteMetric('Remaining',
                        '${(trip.totalDistanceKm - trip.coveredDistanceKm).toStringAsFixed(1)} km'),
                    _buildRouteMetric(
                        'Corridor Speed', '${trip.currentSpeedKmH} km/h'),
                    _buildRouteMetric(
                        'Speed Limit', '${trip.speedLimitKmH} km/h'),
                    _buildRouteMetric(
                        'Compliance', '${trip.safetyScore}%'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Route Stops Timeline
          const Text(
            'Customs Checkpoints & Mandatory Waypoints',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.slate200),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: trip.stops.length,
              itemBuilder: (context, index) {
                final stop = trip.stops[index];
                final isLast = index == trip.stops.length - 1;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: stop.isCompleted
                                ? AppTheme.securityGreen
                                : stop.isCurrent
                                    ? AppTheme.customsBlue
                                    : Colors.grey.shade300,
                          ),
                          child: Icon(
                            stop.isCompleted
                                ? Icons.check
                                : stop.isCurrent
                                    ? Icons.my_location
                                    : Icons.circle,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 48,
                            color: stop.isCompleted
                                ? AppTheme.securityGreen
                                : Colors.grey.shade300,
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    stop.name,
                                    style: TextStyle(
                                      fontWeight: stop.isCurrent
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      fontSize: 13,
                                      color: stop.isCurrent
                                          ? AppTheme.customsBlue
                                          : AppTheme.slate800,
                                    ),
                                  ),
                                ),
                                Text(
                                  stop.scheduledTime,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            if (stop.checkpointNote != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                stop.checkpointNote!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          FilledButton.icon(
            onPressed: widget.onNextStopReached,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.customsBlue,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Verify Current Checkpoint Clearance'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCompletedCorridorsView(BuildContext context) {
    if (widget.completedTrips.isEmpty) {
      return Center(
        child: Text(
          'No completed transit runs recorded today.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.completedTrips.length,
      itemBuilder: (context, index) {
        final trip = widget.completedTrips[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.slate200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    trip.routeNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppTheme.customsBlue,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.securityGreenLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'SEAL VERIFIED & DISARMED',
                      style: TextStyle(
                        color: AppTheme.securityGreen,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                trip.routeName,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.slate800),
              ),
              const SizedBox(height: 4),
              Text(
                'Container: ${trip.containerNumber} • RFID: ${trip.rfidLockId}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const Divider(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${trip.totalDistanceKm} km',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Transit Safe Score: ${trip.safetyScore}%',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.securityGreen),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRouteMetric(String label, String val) {
    return Column(
      children: [
        Text(
          val,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.slate800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
