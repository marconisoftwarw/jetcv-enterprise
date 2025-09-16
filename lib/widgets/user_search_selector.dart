import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/otp_verification_service.dart';
import '../services/certification_user_service.dart';
import '../widgets/enterprise_card.dart';
import '../widgets/enterprise_text_field.dart';

class UserSearchSelector extends StatefulWidget {
  final String legalEntityId;
  final Function(UserData) onUserSelected;
  final List<UserData> selectedUsers;

  const UserSearchSelector({
    super.key,
    required this.legalEntityId,
    required this.onUserSelected,
    required this.selectedUsers,
  });

  @override
  State<UserSearchSelector> createState() => _UserSearchSelectorState();
}

class _UserSearchSelectorState extends State<UserSearchSelector> {
  final TextEditingController _searchController = TextEditingController();
  List<UserData> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  String _lastSearchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    if (query.trim() == _lastSearchQuery) {
      return; // Evita ricerche duplicate
    }

    setState(() {
      _isSearching = true;
      _lastSearchQuery = query.trim();
    });

    try {
      final results =
          await CertificationUserService.getUsersWithAcceptedCertifications(
            legalEntityId: widget.legalEntityId,
            searchQuery: query,
            limit: 20,
          );

      // Filtra gli utenti già selezionati
      final filteredResults = results.where((user) {
        return !widget.selectedUsers.any(
          (selected) => selected.idUser == user.idUser,
        );
      }).toList();

      setState(() {
        _searchResults = filteredResults;
        _hasSearched = true;
        _isSearching = false;
      });
    } catch (e) {
      print('❌ Error searching users: $e');
      setState(() {
        _searchResults = [];
        _hasSearched = true;
        _isSearching = false;
      });
    }
  }

  Future<void> _loadAllAvailableUsers() async {
    // Non fare chiamate se non c'è almeno una ricerca testuale
    // (evita di caricare tutte le certificazioni inutilmente)
    if (_searchController.text.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = true;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // Usa la ricerca corrente nel campo di testo per "Show All"
      final results =
          await CertificationUserService.getUsersWithAcceptedCertifications(
            legalEntityId: widget.legalEntityId,
            searchQuery: _searchController.text.trim(),
            limit: 100, // Aumenta il limite per "Show All"
          );

      // Filtra gli utenti già selezionati
      final filteredResults = results.where((user) {
        return !widget.selectedUsers.any(
          (selected) => selected.idUser == user.idUser,
        );
      }).toList();

      setState(() {
        _searchResults = filteredResults;
        _hasSearched = true;
        _isSearching = false;
      });
    } catch (e) {
      print('❌ Error loading users: $e');
      setState(() {
        _searchResults = [];
        _hasSearched = true;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return EnterpriseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.search,
                color: AppTheme.primaryBlue,
                size: isTablet ? 24 : 20,
              ),
              SizedBox(width: isTablet ? 12 : 8),
              Expanded(
                child: Text(
                  l10n.getString('search_existing_users'),
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlack,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),

          // Description
          Text(
            l10n.getString('search_users_description'),
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),

          // Search field
          Row(
            children: [
              Expanded(
                child: EnterpriseTextField(
                  controller: _searchController,
                  label: l10n.getString('search_users'),
                  hint: l10n.getString('search_by_name_email'),
                  prefixIcon: Icon(Icons.search),
                  onChanged: (value) {
                    // Debounce la ricerca
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (_searchController.text == value) {
                        _searchUsers(value);
                      }
                    });
                  },
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              SizedBox(
                width: isTablet ? 120 : 100,
                child: ElevatedButton(
                  onPressed: _isSearching ? null : _loadAllAvailableUsers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: AppTheme.pureWhite,
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    l10n.getString('show_all'),
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),

          // Loading indicator
          if (_isSearching)
            Center(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      color: AppTheme.primaryBlue,
                      strokeWidth: 2,
                    ),
                    SizedBox(height: isTablet ? 12 : 8),
                    Text(
                      l10n.getString('searching_users'),
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Search results
          if (!_isSearching && _hasSearched) ...[
            if (_searchResults.isEmpty) ...[
              // No results
              Container(
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.borderGrey.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_search,
                      size: isTablet ? 48 : 40,
                      color: AppTheme.textSecondary,
                    ),
                    SizedBox(height: isTablet ? 12 : 8),
                    Text(
                      l10n.getString('no_users_found'),
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: isTablet ? 8 : 4),
                    Text(
                      l10n.getString('try_different_search'),
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Results list
              Container(
                constraints: BoxConstraints(maxHeight: isTablet ? 400 : 300),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: AppTheme.borderGrey.withValues(alpha: 0.3),
                  ),
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    return _buildUserItem(user, isTablet);
                  },
                ),
              ),
            ],
          ],

          // Initial state message
          if (!_hasSearched && !_isSearching)
            Container(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              decoration: BoxDecoration(
                color: AppTheme.lightBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryBlue,
                    size: isTablet ? 20 : 18,
                  ),
                  SizedBox(width: isTablet ? 12 : 8),
                  Expanded(
                    child: Text(
                      l10n.getString('search_users_hint'),
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserItem(UserData user, bool isTablet) {
    // Controlla se firstName o lastName sono null
    final hasFirstName =
        user.firstName != null && user.firstName!.trim().isNotEmpty;
    final hasLastName =
        user.lastName != null && user.lastName!.trim().isNotEmpty;
    final hasFullName =
        user.fullName != null && user.fullName!.trim().isNotEmpty;

    String displayName;
    bool shouldShowEmail = false;

    // Se firstName o lastName sono null, mostra l'email come nome principale
    if (!hasFirstName || !hasLastName) {
      displayName = user.email;
      shouldShowEmail = false; // Non mostrare l'email due volte
    } else if (hasFullName) {
      displayName = user.fullName!.trim();
      shouldShowEmail = true;
    } else {
      final firstName = user.firstName!.trim();
      final lastName = user.lastName!.trim();
      displayName = '$firstName $lastName'.trim();
      shouldShowEmail = true;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          widget.onUserSelected(user);
          // Pulisci la ricerca dopo la selezione
          _searchController.clear();
          setState(() {
            _searchResults = [];
            _hasSearched = false;
            _lastSearchQuery = '';
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16 : 12,
            vertical: isTablet ? 12 : 10,
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: isTablet ? 24 : 20,
                backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                backgroundImage: user.profilePicture?.isNotEmpty == true
                    ? NetworkImage(user.profilePicture!)
                    : null,
                child: user.profilePicture?.isEmpty != false
                    ? Text(
                        displayName.isNotEmpty
                            ? displayName.substring(0, 1).toUpperCase()
                            : 'U',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: isTablet ? 16 : 14,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: isTablet ? 16 : 12),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                    if (shouldShowEmail) ...[
                      SizedBox(height: 2),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                    if (user.phone?.isNotEmpty == true) ...[
                      SizedBox(height: 2),
                      Text(
                        user.phone!,
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Add button/icon
              Container(
                padding: EdgeInsets.all(isTablet ? 8 : 6),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.successGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: AppTheme.successGreen,
                  size: isTablet ? 20 : 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
