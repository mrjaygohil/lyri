import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/locale_keys.dart';
import '../../../core/widgets/app_animated_button.dart';
import '../../../core/widgets/app_glass_container.dart';
import '../../../core/widgets/app_glass_icon_button.dart';
import '../../../routes/app_routes.dart';
import '../../authentication/models/profile_model.dart';
import '../../dashboard/widgets/dashboard_layout.dart';
import '../controllers/users_controller.dart';

class UsersView extends GetView<UsersController> {
  const UsersView({super.key});

  void _confirmDelete(BuildContext context, ProfileModel user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(LocaleKeys.deleteUser.tr),
          content: Text('Are you sure you want to delete user "${user.fullName}"? This action is permanent.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(LocaleKeys.cancel.tr),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                controller.deleteUser(user.id);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final RxString searchQuery = ''.obs;

    return DashboardLayout(
      currentRoute: AppRoutes.users,
      child: AppGlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // Header search
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: TextField(
                  onChanged: (val) => searchQuery.value = val,
                  decoration: InputDecoration(
                    hintText: '${LocaleKeys.search.tr} users...',
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Data Table Area
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Local filter based on search query (by full name or email)
                  final filteredUsers = controller.users.where((user) {
                    final query = searchQuery.value.toLowerCase();
                    return user.fullName.toLowerCase().contains(query) ||
                        user.email.toLowerCase().contains(query);
                  }).toList();

                  if (filteredUsers.isEmpty) {
                    return const Center(
                      child: Text('No users found.'),
                    );
                  }

                  return DataTable2(
                    dataRowColor: WidgetStateProperty.all(Colors.transparent),
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 800,
                    columns: [
                      DataColumn2(
                        label: Text(LocaleKeys.name.tr),
                        size: ColumnSize.L,
                      ),
                      const DataColumn2(
                        label: Text('Email'),
                        size: ColumnSize.L,
                      ),
                      const DataColumn2(
                        label: Text('Role'),
                        size: ColumnSize.S,
                      ),
                      DataColumn2(
                        label: Text(LocaleKeys.registrationDate.tr),
                        size: ColumnSize.M,
                      ),
                      const DataColumn2(
                        label: Text('Actions'),
                        size: ColumnSize.M,
                        numeric: true,
                      ),
                    ],
                    rows: filteredUsers.map((user) {
                      final isBanned = user.role == 'banned';
                      final isAdmin = user.role == 'admin';

                      return DataRow(
                        cells: [
                          DataCell(Text(
                            user.fullName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          )),
                          DataCell(Text(user.email)),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isAdmin
                                    ? theme.primaryColor.withOpacity(0.1)
                                    : (isBanned
                                        ? Colors.red.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.1)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                user.role.toUpperCase(),
                                style: TextStyle(
                                  color: isAdmin
                                      ? theme.primaryColor
                                      : (isBanned ? Colors.red : theme.textTheme.bodyMedium?.color),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(
                            DateFormat('yyyy-MM-dd').format(user.createdAt.toLocal()),
                          )),
                          DataCell(
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Don't let admins ban themselves
                                if (!isAdmin) ...[
                                  AppAnimatedButton(
                                    onTap: () => controller.toggleUserBan(user),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: (isBanned ? Colors.green : Colors.amber.shade800).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: (isBanned ? Colors.green : Colors.amber.shade800).withOpacity(0.35),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isBanned ? Icons.check_circle_outline : Icons.block,
                                            size: 14,
                                            color: isBanned ? Colors.green : Colors.amber.shade800,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            isBanned ? LocaleKeys.unbanUser.tr : LocaleKeys.banUser.tr,
                                            style: TextStyle(
                                              color: isBanned ? Colors.green : Colors.amber.shade800,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AppGlassIconButton(
                                    icon: Icons.delete_outline,
                                    color: Colors.redAccent,
                                    onPressed: () => _confirmDelete(context, user),
                                    tooltip: LocaleKeys.deleteUser.tr,
                                  ),
                                ] else
                                  const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  );
                }),
              ),
            ],
          ),
        ),
      );
  }
}
