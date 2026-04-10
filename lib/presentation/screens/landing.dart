import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

void main() {
  runApp(const WaslaApp());
}

class WaslaApp extends StatelessWidget {
  const WaslaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wasla (وصلة)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0C1445),
          onPrimary: Colors.white,
          primaryContainer: Color(0xFF0E1647),
          onPrimaryContainer: Color(0xFF7980B6),
          secondary: Color(0xFF735C00),
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFFFDD34D),
          onSecondaryContainer: Color(0xFF725B00),
          tertiary: Color(0xFF360F01),
          onTertiary: Colors.white,
          tertiaryContainer: Color(0xFF360F01),
          onTertiaryContainer: Color(0xFFB4745A),
          surface: Color(0xFFF7F9FC),
          onSurface: Color(0xFF191C1E),
          surfaceContainerHighest: Color(0xFFE0E3E6),
          onSurfaceVariant: Color(0xFF46464F),
          error: Color(0xFFBA1A1A),
          onError: Colors.white,
          errorContainer: Color(0xFFFFDAD6),
          onErrorContainer: Color(0xFF93000A),
          outline: Color(0xFF767680),
          outlineVariant: Color(0xFFC7C5D0),
          inverseSurface: Color(0xFF2D3133),
          onInverseSurface: Color(0xFFEFF1F4),
          inversePrimary: Color(0xFFBCC3FD),
          surfaceTint: Color(0xFF535B8E),
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.manrope(fontWeight: FontWeight.w800),
          displayMedium: GoogleFonts.manrope(fontWeight: FontWeight.w700),
          displaySmall: GoogleFonts.manrope(fontWeight: FontWeight.w700),
          headlineLarge: GoogleFonts.manrope(fontWeight: FontWeight.w700),
          headlineMedium: GoogleFonts.manrope(fontWeight: FontWeight.w600),
          headlineSmall: GoogleFonts.manrope(fontWeight: FontWeight.w600),
          titleLarge: GoogleFonts.manrope(fontWeight: FontWeight.w600),
          titleMedium: GoogleFonts.lexend(fontWeight: FontWeight.w500),
          titleSmall: GoogleFonts.lexend(fontWeight: FontWeight.w500),
          bodyLarge: GoogleFonts.lexend(fontWeight: FontWeight.w400),
          bodyMedium: GoogleFonts.lexend(fontWeight: FontWeight.w400),
          bodySmall: GoogleFonts.lexend(fontWeight: FontWeight.w300),
          labelLarge: GoogleFonts.lexend(fontWeight: FontWeight.w600),
          labelMedium: GoogleFonts.lexend(fontWeight: FontWeight.w500),
          labelSmall: GoogleFonts.lexend(fontWeight: FontWeight.w400),
        ),
        fontFamily: GoogleFonts.lexend().fontFamily,
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: WaslaHomePage(),
      ),
    );
  }
}

class WaslaHomePage extends StatelessWidget {
  const WaslaHomePage({super.key});

  void _navigateToAuth(BuildContext context) {
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildNavBar(context),
          ),
          SliverToBoxAdapter(
            child: _buildHeroSection(context),
          ),
          SliverToBoxAdapter(
            child: _buildFeaturesSection(context),
          ),
          SliverToBoxAdapter(
            child: _buildPartnersSection(context),
          ),
          SliverToBoxAdapter(
            child: _buildForStudentsSection(context),
          ),
          SliverToBoxAdapter(
            child: _buildForProvidersSection(context),
          ),
          SliverToBoxAdapter(
            child: _buildHowItWorksSection(context),
          ),
          SliverToBoxAdapter(
            child: _buildAppPreviewSection(context),
          ),
          SliverToBoxAdapter(
            child: _buildTestimonialsSection(context),
          ),
          SliverToBoxAdapter(
            child: _buildCTASection(context),
          ),
          SliverToBoxAdapter(
            child: _buildFooter(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE2E8F0).withOpacity(0.2),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1280),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Wasla (وصلة)',
                      style: GoogleFonts.manrope(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0C1445),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 32),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 768) {
                          return Row(
                            children: [
                              _buildNavLink(context, 'Home', isActive: true),
                              const SizedBox(width: 24),
                              _buildNavLink(context, 'About Us'),
                              const SizedBox(width: 24),
                              _buildNavLink(context, 'Support'),
                              const SizedBox(width: 24),
                              _buildNavLink(context, 'Terms'),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 1024) {
                          return TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF64748B),
                              textStyle: GoogleFonts.lexend(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            child: const Text('Download App'),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => _navigateToAuth(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C1445),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: GoogleFonts.manrope(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      child: const Text('ابدأ الآن كمقدم خدمة'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavLink(BuildContext context, String text,
      {bool isActive = false}) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        foregroundColor:
            isActive ? const Color(0xFF0C1445) : const Color(0xFF64748B),
        textStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: -0.3,
        ),
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 40,
              color: const Color(0xFF0C1445),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.only(top: 128, bottom: 80),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 1024;

          return Container(
            constraints: const BoxConstraints(maxWidth: 1280),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildHeroContent(context),
                      ),
                      const SizedBox(width: 48),
                      Expanded(
                        flex: 5,
                        child: _buildHeroImage(context),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildHeroContent(context),
                      const SizedBox(height: 48),
                      _buildHeroImage(context),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildHeroContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تعلم، علّم، وانطلق بمستقبلك مع',
          style: GoogleFonts.manrope(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
        Text(
          'وصلة',
          style: GoogleFonts.manrope(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: colorScheme.primaryContainer,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'منصة وصلة تربط بين الطلاب الشغوفين ومقدمي الكورسات المحترفين في بيئة تعليمية متكاملة وسهلة الاستخدام.',
          style: GoogleFonts.lexend(
            fontSize: 20,
            color: colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ElevatedButton(
              onPressed: () => _navigateToAuth(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: colorScheme.primaryContainer.withOpacity(0.2),
                textStyle: GoogleFonts.lexend(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              child: const Text('ابدأ الآن كمقدم خدمة'),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.onSecondaryContainer,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: GoogleFonts.lexend(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              child: const Text('تحميل التطبيق'),
            ),
          ],
        ),
        const SizedBox(height: 48),
        Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.surface,
                      width: 2,
                    ),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAvmFRwnSPX4Rxo_pci96RNhmvpACByeADrgSBlEMifWAusHBIAz3YdQELOQ8fSuGqhaJfekmGWqFoeJTxrHcpluFJ-aEhJp6kSN05Ndf-q--wQH_ezQR7HElXZwEmBELsh9j-Vi_q7cLMp5ZN4bP85enzjpT8LYfWzusyimeHJx6H42Iv_fubB5G8hdlo7MOFYWRX4qeCh7whpFfIQLI9oA5a3FGIZq0NOhcKWNiy5I00GKTKiOUF8VGDXAxV8hg5tXz33Tt1Uy5u_',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(-16, 0),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.surface,
                        width: 2,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBTGljbgg9uFxinTgUCLRYmVtAhT_bdA8XEHyo1WocFWnXj9T-k7cQUliVde7SkBWRxcMYrjCGF5io5o989dkQKF4Fcy1wbUJR-ruPSCDBVxxRTHkd27hbiAlhohMVSFBDRM_d2XQFPLPvJ0ODaLsZ9wnPun9NQwXC3JSERER-ODxBzlkgWA6ELtugZdOleGQu8P324O1CbaqOuHynSDh2RLf6KyTAWoSTHEW3e-sfg1iXQ5KDlLZRoeiF4VATcf-4U-fYEdXPsfSdJ',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(-32, 0),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.surface,
                        width: 2,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDrenjjxALiro_quaPm20EMo56vyxKqql4ky86dYDpsZu8stJeVw7kkJgUpe6Fn93wFRnTzbeGz8uvMuOgIJxJ7lhZotinPG2Nms3Wt4yW1R6Kq0NhB_NB_LC7bpz41A2NzyNmH2r1iPzF-PxdWoJ4fzP_UviEYVuKtYAFqjVXzFg-N8lQIq8TzkgkceYHDdChx1iL4DLjcE2EaN5t1F58bBEO7zvOCenXwD0UKUcsgCrOQJNGCRcU53CFM9tPRA03c61Zgdo_nIljJ',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 48),
            Text(
              '+5,000 طالب انضموا إلينا هذا الشهر',
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 500,
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(192),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
          Center(
            child: Transform.rotate(
              angle: 0.05,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCmbL5vfWU9sMBEFuW8jzwtRdWAbalNEc2_43C4OSvOSxcsN7L22JN37p7R2Y9OXuiuyA7sFV5lJbOiTh-IatyzEh2WdYydHRbNNgsiwiilOnhSp7q813fuqS_d6Dw3fYPuIIR34f9AveayEaIJU4DzIuYuVbCK1ua-cF_y0mhpMYgqIESQOrQAUCzxJlK4ohRgYQ6MmjLmBhSSjGnOxCfR5hJMUF8RLUyMOlittBWC1sx--BS9sAUMbvWmYIk_5UelunX6ijShe-ev',
                    width: double.infinity,
                    height: 350,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.verified,
                        color: colorScheme.secondary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '98%',
                        style: GoogleFonts.manrope(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'نسبة رضا المستخدمين عن جودة التعليم في وصلة',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final features = [
      {
        'icon': Icons.school,
        'title': 'تعلم من أفضل المدربين',
        'description':
            'نخبة من الخبراء في مختلف المجالات يقدمون خلاصة تجاربهم بين يديك.',
        'color': colorScheme.secondaryContainer,
        'iconColor': colorScheme.onSecondaryContainer,
      },
      {
        'icon': Icons.workspace_premium,
        'title': 'كورسات احترافية',
        'description':
            'محتوى تعليمي عالي الجودة مصمم ليتناسب مع متطلبات سوق العمل الحالية.',
        'color': colorScheme.primaryContainer,
        'iconColor': Colors.white,
      },
      {
        'icon': Icons.card_membership,
        'title': 'شهادات معتمدة',
        'description':
            'احصل على شهادة إتمام موثقة تعزز ملفك الشخصي وتفتح لك أبواب الفرص.',
        'color': colorScheme.secondaryContainer,
        'iconColor': colorScheme.onSecondaryContainer,
      },
      {
        'icon': Icons.trending_up,
        'title': 'متابعة تقدمك بسهولة',
        'description':
            'أدوات متطورة تتيح لك قياس مستواك وتتبع إنجازاتك في كل خطوة.',
        'color': colorScheme.primaryContainer,
        'iconColor': Colors.white,
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 96),
      color: colorScheme.surfaceContainer,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1280),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 1;
            if (constraints.maxWidth > 768) crossAxisCount = 2;
            if (constraints.maxWidth > 1024) crossAxisCount = 4;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 32,
                mainAxisSpacing: 32,
                childAspectRatio: 0.85,
              ),
              itemCount: features.length,
              itemBuilder: (context, index) {
                final feature = features[index];
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: feature['color'] as Color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            feature['icon'] as IconData,
                            color: feature['iconColor'] as Color,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          feature['title'] as String,
                          style: GoogleFonts.manrope(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          feature['description'] as String,
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // NEW PARTNERS SECTION
  Widget _buildPartnersSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final partners = [
      {
        'name': 'الجامعة الوطنية',
        'nameEn': 'National University',
        'description': 'شريك استراتيجي في تطوير المحتوى الأكاديمي',
        'image':
            'https://images.unsplash.com/photo-1562774053-701939374585?w=400&h=400&fit=crop',
        'color': const Color(0xFF1e3a8a),
      },
      {
        'name': 'معهد ITC',
        'nameEn': 'ITC Institute',
        'description': 'مركز التدريب التقني المتخصص في البرمجة والتطوير',
        'image':
            'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400&h=400&fit=crop',
        'color': const Color(0xFF0f766e),
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 96),
      color: colorScheme.surfaceContainerLow,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1280),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'شركاء النجاح',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primaryContainer,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'أبرز الشركاء',
              style: GoogleFonts.manrope(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'نفتخر بالتعاون مع أفضل المؤسسات التعليمية والتقنية',
              style: GoogleFonts.lexend(
                fontSize: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 64),
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 768;

                return isDesktop
                    ? Row(
                        children: partners.map((partner) {
                          return Expanded(
                            child: _buildPartnerCard(context, partner),
                          );
                        }).toList(),
                      )
                    : Column(
                        children: partners.map((partner) {
                          return _buildPartnerCard(context, partner);
                        }).toList(),
                      );
              },
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.outlineVariant.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.handshake_outlined,
                    color: colorScheme.primaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'هل ترغب في أن تصبح شريكاً؟ تواصل معنا',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.arrow_back,
                    color: colorScheme.primaryContainer,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerCard(BuildContext context, Map<String, dynamic> partner) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    partner['color'] as Color,
                    (partner['color'] as Color).withOpacity(0.8),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      partner['image'] as String,
                      fit: BoxFit.cover,
                      opacity: const AlwaysStoppedAnimation(0.3),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              partner['name'].toString().contains('جامعة')
                                  ? Icons.account_balance
                                  : Icons.computer,
                              size: 48,
                              color: partner['color'] as Color,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              partner['nameEn'] as String,
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: partner['color'] as Color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Text(
                    partner['name'] as String,
                    style: GoogleFonts.manrope(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: partner['color'] as Color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    partner['description'] as String,
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: partner['color'] as Color,
                      side: BorderSide(color: partner['color'] as Color),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'زيارة الموقع',
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForStudentsSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 96),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1280),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 1024;

            return isDesktop
                ? IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 7,
                          child: _buildStudentsContent(context),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          flex: 5,
                          child: _buildStudentsImage(context),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      _buildStudentsContent(context),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 500,
                        child: _buildStudentsImage(context),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildStudentsContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(160),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'للمتعلمين',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'إذا كنت طالب...',
                style: GoogleFonts.manrope(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'استكشف آلاف الكورسات في مجالات متنوعة، من البرمجة إلى التصميم والفنون. تعلم بمرونة في أي وقت ومن أي مكان.',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  color: const Color(0xFFCBD5E1),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              Column(
                children: [
                  _buildCheckItem(context, 'تصفح واكتشاف سهل للمحتوى'),
                  const SizedBox(height: 16),
                  _buildCheckItem(context, 'تجربة تعلم تفاعلية وسلسة'),
                  const SizedBox(height: 16),
                  _buildCheckItem(context, 'شهادات فورية عند الإتمام'),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondaryContainer,
                  foregroundColor: colorScheme.onSecondaryContainer,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: GoogleFonts.lexend(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                child: const Text('تحميل التطبيق الآن'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          Icons.check_circle,
          color: colorScheme.secondaryContainer,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.lexend(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentsImage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAUlrdrHtiv_lwsJ_4W33IS8HGfh1EK3mRikl_HyQbgUSoQ0AOvorQUMYHO3G8-xmxeZl8Agk5ILbC9iHLDzGcfdeo8oS0w98MTj4u1_GSH0eacGHfJp_5KDDnw6X6l5YPqk45TyrKHIqb7cPqMIkQmIaqx0JL0ABmfIYgcDhEiNdOl02GkGDRCihttpd8d_t_GgaUyfBhG3igRRA8qvWQXYXUB6bcrY34coGisZMKeIxjBfjX0QdYLE2Nr3WCwdah9cu8Xo1okz7Bs',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 32,
            right: 32,
            child: Text(
              '"وجدت شغفي في البرمجة من خلال وصلة، الرحلة كانت ممتعة والنتائج مذهلة!"',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForProvidersSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 96),
      color: colorScheme.surfaceContainerLow,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1280),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 1024;

            return isDesktop
                ? Row(
                    children: [
                      Expanded(
                        child: _buildProvidersImage(context),
                      ),
                      const SizedBox(width: 64),
                      Expanded(
                        child: _buildProvidersContent(context),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildProvidersContent(context),
                      const SizedBox(height: 48),
                      _buildProvidersImage(context),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildProvidersContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final items = [
      {
        'icon': Icons.add_box,
        'title': 'إنشاء الكورسات بسهولة',
        'description':
            'أدوات قوية لرفع الفيديوهات، الملفات، والاختبارات في دقائق.',
      },
      {
        'icon': Icons.groups,
        'title': 'إدارة الطلاب',
        'description':
            'تواصل مع طلابك، تابع تقدمهم، وقدم الدعم الفني مباشرة عبر المنصة.',
      },
      {
        'icon': Icons.payments,
        'title': 'تحقيق الأرباح',
        'description':
            'نظام مالي شفاف يضمن لك استلام مستحقاتك بكل أمان وسهولة.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'للخبراء والمدربين',
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: colorScheme.secondary,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'إذا كنت مدرب أو جهة تعليمية...',
          style: GoogleFonts.manrope(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 32),
        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: colorScheme.primaryContainer,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['description'] as String,
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _navigateToAuth(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            shadowColor: colorScheme.primaryContainer.withOpacity(0.2),
            textStyle: GoogleFonts.lexend(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          child: const Text('ابدأ الآن كمقدم خدمة'),
        ),
      ],
    );
  }

  Widget _buildProvidersImage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 500,
      child: Stack(
        children: [
          Transform.rotate(
            angle: 0.05,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(48),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(48),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                  ]),
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCHuV1jfRRrBGz94v4u7-uXvJMZomK7fOgs_oSygXkqV8IUkVRlfQO7Afq1BrZsh7i8zB9HMW2vgredxwli8_LyuX_W845co8XyJ18FjHxftVxa8jq5hwNvLwnVfqtelqFWChQCoM8QqLWhI09AjGIaLBOttutWWvHBqe0z2AXdPjB0UhGIo4s90wdrHysqyJDVIbdXywyMd5vvF2pwjMOg8CaCCm7lyv50kcep0t125obmwMfmf7HrDQ59rwCItD3w1FQEWz0YojfJ',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -24,
            right: -24,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.surfaceContainerLow,
                  width: 8,
                ),
              ),
              child: Icon(
                Icons.rocket_launch,
                color: colorScheme.onSecondaryContainer,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final steps = [
      {
        'number': '1',
        'icon': Icons.person_add,
        'title': 'سجل حساب',
        'description': 'أنشئ حسابك المجاني في ثوانٍ',
      },
      {
        'number': '2',
        'icon': Icons.search,
        'title': 'اختر كورس',
        'description': 'تصفح وجد ما يناسب اهتمامك',
      },
      {
        'number': '3',
        'icon': Icons.local_library,
        'title': 'تعلم',
        'description': 'شاهد الفيديوهات وطبق الدروس',
      },
      {
        'number': '4',
        'icon': Icons.emoji_events,
        'title': 'احصل على شهادة',
        'description': 'وثق إنجازك وشارك نجاحك',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 96),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1280),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Text(
              'كيف تعمل وصلة؟',
              style: GoogleFonts.manrope(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'أربع خطوات بسيطة تبعدك عن تحقيق أهدافك التعليمية',
              style: GoogleFonts.lexend(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 64),
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 768;

                return isDesktop
                    ? Row(
                        children: steps.map((step) {
                          return Expanded(
                            child: _buildStepCard(context, step),
                          );
                        }).toList(),
                      )
                    : Column(
                        children: steps.map((step) {
                          return _buildStepCard(context, step);
                        }).toList(),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(BuildContext context, Map<String, dynamic> step) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(32),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            child: Text(
              step['number']! as String,
              style: GoogleFonts.manrope(
                fontSize: 96,
                fontWeight: FontWeight.w900,
                color: colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withOpacity(0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  step['icon'] as IconData,
                  color: colorScheme.primaryContainer,
                  size: 28,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                step['title']! as String,
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                step['description']! as String,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppPreviewSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 96),
      color: colorScheme.primaryContainer,
      child: Column(
        children: [
          Text(
            'التطبيق بين يديك',
            style: GoogleFonts.manrope(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'تجربة مستخدم استثنائية مصممة خصيصاً لتناسب نمط حياتك',
            style: GoogleFonts.lexend(
              fontSize: 16,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 80),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPhoneMockup(context, 'mobile/waslasplash.jpg'),
                const SizedBox(width: 32),
                Transform.translate(
                  offset: const Offset(0, 48),
                  child: _buildPhoneMockup(context, 'mobile/home.jpg'),
                ),
                const SizedBox(width: 32),
                _buildPhoneMockup(context, 'mobile/course.jpg'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneMockup(BuildContext context, String imagePath) {
    return Container(
      width: 256,
      height: 540,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: const Color(0xFF1E293B),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final testimonials = [
      {
        'quote':
            '"كأنني امتلكت مفتاحاً لمستقبلي. وصلة لم تكن مجرد منصة، بل كانت الجسر الذي عبرت به نحو أول وظيفة لي كمصمم."',
        'name': 'أحمد علي',
        'role': 'طالب تصميم جرافيك',
        'image':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAnHH7EtfPWJHU6LpzYpU6kOy0L7Mp88d0d8FsFOAXoOKUaSCxFQU_mbXOH_VAATSkR8M0_WsHiFmxkrE6HmKEWLG5j3SuG1K6BdFBkOj_9AEy8ufKR8NZHY52zT3QbMU0XYwc3jdVsfgE0oQhqtNa7a2A9gCIvUPGorF42gKnhQKfWTSsbzVkhC96xiLMErKu77dailcADAZps6Ljq8uOp9HoO35T_FtRbhlz35MPQ2XllQlmfRyg-i5ZPTAPZDwm8jRdlE_rL1DTP',
      },
      {
        'quote':
            '"بصفتي مدربة، وجدت في وصلة الأدوات التي كنت أحلم بها لتوصيل علمي لأكبر عدد ممكن من الطلاب بكل احترافية."',
        'name': 'سارة محمود',
        'role': 'مدربة تطوير أعمال',
        'image':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuD1Lj5nbhIxSEDzyNZSJQNl-JABzcVmDw5nQBRSycpWNLjrt9T-6HjFBKZN15aE8HJGgPGu6UOYOq_2ovXS-VK6GmVhWGEMfv_G2TXrC_kaiLb8RarnU92SoabzPhXr2FKNwg30cX21g8PnJMVPcLKPN7UyO4kiF1jsJ7-pbZI8uWxv2_hFsgJgFb0GwuEfGgzXZRf4ibXSqL-mnN6LH00Oxp9QZIOwZNnL9F_rBzcJVxuZ6JbYH-ftpRKB_Uyt83YOC8t1mXmngAn-',
      },
      {
        'quote':
            '"سهولة الاستخدام وجودة المحتوى هي ما يميز وصلة فعلاً. أنصح بها كل من يبحث عن تطوير حقيقي لمهاراته."',
        'name': 'ياسين إبراهيم',
        'role': 'متخصص تسويق رقمي',
        'image':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuA9VxCUq5ejdGOTS-FKSnLcoT_ULOkXVRo47tl9CbLhdiN2XLeZ-P9AvzWh6caJjZGaIxjna6CuulaPioGMVRR69S8K-tGjlzDtSnoKnQBzhkKLC9vazraTR-eX2cmrEuHV8DQRm9d-0JY-t7y0-Oj6CdkkqmFoax1wYbrIXCUUo_OVyJ9vYIxv-nYup71DHufTO-jsfzS5mSJ2Lhu-CbiiUxkF3RgzizFa4PZ7VaJSEdtfQXA-bCbT3jXl0co4SWeAEQ4bvSu0clko',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 96),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1280),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'قالوا عن وصلة',
                      style: GoogleFonts.manrope(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'قصص نجاح حقيقية بدأت من هنا',
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildNavButton(context, Icons.arrow_forward),
                    const SizedBox(width: 16),
                    _buildNavButton(context, Icons.arrow_back),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 64),
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 768;

                return isDesktop
                    ? Row(
                        children: testimonials.map((t) {
                          return Expanded(
                            child: _buildTestimonialCard(context, t),
                          );
                        }).toList(),
                      )
                    : Column(
                        children: testimonials.map((t) {
                          return _buildTestimonialCard(context, t);
                        }).toList(),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(24),
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon),
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget _buildTestimonialCard(
      BuildContext context, Map<String, String> testimonial) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -16,
            right: 32,
            child: Icon(
              Icons.format_quote,
              size: 48,
              color: colorScheme.secondaryContainer.withOpacity(0.5),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                testimonial['quote']!,
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  color: colorScheme.onSurface,
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(testimonial['image']!),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        testimonial['name']!,
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        testimonial['role']!,
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1280),
        decoration: BoxDecoration(
          color: const Color(0xFFFDD34D),
          borderRadius: BorderRadius.circular(32),
        ),
        padding: const EdgeInsets.all(64),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(80),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFF0C1445).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(80),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Text(
                  'ابدأ رحلتك الآن',
                  style: GoogleFonts.manrope(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0C1445),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'سواء كنت تريد التعلم أو مشاركة معرفتك، وصلة هي المكان الأمثل لتبدأ قصة نجاحك الجديدة.',
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    color: const Color(0xFF0C1445).withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _navigateToAuth(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C1445),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 16,
                        shadowColor: const Color(0xFF0C1445).withOpacity(0.2),
                        textStyle: GoogleFonts.lexend(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      child: const Text('ابدأ الآن كمقدم خدمة'),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0C1445),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: const Color(0xFF0C1445).withOpacity(0.1),
                          ),
                        ),
                        textStyle: GoogleFonts.lexend(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      child: const Text('تحميل التطبيق'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: const Color(0xFF0E1647),
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1280),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 768;

                return isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildFooterColumn1(context),
                          ),
                          Expanded(
                            child: _buildFooterColumn2(context, 'الشركة', [
                              'About Us',
                              'Careers',
                              'Contact Us',
                            ]),
                          ),
                          Expanded(
                            child: _buildFooterColumn2(context, 'القانونية', [
                              'Privacy Policy',
                              'Terms of Service',
                            ]),
                          ),
                          Expanded(
                            child: _buildFooterColumn3(context),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildFooterColumn1(context),
                          const SizedBox(height: 32),
                          _buildFooterColumn2(context, 'الشركة', [
                            'About Us',
                            'Careers',
                            'Contact Us',
                          ]),
                          const SizedBox(height: 32),
                          _buildFooterColumn2(context, 'القانونية', [
                            'Privacy Policy',
                            'Terms of Service',
                          ]),
                          const SizedBox(height: 32),
                          _buildFooterColumn3(context),
                        ],
                      );
              },
            ),
            const SizedBox(height: 48),
            const Divider(
              color: Colors.white10,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '© 2024 Wasla. All rights reserved.',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.language,
                      color: Color(0xFF64748B),
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'العربية',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterColumn1(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wasla (وصلة)',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'منصة تعليمية متكاملة تهدف لتمكين الأفراد والمؤسسات من خلال المعرفة والابتكار.',
          style: GoogleFonts.lexend(
            fontSize: 14,
            color: const Color(0xFF94A3B8),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildSocialButton(context, Icons.public),
            const SizedBox(width: 16),
            _buildSocialButton(context, Icons.share),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(BuildContext context, IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon),
        color: Colors.white,
        iconSize: 20,
        hoverColor: const Color(0xFFFDD34D).withOpacity(0.2),
      ),
    );
  }

  Widget _buildFooterColumn2(
      BuildContext context, String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        ...links.map((link) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                link,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFooterColumn3(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تحميل التطبيق',
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        _buildStoreButton(
            context, Icons.phone_iphone, 'Available on', 'App Store'),
        const SizedBox(height: 12),
        _buildStoreButton(context, Icons.android, 'Get it on', 'Google Play'),
      ],
    );
  }

  Widget _buildStoreButton(
      BuildContext context, IconData icon, String subtitle, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle,
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              Text(
                title,
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
