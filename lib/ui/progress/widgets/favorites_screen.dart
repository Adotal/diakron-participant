import 'package:diakron_participant/ui/core/ui/custom_screen.dart';
import 'package:diakron_participant/ui/core/ui/error_indicator.dart';
import 'package:diakron_participant/ui/home/widgets/coupon_card_grid.dart';
import 'package:diakron_participant/ui/progress/view_models/favorites_viewmodel.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, required this.viewModel});

  final FavoritesViewmodel viewModel;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.viewModel.coupons.isEmpty && !widget.viewModel.load.running) {
      widget.viewModel.load.execute();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScreen(
      title: 'Favoritos',
      child: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          if (widget.viewModel.load.running) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.viewModel.load.error) {
            return ErrorIndicator(
              title: 'Error cargando favoritos',
              label: 'Recargar',
              onPressed: widget.viewModel.load.execute,
            );
          }
          return RefreshIndicator(
            onRefresh: () => widget.viewModel.load.execute(),
            child: CustomScrollView(
              slivers: [
                // 2. SEARCH BAR (Pinned or static)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: SearchBar(
                      elevation: WidgetStateProperty.all(0),
                      backgroundColor: WidgetStateProperty.all(
                        const Color.fromRGBO(218, 222, 220, 1),
                      ),
                      hintText: 'Buscar favorito...',
                      leading: const Icon(Icons.search, color: Colors.grey),
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onChanged: widget.viewModel.updateSearchQuery,
                      trailing: [
                        if (widget.viewModel.isSearching)
                          IconButton(
                            icon: const Icon(Icons.filter_list_off),
                            onPressed: () => widget.viewModel.clearFilters(),
                          ),
                      ],
                    ),
                  ),
                ),
                // SliverPadding(
                //   padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                //   sliver: SliverToBoxAdapter(
                //     child: Text(
                //       widget.viewModel.isSearching
                //           ? "Resultados de búsqueda"
                //           : "Todos los beneficios",
                //       style: const TextStyle(
                //         fontSize: 18,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ),
                // ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 15,
                          childAspectRatio: 0.8,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final coupon = widget.viewModel.coupons[index];
                      return CouponCardGrid(coupon: coupon);
                    }, childCount: widget.viewModel.coupons.length),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            ),
          );
        },
      ),
    );
  }
}
