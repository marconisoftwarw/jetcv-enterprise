import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/enterprise_card.dart';
import '../../l10n/app_localizations.dart';
import '../../services/certification_users_outcome_service.dart';
import '../../services/certification_service_v2.dart';
import '../../providers/auth_provider.dart';

class CertificationDetailScreen extends StatefulWidget {
  final String certificationId;
  final Map<String, dynamic>? certificationData;

  const CertificationDetailScreen({
    super.key,
    required this.certificationId,
    this.certificationData,
  });

  @override
  State<CertificationDetailScreen> createState() =>
      _CertificationDetailScreenState();
}

class _CertificationDetailScreenState extends State<CertificationDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<CertificationUserOutcome> _userOutcomes = [];
  Map<String, dynamic>? _certification;
  Map<String, int> _outcomeStats = {};
  bool _isLoading = true;
  String? _errorMessage;

  String _selectedFilter = 'all'; // 'all', 'pending', 'accepted', 'rejected'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _certification = widget.certificationData;
    _loadCertificationDetails();
    _loadUserOutcomes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCertificationDetails() async {
    if (_certification != null) return;

    try {
      final details = await CertificationServiceV2.getCertification(
        widget.certificationId,
      );

      if (details != null && details['data'] != null) {
        setState(() {
          _certification = details['data'];
        });
      }
    } catch (e) {
      print('❌ Error loading certification details: $e');
    }
  }

  Future<void> _loadUserOutcomes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final outcomes =
          await CertificationUsersOutcomeService.getCertificationUsersOutcomes(
            certificationId: widget.certificationId,
          );

      final stats =
          await CertificationUsersOutcomeService.getCertificationOutcomeStats(
            certificationId: widget.certificationId,
          );

      setState(() {
        _userOutcomes = outcomes;
        _outcomeStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Errore nel caricamento degli esiti utenti';
        _isLoading = false;
      });
      print('❌ Error loading user outcomes: $e');
    }
  }

  List<CertificationUserOutcome> get _filteredOutcomes {
    switch (_selectedFilter) {
      case 'pending':
        return CertificationUsersOutcomeService.filterByStatus(
          _userOutcomes,
          'pending',
        );
      case 'accepted':
        return CertificationUsersOutcomeService.filterByStatus(
          _userOutcomes,
          'accepted',
        );
      case 'rejected':
        return CertificationUsersOutcomeService.filterByStatus(
          _userOutcomes,
          'rejected',
        );
      default:
        return _userOutcomes;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isTablet = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: AppTheme.lightGrey.withValues(alpha: 0.1),
      appBar: AppBar(
        backgroundColor: AppTheme.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.getString('certification_details'),
          style: TextStyle(
            color: AppTheme.primaryBlack,
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? 20 : 18,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryBlue,
          tabs: [
            Tab(
              icon: Icon(Icons.dashboard),
              text: l10n.getString('certification_overview'),
            ),
            Tab(icon: Icon(Icons.people), text: l10n.getString('users')),
            Tab(icon: Icon(Icons.photo_library), text: l10n.getString('media')),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(l10n, isTablet),
            _buildUsersTab(l10n, isTablet),
            _buildMediaTab(l10n, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(AppLocalizations l10n, bool isTablet) {
    if (_certification == null) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 32 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCertificationInfo(l10n, isTablet),
          SizedBox(height: isTablet ? 32 : 24),
          _buildOutcomeStatsCards(l10n, isTablet),
        ],
      ),
    );
  }

  Widget _buildUsersTab(AppLocalizations l10n, bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  _buildUserFilters(l10n, isTablet),
                  _buildUsersList(l10n, isTablet),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMediaTab(AppLocalizations l10n, bool isTablet) {
    return Center(
      child: Text(
        'Media tab - To be implemented',
        style: TextStyle(
          fontSize: isTablet ? 18 : 16,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildCertificationInfo(AppLocalizations l10n, bool isTablet) {
    final cert = _certification!;
    final status = cert['status'] ?? 'draft';
    final serialNumber = cert['serial_number'] ?? 'N/A';
    final createdAt =
        DateTime.tryParse(cert['created_at'] ?? '') ?? DateTime.now();

    return EnterpriseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isTablet ? 72 : 64,
                height: isTablet ? 72 : 64,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.workspace_premium,
                  color: AppTheme.pureWhite,
                  size: isTablet ? 36 : 32,
                ),
              ),
              SizedBox(width: isTablet ? 20 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Certificazione #$serialNumber',
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(status),
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),
          _buildInfoRow('Creata il', _formatDate(createdAt), isTablet),
          if (cert['sent_at'] != null) ...[
            SizedBox(height: 8),
            _buildInfoRow(
              'Inviata il',
              _formatDate(DateTime.parse(cert['sent_at'])),
              isTablet,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOutcomeStatsCards(AppLocalizations l10n, bool isTablet) {
    if (_outcomeStats.isEmpty) {
      return SizedBox.shrink();
    }

    final total = _outcomeStats['total'] ?? 0;
    final accepted = _outcomeStats['accepted'] ?? 0;
    final rejected = _outcomeStats['rejected'] ?? 0;
    final pending = _outcomeStats['pending'] ?? 0;

    final responded = accepted + rejected;
    final responseRate = total > 0 ? (responded / total * 100) : 0;
    final acceptanceRate = responded > 0 ? (accepted / responded * 100) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.getString('user_outcomes'),
          style: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryBlack,
          ),
        ),
        SizedBox(height: isTablet ? 16 : 12),
        Wrap(
          spacing: isTablet ? 16 : 12,
          runSpacing: isTablet ? 16 : 12,
          children: [
            _buildStatCard(
              l10n.getString('total_users'),
              total.toString(),
              Icons.people,
              AppTheme.primaryBlue,
              isTablet,
            ),
            _buildStatCard(
              l10n.getString('accepted_users'),
              accepted.toString(),
              Icons.check_circle,
              AppTheme.successGreen,
              isTablet,
            ),
            _buildStatCard(
              l10n.getString('rejected_users'),
              rejected.toString(),
              Icons.cancel,
              AppTheme.errorRed,
              isTablet,
            ),
            _buildStatCard(
              l10n.getString('pending_users'),
              pending.toString(),
              Icons.schedule,
              Colors.orange,
              isTablet,
            ),
            _buildStatCard(
              l10n.getString('response_rate'),
              '${responseRate.toStringAsFixed(1)}%',
              Icons.trending_up,
              AppTheme.primaryBlue,
              isTablet,
            ),
            _buildStatCard(
              l10n.getString('acceptance_rate'),
              '${acceptanceRate.toStringAsFixed(1)}%',
              Icons.thumb_up,
              AppTheme.successGreen,
              isTablet,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isTablet,
  ) {
    return Container(
      width: isTablet ? 180 : 150,
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: isTablet ? 24 : 20),
              Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserFilters(AppLocalizations l10n, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderGrey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('all', l10n.getString('all_users'), isTablet),
            SizedBox(width: 8),
            _buildFilterChip(
              'pending',
              l10n.getString('pending_users'),
              isTablet,
            ),
            SizedBox(width: 8),
            _buildFilterChip(
              'accepted',
              l10n.getString('accepted_users'),
              isTablet,
            ),
            SizedBox(width: 8),
            _buildFilterChip(
              'rejected',
              l10n.getString('rejected_users'),
              isTablet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filter, String label, bool isTablet) {
    final isSelected = _selectedFilter == filter;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: isTablet ? 14 : 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? AppTheme.pureWhite : AppTheme.textSecondary,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = filter;
        });
      },
      backgroundColor: AppTheme.lightGrey.withValues(alpha: 0.3),
      selectedColor: AppTheme.primaryBlue,
      checkmarkColor: AppTheme.pureWhite,
    );
  }

  Widget _buildUsersList(AppLocalizations l10n, bool isTablet) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBlue),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            color: AppTheme.errorRed,
          ),
        ),
      );
    }

    final filteredOutcomes = _filteredOutcomes;

    if (filteredOutcomes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: isTablet ? 64 : 48,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              l10n.getString('no_users_found_certification'),
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      itemCount: filteredOutcomes.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: isTablet ? 16 : 12),
      itemBuilder: (context, index) {
        final outcome = filteredOutcomes[index];
        return _buildUserOutcomeCard(outcome, l10n, isTablet);
      },
    );
  }

  Widget _buildUserOutcomeCard(
    CertificationUserOutcome outcome,
    AppLocalizations l10n,
    bool isTablet,
  ) {
    final statusColor = _getUserStatusColor(outcome.status);

    return EnterpriseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: isTablet ? 24 : 20,
                backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                backgroundImage: outcome.profilePicture != null
                    ? NetworkImage(outcome.profilePicture!)
                    : null,
                child: outcome.profilePicture == null
                    ? Text(
                        outcome.displayName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      outcome.displayName,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                    if (outcome.displayName != outcome.email) ...[
                      SizedBox(height: 2),
                      Text(
                        outcome.email,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getUserStatusText(outcome.status, l10n),
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (outcome.reason != null && outcome.reason!.trim().isNotEmpty) ...[
            SizedBox(height: isTablet ? 16 : 12),
            Container(
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              decoration: BoxDecoration(
                color: AppTheme.lightGrey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.getString('response_reason'),
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    outcome.reason!,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: AppTheme.primaryBlack,
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: isTablet ? 12 : 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: isTablet ? 16 : 14,
                color: AppTheme.textSecondary,
              ),
              SizedBox(width: 4),
              Text(
                outcome.respondedAt != null
                    ? '${l10n.getString('responded_on')} ${_formatDate(outcome.respondedAt!)}'
                    : '${l10n.getString('added_on')} ${_formatDate(outcome.addedAt)}',
                style: TextStyle(
                  fontSize: isTablet ? 12 : 10,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryBlack,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'sent':
        return AppTheme.primaryBlue;
      case 'closed':
        return AppTheme.successGreen;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'In Attesa';
      case 'sent':
        return 'Inviata';
      case 'closed':
        return 'Completata';
      default:
        return 'Bozza';
    }
  }

  Color _getUserStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return AppTheme.successGreen;
      case 'rejected':
        return AppTheme.errorRed;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getUserStatusText(String status, AppLocalizations l10n) {
    switch (status) {
      case 'pending':
        return l10n.getString('user_status_pending');
      case 'accepted':
        return l10n.getString('user_status_accepted');
      case 'rejected':
        return l10n.getString('user_status_rejected');
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
