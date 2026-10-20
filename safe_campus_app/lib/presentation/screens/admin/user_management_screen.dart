import 'package:flutter/material.dart';
import 'package:safe_campus_app/logic/models/user.dart';
import 'package:safe_campus_app/services/admin_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<User> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedRole;
  int? _selectedUniversityId;
  int? _selectedUnitId;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await AdminService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } on AdminException catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<User> get _filteredUsers {
    return _users.where((user) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          user.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _selectedRole == null || user.role == _selectedRole;
      final matchesUniversity =
          _selectedUniversityId == null ||
          user.universityId == _selectedUniversityId;
      final matchesUnit =
          _selectedUnitId == null || user.unitId == _selectedUnitId;
      return matchesSearch && matchesRole && matchesUniversity && matchesUnit;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Unique university and unit IDs for dropdowns
    final universityIds =
        _users.map((u) => u.universityId).whereType<int>().toSet().toList()
          ..sort();
    final unitIds =
        _users.map((u) => u.unitId).whereType<int>().toSet().toList()..sort();
    final roles = _users.map((u) => u.role).toSet().toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcı Yönetimi'),
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
                        'Üniversite ID',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Birim ID',
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
                        hint: const Text('Üniversite ID'),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('Tümü'),
                          ),
                          ...universityIds.map(
                            (id) => DropdownMenuItem<int>(
                              value: id,
                              child: Text(id.toString()),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedUniversityId = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Birim filtresi
                    Expanded(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: _selectedUnitId,
                        hint: const Text('Birim ID'),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('Tümü'),
                          ),
                          ...unitIds.map(
                            (id) => DropdownMenuItem<int>(
                              value: id,
                              child: Text(id.toString()),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedUnitId = value);
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

  Widget _buildUserCard(User user) {
    Color roleColor;
    switch (user.role) {
      case 'SuperAdmin':
        roleColor = Colors.deepPurple;
        break;
      case 'UniAdmin':
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
            user.fullName[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(user.fullName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.2),
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

  void _confirmDeleteUser(User user) {
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
              await _deleteUser(user.id);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(int userId) async {
    try {
      final message = await AdminService.deleteUser(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
        _loadUsers();
      }
    } on AdminException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showChangeRoleDialog(User user) {
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
                title: const Text('User'),
                value: 'User',
                groupValue: selectedRole,
                onChanged: (value) => setState(() => selectedRole = value!),
              ),
              RadioListTile<String>(
                title: const Text('UniAdmin'),
                value: 'UniAdmin',
                groupValue: selectedRole,
                onChanged: (value) => setState(() => selectedRole = value!),
              ),
              RadioListTile<String>(
                title: const Text('SuperAdmin'),
                value: 'SuperAdmin',
                groupValue: selectedRole,
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
              await _updateUserRole(user.id, selectedRole);
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserRole(int userId, String newRole) async {
    try {
      final message = await AdminService.updateUserRole(
        userId: userId,
        role: newRole,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
        _loadUsers();
      }
    } on AdminException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    }
  }
}
