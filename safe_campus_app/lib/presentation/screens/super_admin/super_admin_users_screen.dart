import 'package:safe_campus_app/logic/models/super_admin_university.dart';

import 'package:flutter/material.dart';

import 'package:safe_campus_app/services/super_admin_service.dart';
import 'package:safe_campus_app/logic/models/super_admin_user.dart';

class SuperAdminUsersScreen extends StatefulWidget {
  const SuperAdminUsersScreen({super.key});

  @override
  State<SuperAdminUsersScreen> createState() => _SuperAdminUsersScreenState();
}

class _SuperAdminUsersScreenState extends State<SuperAdminUsersScreen> {
  List<SuperAdminUser> _users = [];
  List<SuperAdminUniversity> _universities = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedRole;
  int? _selectedUniversityId;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadUniversities();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await SuperAdminService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadUniversities() async {
    try {
      final universities = await SuperAdminService.getAllUniversities();
      setState(() {
        _universities = universities;
      });
    } catch (e) {
      // Hata gösterilebilir
    }
  }

  List<SuperAdminUser> get _filteredUsers {
    return _users.where((user) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          user.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _selectedRole == null || user.role == _selectedRole;
      final matchesUniversity =
          _selectedUniversityId == null ||
          user.universityId == _selectedUniversityId;
      return matchesSearch && matchesRole && matchesUniversity;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final roles = _users.map((u) => u.role).toSet().toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcı Yönetimi (SuperAdmin)'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Arama çubuğu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Kullanıcı ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          // Filtre başlıkları ve filtreler
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Rol',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Üniversite',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Rol filtresi
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedRole,
                        hint: const Text('Rol'),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Tümü'),
                          ),
                          ...roles.map(
                            (role) => DropdownMenuItem<String>(
                              value: role,
                              child: Text(role),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedRole = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Üniversite filtresi
                    Expanded(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: _selectedUniversityId,
                        hint: const Text('Üniversite'),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('Tümü'),
                          ),
                          ..._universities.map(
                            (uni) => DropdownMenuItem<int>(
                              value: uni.universityId,
                              child: Text(uni.name),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedUniversityId = value);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Kullanıcı listesi
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                ? const Center(child: Text('Kullanıcı bulunamadı'))
                : RefreshIndicator(
                    onRefresh: _loadUsers,
                    child: ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return _buildUserCard(user);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(SuperAdminUser user) {
    Color roleColor;
    switch (user.role.toLowerCase()) {
      case 'superadmin':
        roleColor = Colors.deepPurple;
        break;
      case 'uniadmin':
        roleColor = Colors.indigo;
        break;
      default:
        roleColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleColor,
          child: Text(
            user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(user.fullName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            if (user.universityName.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(user.universityName, style: const TextStyle(fontSize: 12)),
            ],
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(
                  0.2,
                ), // TODO: withOpacity deprecated, .withValues() ile değiştirilebilir
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.role,
                style: TextStyle(
                  fontSize: 12,
                  color: roleColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _confirmDeleteUser(user);
            } else if (value == 'changeRole') {
              _showChangeRoleDialog(user);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'changeRole',
              child: Row(
                children: [
                  Icon(Icons.swap_horiz, size: 20),
                  SizedBox(width: 8),
                  Text('Rol Değiştir'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Sil', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteUser(SuperAdminUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kullanıcı Sil'),
        content: Text(
          '${user.fullName} kullanıcısını silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteUser(user.userId);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(int userId) async {
    try {
      await SuperAdminService.deleteUser(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kullanıcı silindi'),
            backgroundColor: Colors.green,
          ),
        );
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showChangeRoleDialog(SuperAdminUser user) {
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rol Değiştir'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('user'),
                value: 'user',
                groupValue: selectedRole.toLowerCase(),
                onChanged: (value) => setState(() => selectedRole = value!),
              ),
              RadioListTile<String>(
                title: const Text('uniadmin'),
                value: 'uniadmin',
                groupValue: selectedRole.toLowerCase(),
                onChanged: (value) => setState(() => selectedRole = value!),
              ),
              RadioListTile<String>(
                title: const Text('superadmin'),
                value: 'superadmin',
                groupValue: selectedRole.toLowerCase(),
                onChanged: (value) => setState(() => selectedRole = value!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateUserRole(user.userId, selectedRole);
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserRole(int userId, String newRole) async {
    try {
      await SuperAdminService.updateUserRole(userId, newRole);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rol güncellendi'),
            backgroundColor: Colors.green,
          ),
        );
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
