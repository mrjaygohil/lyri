import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../routes/app_routes.dart';
import '../controllers/categories_controller.dart';
import '../models/category_model.dart';

class CategoriesTabView extends StatelessWidget {
  const CategoriesTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final CategoriesController controller = Get.find<CategoriesController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: CustomText(
          'Categories',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          useOutfit: true,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final activeCategories = controller.categories.where((c) => c.status).toList();

        if (activeCategories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category_outlined, size: 64, color: Colors.grey[600]),
                const SizedBox(height: 16),
                const CustomText('No categories found', isSecondary: true),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadCategories,
          color: Theme.of(context).primaryColor,
          backgroundColor: const Color(0xFF1E293B),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 1200
                      ? 4
                      : MediaQuery.of(context).size.width > 800
                          ? 3
                          : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                ),
                itemCount: activeCategories.length,
                itemBuilder: (context, index) {
                  final cat = activeCategories[index];
                  return GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.categorySongs, arguments: cat),
                    child: _HoverCategoryCard(category: cat),
                  );
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _HoverCategoryCard extends StatefulWidget {
  final CategoryModel category;
  const _HoverCategoryCard({required this.category});

  @override
  State<_HoverCategoryCard> createState() => _HoverCategoryCardState();
}

class _HoverCategoryCardState extends State<_HoverCategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _isHovered ? (Matrix4.identity()..scale(1.04)) : Matrix4.identity(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.35 : 0.2),
              blurRadius: _isHovered ? 12 : 6,
              offset: Offset(0, _isHovered ? 6 : 3),
            ),
          ],
          image: cat.image != null && cat.image!.isNotEmpty
              ? DecorationImage(
                  image: CachedNetworkImageProvider(cat.image!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(_isHovered ? 0.45 : 0.55),
                    BlendMode.srcOver,
                  ),
                )
              : null,
          gradient: cat.image == null || cat.image!.isEmpty
              ? const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CustomText(
              cat.name,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
