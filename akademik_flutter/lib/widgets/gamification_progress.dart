import 'package:akademik_flutter/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

class GamificationProgress extends StatelessWidget {
  final double percent;
  final String title;
  final String subtitle;
  final Color progressColor;

  const GamificationProgress({
    super.key,
    required this.percent,
    required this.title,
    required this.subtitle,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:  AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: CircularPercentIndicator(
        radius: 70.0,
        lineWidth: 12.0,
        animation: true,
        percent: percent,
        center: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
          ],
        ),
        footer: Padding(
          padding: const EdgeInsets.only(top:15.0),
          child: Text(subtitle, style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
          ),
        ),
        circularStrokeCap: CircularStrokeCap.round,
        progressColor: progressColor,
        backgroundColor: Colors.grey.withValues(alpha: 0.2),
      ),
    );
  }
}