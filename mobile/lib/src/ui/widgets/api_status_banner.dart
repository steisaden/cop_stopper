import 'package:flutter/material.dart';

/// Banner widget to show API status and information
class ApiStatusBanner extends StatelessWidget {
  final bool isRealApiMode;
  final bool isLoading;
  final String? errorMessage;
  final int resultCount;

  const ApiStatusBanner({
    Key? key,
    required this.isRealApiMode,
    this.isLoading = false,
    this.errorMessage,
    this.resultCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isRealApiMode) return const SizedBox.shrink();

    Color backgroundColor;
    Color textColor;
    IconData icon;
    String message;

    if (isLoading) {
      backgroundColor = Colors.blue[50]!;
      textColor = Colors.blue[700]!;
      icon = Icons.sync;
      message = 'Searching UK Police API...';
    } else if (errorMessage != null) {
      backgroundColor = Colors.red[50]!;
      textColor = Colors.red[700]!;
      icon = Icons.error_outline;
      message = 'API Error: $errorMessage';
    } else if (resultCount > 0) {
      backgroundColor = Colors.green[50]!;
      textColor = Colors.green[700]!;
      icon = Icons.verified;
      message = 'Found $resultCount real officers from UK Police API';
    } else {
      backgroundColor = Colors.orange[50]!;
      textColor = Colors.orange[700]!;
      icon = Icons.info_outline;
      message = 'No officers found. Most UK forces don\'t publish senior officer data publicly.';
    }

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (isRealApiMode && !isLoading && errorMessage == null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Currently searching: Leicestershire Police (known to have public data)',
                    style: TextStyle(
                      color: textColor.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}