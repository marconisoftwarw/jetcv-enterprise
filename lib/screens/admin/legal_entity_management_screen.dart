import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/legal_entity.dart';
import '../../models/legal_entity_invitation.dart';
import '../../providers/legal_entity_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/global_hamburger_menu.dart';

class LegalEntityManagementScreen extends StatefulWidget {
  final bool hideMenu;

  const LegalEntityManagementScreen({super.key, this.hideMenu = false});

  @override
  State<LegalEntityManagementScreen> createState() =>
      _LegalEntityManagementScreenState();
}

class _LegalEntityManagementScreenState
    extends State<LegalEntityManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  List<LegalEntity> _filteredEntities = [];
  bool _isMenuExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadLegalEntities();
    _searchController.addListener(_filterEntities);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLegalEntities() async {
    print('🔄 LegalEntityManagementScreen: Starting to load legal entities...');
    final provider = context.read<LegalEntityProvider>();
    await provider.loadLegalEntities();
    print('🔄 LegalEntityManagementScreen: Provider loading completed');
    _filterEntities();
    print('🔄 LegalEntityManagementScreen: Entities filtered');
  }

  void _filterEntities() {
    final provider = context.read<LegalEntityProvider>();
    final query = _searchController.text.trim();

    print('🔍 LegalEntityManagementScreen: Filtering entities...');
    print('🔍 Search query: "$query"');
    print('🔍 Selected status: $_selectedStatus');
    print('🔍 Total entities in provider: ${provider.legalEntities.length}');
    print(
      '🔍 Entity names in provider: ${provider.legalEntities.map((e) => e.legalName).join(', ')}',
    );

    setState(() {
      if (query.isEmpty && _selectedStatus == null) {
        _filteredEntities = provider.legalEntities;
        print(
          '🔍 No filters applied, showing all ${_filteredEntities.length} entities',
        );
      } else {
        _filteredEntities = provider.searchLegalEntities(query);
        print('🔍 After search filter: ${_filteredEntities.length} entities');

        if (_selectedStatus != null) {
          _filteredEntities = _filteredEntities
              .where(
                (entity) =>
                    entity.status.toString().split('.').last == _selectedStatus,
              )
              .toList();
          print('🔍 After status filter: ${_filteredEntities.length} entities');
        }
      }

      print('🔍 Final filtered entities: ${_filteredEntities.length}');
      print(
        '🔍 Final entity names: ${_filteredEntities.map((e) => e.legalName).join(', ')}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    // Se hideMenu è true, restituisci solo il contenuto senza il menu
    if (widget.hideMenu) {
      return Consumer<LegalEntityProvider>(
        builder: (context, provider, child) {
          return _buildMainContent(provider, isTablet);
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MediaQuery.of(context).size.width <= 768
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  setState(() {
                    _isMenuExpanded = !_isMenuExpanded;
                  });
                },
              ),
              title: Text(
                'Gestione Entità Legali',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      body: Stack(
        children: [
          Row(
            children: [
              // Navigation Rail - Solo su desktop o quando espanso su mobile
              if (MediaQuery.of(context).size.width > 768 || _isMenuExpanded)
                Container(
                  width: MediaQuery.of(context).size.width > 768 ? 280 : 260,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(2, 0),
                      ),
                    ],
                  ),
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return GlobalHamburgerMenu(
                        selectedIndex: 2, // Entità Legali
                        onDestinationSelected: (index) {
                          setState(() {
                            _isMenuExpanded = false;
                          });
                          _handleNavigation(index);
                        },
                        isExpanded: _isMenuExpanded,
                        onExpansionChanged: (expanded) {
                          setState(() {
                            _isMenuExpanded = expanded;
                          });
                        },
                        context: context,
                        userType: authProvider.userType,
                      );
                    },
                  ),
                ),

              // Main Content
              Expanded(
                child: Consumer<LegalEntityProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading && provider.legalEntities.isEmpty) {
                      return _buildLoadingState();
                    }

                    return CustomScrollView(
                      slivers: [
                        // Header stile Airbnb (solo su desktop)
                        if (MediaQuery.of(context).size.width > 768)
                          _buildAirbnbHeader(isTablet),

                        // Filtri e statistiche
                        _buildFilterSection(provider, isTablet),

                        // Lista delle entità
                        _buildEntityGrid(provider, isTablet),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),

          // Overlay scuro su mobile quando il menu è aperto
          if (MediaQuery.of(context).size.width <= 768 && _isMenuExpanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isMenuExpanded = false;
                  });
                },
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent(LegalEntityProvider provider, bool isTablet) {
    if (provider.isLoading && provider.legalEntities.isEmpty) {
      return _buildLoadingState();
    }

    return CustomScrollView(
      slivers: [
        // Header stile Airbnb (solo su desktop)
        if (MediaQuery.of(context).size.width > 768)
          _buildAirbnbHeader(isTablet),

        // Filtri e statistiche
        _buildFilterSection(provider, isTablet),

        // Lista delle entità
        _buildEntityGrid(provider, isTablet),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: const Color(0xFF2563EB)),
          const SizedBox(height: 16),
          Text(
            'Caricamento entità legali...',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAirbnbHeader(bool isTablet) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(
          left: isTablet ? 120 : 80,
          right: isTablet ? 120 : 80,
          bottom: 16,
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestione Entità Legali',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Gestisci e monitora le entità registrate',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final user = authProvider.currentUser;
              return CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF2563EB),
                child: Text(
                  user?.initials ?? 'A',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection(LegalEntityProvider provider, bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Statistiche
            _buildStatsRow(provider, isTablet),
            const SizedBox(height: 20),

            // Filtri
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cerca per nome, email o codice...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey[500],
                          size: 20,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Filtro stato
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: DropdownButton<String?>(
                    value: _selectedStatus,
                    hint: Text(
                      'Tutti gli Stati',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                    underline: const SizedBox(),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(AppLocalizations.of(context).getString('all_statuses_short')),
                      ),
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text(AppLocalizations.of(context).getString('pending_short')),
                      ),
                      DropdownMenuItem(
                        value: 'approved',
                        child: Text(AppLocalizations.of(context).getString('approved_short')),
                      ),
                      DropdownMenuItem(
                        value: 'rejected',
                        child: Text(AppLocalizations.of(context).getString('rejected_short')),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                      _filterEntities();
                    },
                  ),
                ),

                const SizedBox(width: 12),

                // Pulsante Nuova Entità
                GestureDetector(
                  onTap: () => _showCreateEntityDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2563EB),
                          const Color(0xFF1D4ED8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Nuova',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(LegalEntityProvider provider, bool isTablet) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Totale',
            provider.totalCount,
            const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'In Attesa',
            provider.pendingCount,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Approvate',
            provider.approvedCount,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Rifiutate',
            provider.rejectedCount,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEntityGrid(LegalEntityProvider provider, bool isTablet) {
    if (_filteredEntities.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState());
    }

    final crossAxisCount = isTablet ? 2 : 1;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isTablet ? 1.1 : 1.0,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final entity = _filteredEntities[index];
          return _buildAirbnbEntityCard(entity, provider);
        }, childCount: _filteredEntities.length),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.business_outlined,
                size: 40,
                color: const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nessuna entità legale',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty || _selectedStatus != null
                  ? 'Prova a modificare i filtri di ricerca'
                  : 'Crea la tua prima entità legale',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _showCreateEntityDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  'Crea Entità',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAirbnbEntityCard(
    LegalEntity entity,
    LegalEntityProvider provider,
  ) {
    final statusColor = _getStatusColor(entity.status);

    return GestureDetector(
      onTap: () => _showEntityDetails(entity),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entity.statusDisplayName,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  PopupMenuButton<LegalEntityStatus>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: LegalEntityStatus.pending,
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: _getStatusColor(LegalEntityStatus.pending),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context).getString('pending_short')),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: LegalEntityStatus.approved,
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: _getStatusColor(
                                LegalEntityStatus.approved,
                              ),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context).getString('approved_short')),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: LegalEntityStatus.rejected,
                        child: Row(
                          children: [
                            Icon(
                              Icons.cancel,
                              color: _getStatusColor(
                                LegalEntityStatus.rejected,
                              ),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context).getString('rejected_short')),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (newStatus) =>
                        _changeEntityStatus(entity, newStatus),
                  ),
                ],
              ),
            ),

            // Contenuto principale
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entity.legalName ?? 'Nome non specificato',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entity.identifierCode ?? 'Codice non specificato',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    if (entity.email != null)
                      Text(
                        entity.email!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.grey[500],
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(entity.createdAt),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Oggi';
    } else if (difference.inDays == 1) {
      return 'Ieri';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} giorni fa';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildHeader(LegalEntityProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistiche
          Row(
            children: [
              _buildStatCard('Totale', provider.totalCount, Colors.blue),
              const SizedBox(width: 12),
              _buildStatCard('In Attesa', provider.pendingCount, Colors.orange),
              const SizedBox(width: 12),
              _buildStatCard('Approvate', provider.approvedCount, Colors.green),
              const SizedBox(width: 12),
              _buildStatCard('Rifiutate', provider.rejectedCount, Colors.red),
            ],
          ),

          const SizedBox(height: 20),

          // Filtri e ricerca
          Row(
            children: [
              // Campo ricerca
              Expanded(
                child: CustomTextField(
                  controller: _searchController,
                  hintText: 'Cerca per nome, email o codice...',
                  prefixIcon: const Icon(Icons.search),
                ),
              ),

              const SizedBox(width: 12),

              // Filtro stato
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String?>(
                  value: _selectedStatus,
                  hint: Text(AppLocalizations.of(context).getString('all_statuses_short')),
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text(AppLocalizations.of(context).getString('all_statuses_short')),
                    ),
                    const DropdownMenuItem(
                      value: 'pending',
                      child: Text(AppLocalizations.of(context).getString('pending_short')),
                    ),
                    const DropdownMenuItem(
                      value: 'approved',
                      child: Text(AppLocalizations.of(context).getString('approved_short')),
                    ),
                    const DropdownMenuItem(
                      value: 'rejected',
                      child: Text(AppLocalizations.of(context).getString('rejected_short')),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                    _filterEntities();
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Pulsante refresh
              IconButton(
                onPressed: _loadLegalEntities,
                icon: const Icon(Icons.refresh),
                tooltip: 'Aggiorna',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEntityList(LegalEntityProvider provider) {
    if (_filteredEntities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Nessuna entità legale trovata',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty || _selectedStatus != null
                  ? 'Prova a modificare i filtri di ricerca'
                  : 'Crea la tua prima entità legale',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredEntities.length,
      itemBuilder: (context, index) {
        final entity = _filteredEntities[index];
        return _buildEntityCard(entity, provider);
      },
    );
  }

  Widget _buildEntityCard(LegalEntity entity, LegalEntityProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con nome e stato
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entity.legalName ?? 'Nome non specificato',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entity.identifierCode ?? 'Codice non specificato',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Stato con possibilità di modifica
                PopupMenuButton<LegalEntityStatus>(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(entity.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(entity.status).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          entity.statusDisplayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(entity.status),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 16,
                          color: _getStatusColor(entity.status),
                        ),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: LegalEntityStatus.pending,
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: _getStatusColor(LegalEntityStatus.pending),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context).getString('pending_short')),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: LegalEntityStatus.approved,
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: _getStatusColor(LegalEntityStatus.approved),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context).getString('approved_short')),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: LegalEntityStatus.rejected,
                      child: Row(
                        children: [
                          Icon(
                            Icons.cancel,
                            color: _getStatusColor(LegalEntityStatus.rejected),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context).getString('rejected_short')),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (newStatus) =>
                      _changeEntityStatus(entity, newStatus),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Informazioni di contatto
            if (entity.email != null || entity.phone != null)
              Row(
                children: [
                  if (entity.email != null) ...[
                    const Icon(Icons.email, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(entity.email!, style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 16),
                  ],
                  if (entity.phone != null) ...[
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(entity.phone!, style: TextStyle(fontSize: 14)),
                  ],
                ],
              ),

            const SizedBox(height: 8),

            // Indicatore inviti attivi
            Consumer<LegalEntityProvider>(
              builder: (context, provider, child) {
                final hasActiveInvitation = provider.hasActiveInvitation(
                  entity.idLegalEntity,
                );
                if (hasActiveInvitation) {
                  return Row(
                    children: [
                      Icon(
                        Icons.mark_email_unread,
                        size: 16,
                        color: Colors.orange[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Invito attivo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 8),

            // Rappresentante legale
            if (entity.legalRapresentative != null)
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Rappresentante: ${entity.legalRapresentative}',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),

            const SizedBox(height: 12),

            // Azioni
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  onPressed: () => _showEntityDetails(entity),
                  icon: const Icon(Icons.visibility),
                  label: Text(AppLocalizations.of(context).getString('details_short')),
                ),

                TextButton.icon(
                  onPressed: () => _showEditEntityDialog(entity),
                  icon: const Icon(Icons.edit),
                  label: Text(AppLocalizations.of(context).getString('edit_short')),
                ),

                TextButton.icon(
                  onPressed: () => _showSendInvitationDialog(entity),
                  icon: const Icon(Icons.email),
                  label: Text(AppLocalizations.of(context).getString('send_invitation_short')),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                ),

                PopupMenuButton<LegalEntityStatus>(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.swap_horiz,
                          size: 16,
                          color: _getStatusColor(entity.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Cambia Stato',
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(entity.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: LegalEntityStatus.pending,
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: _getStatusColor(LegalEntityStatus.pending),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context).getString('pending_short')),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: LegalEntityStatus.approved,
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: _getStatusColor(LegalEntityStatus.approved),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context).getString('approved_short')),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: LegalEntityStatus.rejected,
                      child: Row(
                        children: [
                          Icon(
                            Icons.cancel,
                            color: _getStatusColor(LegalEntityStatus.rejected),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context).getString('rejected_short')),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (newStatus) =>
                      _changeEntityStatus(entity, newStatus),
                ),

                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showDeleteDialog(entity),
                  icon: const Icon(Icons.delete),
                  label: Text(AppLocalizations.of(context).getString('delete_short')),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(LegalEntityStatus status) {
    switch (status) {
      case LegalEntityStatus.pending:
        return Colors.orange;
      case LegalEntityStatus.approved:
        return Colors.green;
      case LegalEntityStatus.rejected:
        return Colors.red;
    }
  }

  void _showEntityDetails(LegalEntity entity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text(entity.legalName ?? 'Dettagli Entità')),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(entity.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(entity.status).withOpacity(0.3),
                ),
              ),
              child: Text(
                entity.statusDisplayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getStatusColor(entity.status),
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Nome Legale', entity.legalName),
              _buildDetailRow('Codice Identificativo', entity.identifierCode),
              _buildDetailRow('Email', entity.email),
              _buildDetailRow('Telefono', entity.phone),
              _buildDetailRow('PEC', entity.pec),
              _buildDetailRow('Sito Web', entity.website),
              _buildDetailRow(
                'Rappresentante Legale',
                entity.legalRapresentative,
              ),
              const SizedBox(height: 16),
              const Text(
                'Indirizzo Operativo:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(entity.displayAddress),
              const SizedBox(height: 8),
              const Text(
                'Sede Legale:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(entity.displayHeadquarters),
              const SizedBox(height: 16),
              _buildDetailRow('Stato', entity.statusDisplayName),
              _buildDetailRow(
                'Data Creazione',
                entity.createdAt.toString().split(' ')[0],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).getString('close_short')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSendInvitationDialog(entity);
            },
            child: Text(AppLocalizations.of(context).getString('send_invitation_short')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEditEntityDialog(entity);
            },
            child: Text(AppLocalizations.of(context).getString('edit_short')),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value ?? 'Non specificato')),
        ],
      ),
    );
  }

  void _showCreateEntityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LegalEntityFormDialog(),
    ).then((_) => _loadLegalEntities());
  }

  void _showEditEntityDialog(LegalEntity entity) {
    showDialog(
      context: context,
      builder: (context) => LegalEntityFormDialog(entity: entity),
    ).then((_) => _loadLegalEntities());
  }

  Future<void> _approveEntity(LegalEntity entity) async {
    final authProvider = context.read<AuthProvider>();
    final adminId = authProvider.currentUser?.idUser;

    // Salva il ScaffoldMessenger prima dell'operazione asincrona
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final success = await context
        .read<LegalEntityProvider>()
        .approveLegalEntity(entity.idLegalEntity);

    if (mounted) {
      if (success) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).getString('entity_approved_successfully_short'))),
        );
      }
      _loadLegalEntities();
    }
  }

  void _showRejectDialog(LegalEntity entity) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).getString('reject_entity_short')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context).getString('enter_rejection_reason_short')),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Motivo del rifiuto...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).getString('cancel_short')),
          ),
          TextButton(
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              final adminId = authProvider.currentUser?.idUser;

              // Salva il ScaffoldMessenger prima dell'operazione asincrona
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              final success = await context
                  .read<LegalEntityProvider>()
                  .rejectLegalEntity(
                    entity.idLegalEntity,
                    reasonController.text,
                  );

              Navigator.of(context).pop();

              if (mounted) {
                if (success) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text(AppLocalizations.of(context).getString('entity_rejected_successfully_short')),
                    ),
                  );
                }
                _loadLegalEntities();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Rifiuta'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(LegalEntity entity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).getString('delete_short')),
        content: Text(
          'Sei sicuro di voler eliminare l\'entità "${entity.legalName ?? 'senza nome'}"? Questa azione non può essere annullata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).getString('cancel_short')),
          ),
          TextButton(
            onPressed: () async {
              final provider = context.read<LegalEntityProvider>();

              // Salva il ScaffoldMessenger prima dell'operazione asincrona
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              final success = await provider.deleteLegalEntity(
                entity.idLegalEntity,
              );

              Navigator.of(context).pop();

              if (mounted) {
                if (success) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text(AppLocalizations.of(context).getString('entity_deleted_successfully_short')),
                    ),
                  );
                  // Ricarica la lista
                  await provider.refreshLegalEntities();
                } else {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Errore nell\'eliminazione dell\'entità'),
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  Future<void> _changeEntityStatus(
    LegalEntity entity,
    LegalEntityStatus newStatus,
  ) async {
    // Se lo stato è lo stesso, non fare nulla
    if (entity.status == newStatus) {
      return;
    }

    // Mostra un dialog di conferma per il cambio di stato
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifica Stato Entità'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sei sicuro di voler modificare lo stato dell\'entità "${entity.legalName ?? 'senza nome'}"?',
            ),
            const SizedBox(height: 8),
            Text(
              'Stato attuale: ${entity.statusDisplayName}',
              style: TextStyle(
                color: _getStatusColor(entity.status),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Nuovo stato: ${_getStatusDisplayName(newStatus)}',
              style: TextStyle(
                color: _getStatusColor(newStatus),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (newStatus == LegalEntityStatus.rejected) ...[
              const SizedBox(height: 16),
              const Text(
                'Motivo del rifiuto (opzionale):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(),
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Inserisci il motivo del rifiuto...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context).getString('cancel_short')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: _getStatusColor(newStatus),
            ),
            child: const Text('Conferma'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final provider = context.read<LegalEntityProvider>();
    bool success = false;
    String? rejectionReason;

    // Se il nuovo stato è rejected, chiedi il motivo
    if (newStatus == LegalEntityStatus.rejected) {
      final reasonController = TextEditingController();
      final reasonConfirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Motivo del Rifiuto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context).getString('enter_rejection_reason_short')),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Motivo del rifiuto...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context).getString('cancel_short')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Rifiuta'),
            ),
          ],
        ),
      );

      if (reasonConfirmed == true) {
        rejectionReason = reasonController.text.isNotEmpty
            ? reasonController.text
            : 'Nessun motivo specificato';
      } else {
        return; // User cancelled
      }
    }

    // Salva il ScaffoldMessenger prima dell'operazione asincrona
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Usa il nuovo metodo unificato per l'aggiornamento dello stato
    success = await provider.updateLegalEntityStatus(
      entity.idLegalEntity,
      newStatus,
      rejectionReason: rejectionReason,
    );

    if (mounted) {
      if (success) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'Stato dell\'entità modificato con successo in "${_getStatusDisplayName(newStatus)}"',
            ),
            backgroundColor: _getStatusColor(newStatus),
          ),
        );
      }
      _loadLegalEntities();
    }
  }

  String _getStatusDisplayName(LegalEntityStatus status) {
    switch (status) {
      case LegalEntityStatus.pending:
        return 'In Attesa';
      case LegalEntityStatus.approved:
        return 'Approvata';
      case LegalEntityStatus.rejected:
        return 'Rifiutata';
    }
  }

  void _showSendInvitationDialog(LegalEntity entity) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController messageController = TextEditingController();

    // Pre-compila l'email se disponibile
    if (entity.email != null && entity.email!.isNotEmpty) {
      emailController.text = entity.email!;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.email, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('Invia Invito Email'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invia un invito via email per l\'entità:',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Container(
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
                    entity.legalName ?? 'Nome non specificato',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (entity.email != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      entity.email!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: emailController,
              labelText: 'Email destinatario *',
              hintText: 'Inserisci l\'email del destinatario',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'L\'email è obbligatoria';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Inserisci un\'email valida';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: messageController,
              labelText: 'Messaggio personalizzato (opzionale)',
              hintText: 'Aggiungi un messaggio personalizzato all\'invito...',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'L\'invito conterrà un link sicuro per accedere alla piattaforma e scadrà automaticamente dopo 7 giorni.',
                      style: TextStyle(color: Colors.blue[700], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).getString('cancel_short')),
          ),
          CustomButton(
            text: 'Invia Invito',
            onPressed: () async {
              // Validazione
              if (emailController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Inserisci un\'email valida'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(emailController.text)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Inserisci un\'email valida'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.of(context).pop();

              // Salva il ScaffoldMessenger prima dell'operazione asincrona
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              // Invia l'invito
              final authProvider = context.read<AuthProvider>();

              // Ottieni l'ID dell'utente corrente
              String? adminId;

              // Prima prova a ottenere l'ID dall'utente già caricato
              if (authProvider.currentUser != null) {
                adminId = authProvider.currentUser!.idUser;
              } else {
                // Se non è caricato, prova a ottenere l'ID direttamente da Supabase
                adminId = await authProvider.getCurrentUserId();
              }

              if (adminId == null) {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Errore: utente non autenticato. Riprova dopo aver effettuato il login.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return;
              }

              final success = await context
                  .read<LegalEntityProvider>()
                  .sendEmailInvitation(
                    email: emailController.text.trim(),
                    legalEntityId: entity.idLegalEntity,
                    inviterId: adminId!,
                  );

              if (mounted) {
                if (success) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Invito inviato con successo a ${emailController.text.trim()}',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Errore nell\'invio dell\'invito'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            isLoading: context.watch<LegalEntityProvider>().isLoading,
            icon: Icons.send,
          ),
        ],
      ),
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0: // Dashboard
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1: // Certificazioni
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 2: // Entità Legali
        // Rimani nella schermata corrente
        break;
      case 3: // Profilo
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 4: // Impostazioni
        Navigator.pushReplacementNamed(context, '/home');
        break;
    }
  }
}

// Dialog per creare/modificare entità legale
class LegalEntityFormDialog extends StatefulWidget {
  final LegalEntity? entity;

  const LegalEntityFormDialog({super.key, this.entity});

  @override
  State<LegalEntityFormDialog> createState() => _LegalEntityFormDialogState();
}

class _LegalEntityFormDialogState extends State<LegalEntityFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final fields = [
      'status',
      'legal_name',
      'identifier_code',
      'operational_address',
      'operational_city',
      'operational_postal_code',
      'operational_state',
      'operational_country',
      'headquarter_address',
      'headquarter_city',
      'headquarter_postal_code',
      'headquarter_state',
      'headquarter_country',
      'legal_rapresentative',
      'email',
      'phone',
      'pec',
      'website',
    ];

    for (final field in fields) {
      _controllers[field] = TextEditingController();

      // Se stiamo modificando, riempi i campi con i valori esistenti
      if (widget.entity != null) {
        String? value;
        switch (field) {
          case 'status':
            value = widget.entity!.status.toString().split('.').last;
            break;
          case 'legal_name':
            value = widget.entity!.legalName;
            break;
          case 'identifier_code':
            value = widget.entity!.identifierCode;
            break;
          case 'operational_address':
            value = widget.entity!.operationalAddress;
            break;
          case 'operational_city':
            value = widget.entity!.operationalCity;
            break;
          case 'operational_postal_code':
            value = widget.entity!.operationalPostalCode;
            break;
          case 'operational_state':
            value = widget.entity!.operationalState;
            break;
          case 'operational_country':
            value = widget.entity!.operationalCountry;
            break;
          case 'headquarter_address':
            value = widget.entity!.headquarterAddress;
            break;
          case 'headquarter_city':
            value = widget.entity!.headquarterCity;
            break;
          case 'headquarter_postal_code':
            value = widget.entity!.headquarterPostalCode;
            break;
          case 'headquarter_state':
            value = widget.entity!.headquarterState;
            break;
          case 'headquarter_country':
            value = widget.entity!.headquarterCountry;
            break;
          case 'legal_rapresentative':
            value = widget.entity!.legalRapresentative;
            break;
          case 'email':
            value = widget.entity!.email;
            break;
          case 'phone':
            value = widget.entity!.phone;
            break;
          case 'pec':
            value = widget.entity!.pec;
            break;
          case 'website':
            value = widget.entity!.website;
            break;
        }
        _controllers[field]!.text = value ?? '';
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entity != null;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  isEditing ? 'Modifica Entità Legale' : 'Nuova Entità Legale',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const Divider(),

            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informazioni Generali
                      const Text(
                        'Informazioni Generali',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _controllers['legal_name'],
                              labelText: 'Nome Legale *',
                              hintText:
                                  'Inserisci il nome legale dell\'azienda',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Il nome legale è obbligatorio';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _controllers['identifier_code'],
                              labelText: 'Codice Identificativo *',
                              hintText: 'P.IVA, Codice Fiscale, etc.',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Il codice identificativo è obbligatorio';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Campo Stato (solo per la modifica)
                      if (isEditing)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _controllers['status']!.text.isNotEmpty
                                ? _controllers['status']!.text
                                : 'pending',
                            decoration: const InputDecoration(
                              labelText: 'Stato *',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'pending',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      color: _getStatusColor(
                                        LegalEntityStatus.pending,
                                      ),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(AppLocalizations.of(context).getString('pending_short')),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'approved',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: _getStatusColor(
                                        LegalEntityStatus.approved,
                                      ),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(AppLocalizations.of(context).getString('approved_short')),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'rejected',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.cancel,
                                      color: _getStatusColor(
                                        LegalEntityStatus.rejected,
                                      ),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(AppLocalizations.of(context).getString('rejected_short')),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                _controllers['status']!.text = value;
                              }
                            },
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Informazioni di Contatto
                      const Text(
                        'Informazioni di Contatto',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _controllers['email'],
                              labelText: 'Email',
                              hintText: 'email@azienda.com',
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _controllers['phone'],
                              labelText: 'Telefono',
                              hintText: '+39 123 456 7890',
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _controllers['pec'],
                              labelText: 'PEC',
                              hintText: 'pec@azienda.legalmail.it',
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _controllers['website'],
                              labelText: 'Sito Web',
                              hintText: 'https://www.azienda.com',
                              keyboardType: TextInputType.url,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _controllers['legal_rapresentative'],
                        labelText: 'Rappresentante Legale',
                        hintText: 'Nome e cognome del rappresentante legale',
                      ),

                      const SizedBox(height: 24),

                      // Indirizzo Operativo
                      const Text(
                        'Indirizzo Operativo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _controllers['operational_address'],
                        labelText: 'Indirizzo',
                        hintText: 'Via/Piazza, numero civico',
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: CustomTextField(
                              controller: _controllers['operational_city'],
                              labelText: 'Città',
                              hintText: 'Roma',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller:
                                  _controllers['operational_postal_code'],
                              labelText: 'CAP',
                              hintText: '00100',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _controllers['operational_state'],
                              labelText: 'Provincia',
                              hintText: 'RM',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _controllers['operational_country'],
                              labelText: 'Paese',
                              hintText: 'Italia',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Sede Legale
                      const Text(
                        'Sede Legale',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _controllers['headquarter_address'],
                        labelText: 'Indirizzo',
                        hintText: 'Via/Piazza, numero civico',
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: CustomTextField(
                              controller: _controllers['headquarter_city'],
                              labelText: 'Città',
                              hintText: 'Milano',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller:
                                  _controllers['headquarter_postal_code'],
                              labelText: 'CAP',
                              hintText: '20100',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _controllers['headquarter_state'],
                              labelText: 'Provincia',
                              hintText: 'MI',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _controllers['headquarter_country'],
                              labelText: 'Paese',
                              hintText: 'Italia',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(),

            // Pulsanti di azione
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context).getString('cancel_short')),
                ),
                const SizedBox(width: 16),
                CustomButton(
                  text: isEditing ? 'Salva Modifiche' : 'Crea Entità',
                  onPressed: _saveEntity,
                  isLoading: context.watch<LegalEntityProvider>().isLoading,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveEntity() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<LegalEntityProvider>();
    final entityData = <String, dynamic>{};

    // Salva il ScaffoldMessenger prima dell'operazione asincrona
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Raccogli i dati dal form
    _controllers.forEach((key, controller) {
      if (controller.text.isNotEmpty) {
        entityData[key] = controller.text;
      }
    });

    // Assicurati che il campo status sia sempre presente per le nuove entità
    if (widget.entity == null && !entityData.containsKey('status')) {
      entityData['status'] = 'pending';
    }

    bool success;
    if (widget.entity != null) {
      // Modifica entità esistente
      final provider = context.read<LegalEntityProvider>();
      success =
          await provider.updateLegalEntity(
            id: widget.entity!.idLegalEntity,
            entityData: entityData,
          ) !=
          null;
    } else {
      // Crea nuova entità
      success = await provider.createLegalEntity(entityData) != null;
    }

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              widget.entity != null
                  ? 'Entità modificata con successo'
                  : 'Entità creata con successo',
            ),
          ),
        );
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  Color _getStatusColor(LegalEntityStatus status) {
    switch (status) {
      case LegalEntityStatus.pending:
        return Colors.orange;
      case LegalEntityStatus.approved:
        return Colors.green;
      case LegalEntityStatus.rejected:
        return Colors.red;
    }
  }
}
