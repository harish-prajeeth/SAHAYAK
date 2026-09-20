import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/api_service.dart';
import '../../utils/i18n.dart';
import '../../utils/theme.dart';
import '../../widgets/common/glass_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, dynamic>? _analytics;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final response = await ApiService.getAnalytics();
      if (response['success'] == true) {
        setState(() { _analytics = response['analytics']; _isLoading = false; });
      } else {
        setState(() { _error = 'Failed to load analytics'; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageManager>(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF101836), AppColors.bg],
          stops: [0.0, 0.3],
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? Center(child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.blue),
                  const SizedBox(height: 12),
                  Text(lang.t('common.loading'),
                      style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ))
            : _error != null
                ? Center(child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.red),
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: AppColors.red)),
                      const SizedBox(height: 12),
                      GradientButton(
                        label: lang.t('common.retry'),
                        icon: Icons.refresh_rounded,
                        colors: AppGradients.blue,
                        onPressed: _loadAnalytics,
                      ),
                    ],
                  ))
                : RefreshIndicator(
                    color: AppColors.blue,
                    onRefresh: _loadAnalytics,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(lang.t('analytics.title'),
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        const Text('Platform-wide performance insights',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        const SizedBox(height: 20),

                        // Overview Cards
                        if (_analytics!['overview'] != null) ...[
                          _buildOverviewCards(_analytics!['overview'], lang),
                          const SizedBox(height: 20),
                        ],

                        // Status Breakdown
                        if (_analytics!['statusBreakdown'] != null) ...[
                          _buildStatusBreakdown(_analytics!['statusBreakdown'], lang),
                          const SizedBox(height: 20),
                        ],

                        // By Scheme
                        if (_analytics!['byScheme'] != null) ...[
                          _buildSchemeBreakdown(_analytics!['byScheme'], lang),
                          const SizedBox(height: 20),
                        ],

                        // By Project Type
                        if (_analytics!['byProjectType'] != null) ...[
                          _buildProjectTypeBreakdown(_analytics!['byProjectType'], lang),
                          const SizedBox(height: 20),
                        ],

                        // Top Partners
                        if (_analytics!['topPartners'] != null) ...[
                          _buildTopPartners(_analytics!['topPartners'], lang),
                          const SizedBox(height: 20),
                        ],

                        // Rejection Analysis
                        if (_analytics!['rejectionAnalysis'] != null) ...[
                          _buildRejectionAnalysis(_analytics!['rejectionAnalysis'], lang),
                          const SizedBox(height: 20),
                        ],

                        // Disbursement Pipeline
                        if (_analytics!['disbursementPipeline'] != null) ...[
                          _buildDisbursementPipeline(_analytics!['disbursementPipeline'], lang),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildOverviewCards(Map<String, dynamic> overview, LanguageManager lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Overview'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _OverviewCard(
              title: lang.t('analytics.total_users'),
              value: '${overview['totalUsers'] ?? 0}',
              icon: Icons.people_rounded,
              colors: AppGradients.blue,
            ),
            _OverviewCard(
              title: lang.t('analytics.total_schemes'),
              value: '${overview['totalSchemes'] ?? 0}',
              icon: Icons.category_rounded,
              colors: AppGradients.green,
            ),
            _OverviewCard(
              title: lang.t('analytics.total_partners'),
              value: '${overview['totalPartners'] ?? 0}',
              icon: Icons.business_rounded,
              colors: AppGradients.orange,
            ),
            _OverviewCard(
              title: lang.t('analytics.total_applications'),
              value: '${overview['totalApplications'] ?? 0}',
              icon: Icons.description_rounded,
              colors: AppGradients.purple,
            ),
            _OverviewCard(
              title: lang.t('analytics.approval_rate'),
              value: '${overview['approvalRate'] ?? 0}%',
              icon: Icons.check_circle_rounded,
              colors: AppGradients.cyan,
            ),
            _OverviewCard(
              title: 'Disbursement Rate',
              value: '${overview['disbursementRate'] ?? 0}%',
              icon: Icons.account_balance_rounded,
              colors: AppGradients.indigo,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBreakdown(Map<String, dynamic> statusBreakdown, LanguageManager lang) {
    final total = statusBreakdown.values.fold<int>(0, (sum, v) => sum + (v as int));
    final colors = {
      'draft': AppColors.cyan,
      'submitted': AppColors.blue,
      'under_review': AppColors.orange,
      'approved': AppColors.green,
      'rejected': AppColors.red,
      'disbursed': AppColors.purple,
    };

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Status Breakdown',
              style: TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 16),
          ...statusBreakdown.entries.map((entry) {
            final color = colors[entry.key] ?? AppColors.textMuted;
            final percent = total > 0 ? (entry.value / total * 100) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5)),
                      Text('${entry.value} (${percent.toStringAsFixed(0)}%)',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: total > 0 ? entry.value / total : 0,
                      backgroundColor: color.withOpacity(0.12),
                      color: color,
                      minHeight: 7,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSchemeBreakdown(List<dynamic> schemes, LanguageManager lang) {
    final maxCount = schemes.fold<int>(0, (max, s) {
      final count = int.tryParse('${s['count']}') ?? 0;
      return count > max ? count : max;
    });

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lang.t('analytics.by_scheme'),
              style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 16),
          ...schemes.map((scheme) {
            final count = int.tryParse('${scheme['count']}') ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text('${scheme['name']}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary))),
                      Text('${scheme['code']} • $count apps',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: maxCount > 0 ? count / maxCount : 0,
                      backgroundColor: AppColors.blue.withOpacity(0.12),
                      color: AppColors.blue,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProjectTypeBreakdown(List<dynamic> projects, LanguageManager lang) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lang.t('analytics.by_project'),
              style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 16),
          ...projects.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppGradients.indigo[0].withOpacity(0.14),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppGradients.indigo[0].withOpacity(0.35)),
                  ),
                  child: Text('${p['project_type']}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          color: AppColors.textPrimary)),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${p['count']} apps',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    Text('Avg: ₹${_formatAmount(p['avg_cost'])}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTopPartners(List<dynamic> partners, LanguageManager lang) {
    final rankColors = [
      AppGradients.blue,
      AppGradients.purple,
      AppGradients.green,
      AppGradients.orange,
      AppGradients.cyan,
    ];

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lang.t('analytics.top_partners'),
              style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 16),
          ...partners.take(5).toList().asMap().entries.map((entry) {
            final partner = entry.value;
            final fundUtil = double.tryParse('${partner['fund_utilization']}') ?? 0;
            final npaRate = double.tryParse('${partner['npa_rate']}') ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  GradientIconBadge(icon: Icons.emoji_events_rounded, colors: rankColors[entry.key % rankColors.length], size: 34),
                  const SizedBox(width: 4),
                  Text('#${entry.key + 1}',
                      style: const TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w800,
                          fontSize: 12)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${partner['name']}',
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text('${partner['type']}',
                            style: const TextStyle(
                                fontSize: 11.5, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Fund: ${fundUtil.toStringAsFixed(0)}%',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: fundUtil >= 80 ? AppColors.green : AppColors.red)),
                      Text('NPA: ${npaRate.toStringAsFixed(1)}%',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: npaRate < 5 ? AppColors.green : AppColors.orange)),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRejectionAnalysis(List<dynamic> rejections, LanguageManager lang) {
    final colors = {
      'document': AppColors.orange,
      'eligibility': AppColors.red,
      'project': AppColors.blue,
      'partner': AppColors.purple,
    };

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lang.t('analytics.rejection_analysis'),
              style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 16),
          ...rejections.map((r) {
            final color = colors[r['rejection_category']] ?? AppColors.textMuted;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color.withOpacity(0.4)),
                        ),
                        child: Text('${r['rejection_category']?.toUpperCase()}',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: color)),
                      ),
                      const SizedBox(width: 8),
                      Text('${r['count']} rejections',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...(r['reasons'] as List? ?? []).map((reason) => Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 8),
                    child: Text('• $reason',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                  )),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDisbursementPipeline(List<dynamic> pipeline, LanguageManager lang) {
    final stageNames = {
      'SCA_DISTRICT': 'SCA District',
      'SCA_HEAD': 'SCA Head Office',
      'NSFDC_DESK': 'NSFDC Desk',
      'PCC': 'PCC',
      'CMD': 'CMD Approval',
      'LOI': 'LOI Issued',
      'NSFDC_DISB': 'NSFDC Disbursement',
      'PARTNER_DISB': 'Partner Disbursement',
      'COMPLETE': 'Completed',
    };

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lang.t('analytics.disbursement_pipeline'),
              style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 16),
          if (pipeline.isEmpty)
            Text('No applications in pipeline',
                style: const TextStyle(color: AppColors.textMuted)),
          ...pipeline.map((p) {
            final stageName = stageNames[p['current_stage']] ?? p['current_stage'];
            final count = p['count'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: AppGradients.of(AppGradients.blue),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.blue.withOpacity(0.5), blurRadius: 6),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('$stageName',
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.blue.withOpacity(0.35)),
                    ),
                    child: Text('$count',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: AppColors.blue)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatAmount(dynamic amount) {
    final val = double.tryParse('$amount') ?? 0;
    if (val >= 100000) return '${(val / 100000).toStringAsFixed(1)}L';
    if (val >= 1000) return '${(val / 1000).toStringAsFixed(1)}K';
    return val.toStringAsFixed(0);
  }
}

class _OverviewCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final List<Color> colors;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GradientIconBadge(icon: icon, colors: colors, size: 32),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20)),
          const SizedBox(height: 2),
          Text(title,
              style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
