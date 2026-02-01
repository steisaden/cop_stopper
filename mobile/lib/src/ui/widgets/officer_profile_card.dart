import 'package:flutter/material.dart';
import '../../models/officer_record_model.dart';

/// Enhanced officer profile card with risk assessment and detailed information
class OfficerProfileCard extends StatelessWidget {
  final OfficerRecord officer;
  final VoidCallback? onTap;
  final bool showRiskScore;
  final bool showDetailedInfo;

  const OfficerProfileCard({
    Key? key,
    required this.officer,
    this.onTap,
    this.showRiskScore = true,
    this.showDetailedInfo = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildBasicInfo(context),
              if (showRiskScore) ...[
                const SizedBox(height: 12),
                _buildRiskAssessment(context),
              ],
              if (showDetailedInfo) ...[
                const SizedBox(height: 12),
                _buildDetailedInfo(context),
              ],
              const SizedBox(height: 8),
              _buildDataSource(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          backgroundImage: officer.imageUrl != null 
              ? NetworkImage(officer.imageUrl!) 
              : null,
          child: officer.imageUrl == null 
              ? Icon(
                  Icons.person,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                officer.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Badge #${officer.badgeNumber}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        if (showRiskScore)
          _buildRiskBadge(context),
      ],
    );
  }

  Widget _buildRiskBadge(BuildContext context) {
    final riskScore = officer.riskScore;
    Color badgeColor;
    String riskLevel;
    
    if (riskScore < 20) {
      badgeColor = Colors.green;
      riskLevel = 'LOW';
    } else if (riskScore < 50) {
      badgeColor = Colors.orange;
      riskLevel = 'MED';
    } else {
      badgeColor = Colors.red;
      riskLevel = 'HIGH';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Text(
        riskLevel,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildBasicInfo(BuildContext context) {
    return Column(
      children: [
        _buildInfoRow(
          context,
          Icons.business,
          'Department',
          officer.department,
        ),
        if (officer.rank.isNotEmpty)
          _buildInfoRow(
            context,
            Icons.military_tech,
            'Rank',
            officer.rank,
          ),
        if (officer.yearsOfService > 0)
          _buildInfoRow(
            context,
            Icons.schedule,
            'Years of Service',
            '${officer.yearsOfService} years',
          ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskAssessment(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Risk Assessment',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Complaints',
                  officer.complaints.length.toString(),
                  Colors.red,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Sustained',
                  officer.sustainedComplaints.length.toString(),
                  Colors.deepOrange,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Commendations',
                  officer.commendations.length.toString(),
                  Colors.green,
                ),
              ),
            ],
          ),
          if (officer.yearsOfService > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Complaint Rate: ${officer.complaintRate.toStringAsFixed(2)} per year',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDetailedInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (officer.complaints.isNotEmpty) ...[
          Text(
            'Recent Complaints',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          ...officer.complaints.take(3).map((complaint) => 
            _buildComplaintItem(context, complaint)),
          if (officer.complaints.length > 3)
            Text(
              '... and ${officer.complaints.length - 3} more',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
        if (officer.commendations.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Recent Commendations',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          ...officer.commendations.take(2).map((commendation) => 
            _buildCommendationItem(context, commendation)),
        ],
      ],
    );
  }

  Widget _buildComplaintItem(BuildContext context, ComplaintRecord complaint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning,
            size: 14,
            color: Colors.red[400],
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  complaint.type,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (complaint.date != null)
                  Text(
                    _formatDate(complaint.date!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: complaint.status.toLowerCase().contains('sustained')
                  ? Colors.red[100]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              complaint.status,
              style: TextStyle(
                fontSize: 10,
                color: complaint.status.toLowerCase().contains('sustained')
                    ? Colors.red[700]
                    : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommendationItem(BuildContext context, CommendationRecord commendation) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.star,
            size: 14,
            color: Colors.green[400],
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commendation.type,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (commendation.date != null)
                  Text(
                    _formatDate(commendation.date!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSource(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.info_outline,
          size: 14,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            'Source: ${officer.dataSource} • Reliability: ${(officer.reliability * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
              fontSize: 11,
            ),
          ),
        ),
        Text(
          'Updated ${_formatDate(officer.lastUpdated)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[500],
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${date.year}';
    }
  }
}