import 'package:flutter/material.dart';
import 'auth_form_fields.dart';

/// لوحة الهيرو (الجانب الأيمن في الوضع العريض)
class AuthHeroPanel extends StatelessWidget {
  const AuthHeroPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AuthColors.primaryBg,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Wasla',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'بوابتك للتميز في التعليم',
            style: TextStyle(
              color: AuthColors.accentYellow,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 48),
          const _HeroFeature(
            icon: Icons.school_outlined,
            title: 'إدارة الدورات بسلاسة',
            subtitle: 'أدوات متقدمة لتنظيم محتواك التعليمي وتقديمه بأفضل صورة.',
          ),
          const SizedBox(height: 28),
          const _HeroFeature(
            icon: Icons.trending_up_rounded,
            title: 'تحليلات دقيقة للأداء',
            subtitle: 'راقب تقدم طلابك وحقق أهدافك من خلال لوحة بيانات ذكية.',
          ),
          const SizedBox(height: 40),
          // الصورة
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/prov.png',
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    color: Colors.white54,
                    size: 48,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HeroFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AuthColors.accentYellow, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
