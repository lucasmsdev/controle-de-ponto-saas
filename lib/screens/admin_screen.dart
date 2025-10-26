import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/user.dart';

/// Tela de administração de usuários (apenas admin e gerente)
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _dataService = DataService();

  @override
  Widget build(BuildContext context) {
    final users = _dataService.users;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administração de Usuários'),
      ),
      body: users.isEmpty
          ? const Center(
              child: Text('Nenhum usuário encontrado'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return _buildUserCard(user);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUserDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Novo Usuário'),
      ),
    );
  }

  Widget _buildUserCard(User user) {
    final isCurrentUser = user.id == _dataService.currentUser?.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(user.name[0].toUpperCase()),
        ),
        title: Text(user.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Chip(
              label: Text(
                user.role.displayName,
                style: const TextStyle(fontSize: 11),
              ),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showUserDialog(user: user),
            ),
            if (!isCurrentUser && _dataService.isAdmin)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(user),
              ),
          ],
        ),
      ),
    );
  }

  void _showUserDialog({User? user}) {
    final isEditing = user != null;
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final passwordController = TextEditingController(text: user?.password ?? '');
    UserRole selectedRole = user?.role ?? UserRole.funcionario;
    String? selectedManagerId = user?.managerId;

    final managers = _dataService.users
        .where((u) => u.role == UserRole.gerente)
        .toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Editar Usuário' : 'Novo Usuário'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserRole>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Usuário',
                    border: OutlineInputBorder(),
                  ),
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedRole = value;
                        if (value != UserRole.funcionario) {
                          selectedManagerId = null;
                        }
                      });
                    }
                  },
                ),
                if (selectedRole == UserRole.funcionario) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String?>(
                    value: selectedManagerId,
                    decoration: const InputDecoration(
                      labelText: 'Gerente Responsável',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Sem gerente'),
                      ),
                      ...managers.map((manager) {
                        return DropdownMenuItem<String?>(
                          value: manager.id,
                          child: Text(manager.name),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => selectedManagerId = value);
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preencha todos os campos'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                bool success = false;
                String message = '';

                if (isEditing) {
                  success = await _dataService.updateUser(
                    user.copyWith(
                      name: nameController.text,
                      email: emailController.text,
                      password: passwordController.text,
                      role: selectedRole,
                      managerId: selectedRole == UserRole.funcionario ? selectedManagerId : null,
                    ),
                  );
                  message = success 
                      ? 'Usuário atualizado com sucesso'
                      : 'Erro ao atualizar usuário';
                } else {
                  final result = await _dataService.addUser(
                    name: nameController.text,
                    email: emailController.text,
                    password: passwordController.text,
                    role: selectedRole,
                    managerId: selectedRole == UserRole.funcionario ? selectedManagerId : null,
                  );
                  success = result['success'];
                  message = result['message'];
                }

                if (mounted) {
                  Navigator.of(context).pop();
                  this.setState(() {});

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: Text(isEditing ? 'Salvar' : 'Criar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o usuário ${user.name}? '
          'Todos os registros de ponto dele também serão removidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await _dataService.deleteUser(user.id);
              
              if (mounted) {
                Navigator.of(context).pop();
                setState(() {});

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                          ? 'Usuário excluído com sucesso'
                          : 'Erro ao excluir usuário',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
