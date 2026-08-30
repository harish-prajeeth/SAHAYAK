import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/api_service.dart';
import '../../utils/i18n.dart';

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

    return SafeArea(
      child: _isLoading
          ? Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(lang.t('common.loading')),
              ],
            ))
          : _error != null
              ? Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 12),
                    Text(_error!, style: TextStyle(color: Colors.red[600])),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _loadAnalytics, child: Text(lang.t('common.retry'))),
                  ],
                ))
              : RefreshIndicator(
                  onRefresh: _loadAnalytics,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(lang.t('analytics.title'),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
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
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildOverviewCards(Map<String, dynamic> overview, LanguageManager lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overview', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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
              icon: Icons.people,
              color: Colors.blue,
            ),
            _OverviewCard(
              title: lang.t('analytics.total_schemes'),
              value: '${overview['totalSchemes'] ?? 0}',
              icon: Icons.category,
              color: Colors.green,
            ),
            _OverviewCard(
              title: lang.t('analytics.total_partners'),
              value: '${overview['totalPartners'] ?? 0}',
              icon: Icons.business,
              color: Colors.orange,
            ),
            _OverviewCard(
              title: lang.t('analytics.total_applications'),
              value: '${overview['totalApplications'] ?? 0}',
              icon: Icons.description,
              color: Colors.purple,
            ),
            _OverviewCard(
              title: lang.t('analytics.approval_rate'),
              value: '${overview['approvalRate'] ?? 0}%',
              icon: Icons.check_circle,
              color: Colors.teal,
            ),
            _OverviewCard(
              title: 'Disbursement Rate',
              value: '${overview['disbursementRate'] ?? 0}%',
              icon: Icons.account_balance,
              color: Colors.indigo,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBreakdown(Map<String, dynamic> statusBreakdown, LanguageManager lang) {
    final total = statusBreakdown.values.fold<int>(0, (sum, v) => sum + (v as int));
    final colors = {
      'draft': Colors.grey,
      'submitted': Colors.blue,
      'under_review': Colors.orange,
      'approved': Colors.green,
      'rejected': Colors.red,
      'disbursed': Colors.purple,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ...statusBreakdown.entries.map((entry) {
              final color = colors[entry.key] ?? Colors.grey;
              final percent = total > 0 ? (entry.value / total * 100) : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('${entry.value} (${percent.toStringAsFixed(0)}%)',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: total > 0 ? entry.value / total : 0,
                      backgroundColor: color.withOpacity(0.1),
                      color: color,
                      minHeight: 8,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSchemeBreakdown(List<dynamic> schemes, LanguageManager lang) {
    final maxCount = schemes.fold<int>(0, (max, s) {
      final count = int.tryParse('${s['count']}') ?? 0;
      return count > max ? count : max;
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.t('analytics.by_scheme'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                        Expanded(child: Text('${scheme['name']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                        Text('${scheme['code']} • $count apps', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: maxCount > 0 ? count / maxCount : 0,
                      backgroundColor: Colors.blue[50],
                      color: Colors.blue,
                      minHeight: 6,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectTypeBreakdown(List<dynamic> projects, LanguageManager lang) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.t('analytics.by_project'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ...projects.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text('${p['project_type']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${p['count']} apps', style: const TextStyle(fontSize: 12)),
                        Text('Avg: ₹${_formatAmount(p['avg_cost'])}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPartners(List<dynamic> partners, LanguageManager lang) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.t('analytics.top_partners'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ...partners.take(5).toList().asMap().entries.map((entry) {
              final partner = entry.value;
              final fundUtil = double.tryParse('${partner['fund_utilization']}') ?? 0;
              final npaRate = double.tryParse('${partner['npa_rate']}') ?? 0;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[50],
                  child: Text('#${entry.key + 1}', style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold)),
                ),
                title: Text('${partner['name']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('${partner['type']}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Fund: ${fundUtil.toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 11, color: fundUtil >= 80 ? Colors.green[700] : Colors.red[700])),
                    Text('NPA: ${npaRate.toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 11, color: npaRate < 5 ? Colors.green[700] : Colors.orange[700])),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectionAnalysis(List<dynamic> rejections, LanguageManager lang) {
    final colors = {
      'document': Colors.orange,
      'eligibility': Colors.red,
      'project': Colors.blue,
      'partner': Colors.purple,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.t('analytics.rejection_analysis'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ...rejections.map((r) {
              final color = colors[r['rejection_category']] ?? Colors.grey;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('${r['rejection_category']?.toUpperCase()}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                        ),
                        const SizedBox(width: 8),
                        Text('${r['count']} rejections', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...(r['reasons'] as List? ?? []).map((reason) => Padding(
                      padding: const EdgeInsets.only(bottom: 4, left: 8),
                      child: Text('• $reason', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                    )),
                  ],
                ),
              );
            }),
          ],
        ),
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.t('analytics.disbursement_pipeline'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            if (pipeline.isEmpty)
              Text('No applications in pipeline', style: TextStyle(color: Colors.grey[600])),
            ...pipeline.map((p) {
              final stageName = stageNames[p['current_stage']] ?? p['current_stage'];
              final count = p['count'];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.circle, size: 12, color: Colors.blue[400]),
                title: Text('$stageName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$count', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[700])),
                ),
              );
            }),
          ],
        ),
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
  final Color color;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
