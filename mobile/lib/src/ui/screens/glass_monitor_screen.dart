import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/src/ui/app_colors.dart';
import 'package:mobile/src/ui/components/glass_surface.dart';

/// Collaborative monitoring screen with dark glassmorphism design
/// Based on Stitch collaborative-monitoring.html
class GlassMonitorScreen extends StatefulWidget {
  const GlassMonitorScreen({Key? key}) : super(key: key);

  @override
  State<GlassMonitorScreen> createState() => _GlassMonitorScreenState();
}

class _GlassMonitorScreenState extends State<GlassMonitorScreen> {
  bool _shareLocation = true;

  final List<NearbyIncident> _incidents = [
    NearbyIncident(
      title: 'Traffic Stop',
      distance: '0.3 mi',
      time: '2 min ago',
      witnesses: 3,
      isActive: true,
    ),
    NearbyIncident(
      title: 'Pedestrian Check',
      distance: '0.8 mi',
      time: '15 min ago',
      witnesses: 1,
      isActive: true,
    ),
    NearbyIncident(
      title: 'Vehicle Search',
      distance: '1.2 mi',
      time: '32 min ago',
      witnesses: 5,
      isActive: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.glassBackground,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Map placeholder
                    _buildMapPlaceholder(),

                    const SizedBox(height: 20),

                    // Location sharing toggle
                    _buildLocationToggle(),

                    const SizedBox(height: 24),

                    // Nearby incidents header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'NEARBY INCIDENTS',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.glassSuccess.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${_incidents.where((i) => i.isActive).length} Active',
                            style: TextStyle(
                              color: AppColors.glassSuccess,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Incident list
                    ..._incidents.map((incident) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildIncidentCard(incident),
                        )),

                    const SizedBox(height: 24),

                    // Emergency contacts
                    _buildEmergencyContacts(),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.glassSurfaceFrosted,
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.groups, color: AppColors.glassPrimary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Community Watch',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.glassSuccess.withOpacity(0.15),
              borderRadius: BorderRadius.circular(999),
              border:
                  Border.all(color: AppColors.glassSuccess.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.glassSuccess,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Online',
                  style: TextStyle(
                    color: AppColors.glassSuccess,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return GlassSurface(
      variant: GlassVariant.inset,
      borderRadius: BorderRadius.circular(20),
      padding: EdgeInsets.zero,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.8,
            colors: [
              AppColors.glassPrimary.withOpacity(0.1),
              AppColors.glassBackground,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Grid lines
            ...List.generate(
                5,
                (i) => Positioned(
                      left: 0,
                      right: 0,
                      top: 40.0 * i,
                      child: Container(
                        height: 1,
                        color: Colors.white.withOpacity(0.03),
                      ),
                    )),
            ...List.generate(
                5,
                (i) => Positioned(
                      top: 0,
                      bottom: 0,
                      left: 60.0 * i + 30,
                      child: Container(
                        width: 1,
                        color: Colors.white.withOpacity(0.03),
                      ),
                    )),

            // Center marker (you)
            Center(
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.glassPrimary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.glassPrimary.withOpacity(0.5),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Icon(Icons.person, color: Colors.white, size: 14),
              ),
            ),

            // Incident markers
            Positioned(
              top: 50,
              right: 60,
              child: _buildMapMarker(AppColors.glassRecording, true),
            ),
            Positioned(
              bottom: 60,
              left: 80,
              child: _buildMapMarker(AppColors.glassWarning, true),
            ),
            Positioned(
              top: 80,
              left: 50,
              child: _buildMapMarker(Colors.white.withOpacity(0.3), false),
            ),

            // Legend
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Tap to expand',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapMarker(Color color, bool isPulsing) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: isPulsing
            ? [
                BoxShadow(color: color.withOpacity(0.5), blurRadius: 8),
              ]
            : null,
      ),
    );
  }

  Widget _buildLocationToggle() {
    return GlassSurface(
      variant: GlassVariant.floating,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _shareLocation
                  ? AppColors.glassSuccess.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.share_location,
              color: _shareLocation
                  ? AppColors.glassSuccess
                  : Colors.white.withOpacity(0.5),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share My Location',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Help others see active witnesses nearby',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _buildToggle(
              _shareLocation, (v) => setState(() => _shareLocation = v)),
        ],
      ),
    );
  }

  Widget _buildIncidentCard(NearbyIncident incident) {
    return GlassSurface(
      variant: GlassVariant.inset,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(16),
      onTap: () {},
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: incident.isActive
                  ? AppColors.glassRecording.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              incident.isActive
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: incident.isActive
                  ? AppColors.glassRecording
                  : Colors.white.withOpacity(0.3),
              size: 20,
            ),
          ),

          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  incident.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 12, color: Colors.white.withOpacity(0.4)),
                    const SizedBox(width: 4),
                    Text(
                      incident.distance,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.schedule,
                        size: 12, color: Colors.white.withOpacity(0.4)),
                    const SizedBox(width: 4),
                    Text(
                      incident.time,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Witnesses count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.remove_red_eye,
                    size: 14, color: Colors.white.withOpacity(0.6)),
                const SizedBox(width: 4),
                Text(
                  '${incident.witnesses}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'EMERGENCY CONTACTS',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ),
        GlassSurface(
          variant: GlassVariant.base,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildEmergencyButton(
                  icon: Icons.call,
                  label: 'Call 911',
                  color: AppColors.glassRecording,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEmergencyButton(
                  icon: Icons.group,
                  label: 'Alert Network',
                  color: AppColors.glassPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => HapticFeedback.heavyImpact(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 26,
        decoration: BoxDecoration(
          color: value ? AppColors.glassSuccess : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(13),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

/// Model for nearby incidents
class NearbyIncident {
  final String title;
  final String distance;
  final String time;
  final int witnesses;
  final bool isActive;

  NearbyIncident({
    required this.title,
    required this.distance,
    required this.time,
    required this.witnesses,
    required this.isActive,
  });
}
