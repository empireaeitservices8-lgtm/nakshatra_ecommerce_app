import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_palette.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/app_button_widget.dart';
import '../../../widgets/custom_app_bar.dart';
import '../view_model/user_viewmodel.dart';
import 'add_user_screen.dart';

class UserListScreen extends StatefulWidget {
  static const String routeName = '/users';

  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserViewModel>(context, listen: false).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userVM = context.watch<UserViewModel>();
    final users = userVM.users;

    return Scaffold(
      appBar: buildAppBar(
        title: 'System Users',
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: AppPalette.emerald),
            onPressed: () => Navigator.pushNamed(context, AddUserScreen.routeName),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => userVM.fetchUsers(),
        child: users.isEmpty && !userVM.isBusy
            ? const Center(child: Text('No users found')).orShowEmptyWidget(
                items: users,
                isLoading: userVM.isBusy,
                text: 'No system users configured yet',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: AppPalette.emerald.withOpacity(0.1),
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: AppPalette.emerald,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        user.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      subtitle: Text(
                        '${user.role} • ${user.phone}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              user.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete User'),
                                  content: Text('Are you sure you want to remove ${user.name}?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await userVM.deleteUser(user.id);
                                if (mounted) context.showSnackBar('User removed');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ).showProgressOnCenter(isLoading: userVM.isBusy),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AppButton(
          text: 'Add New User',
          onPressed: () => Navigator.pushNamed(context, AddUserScreen.routeName),
        ),
      ),
    );
  }
}
