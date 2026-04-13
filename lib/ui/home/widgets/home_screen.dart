import 'package:diakron_participant/ui/core/ui/custom_screen.dart';
import 'package:diakron_participant/ui/core/ui/error_indicator.dart';
import 'package:diakron_participant/ui/home/view_models/home_viewmodel.dart';
import 'package:diakron_participant/ui/home/widgets/coupon_card_grid.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.viewModel.coupons.isEmpty && !widget.viewModel.load.running) {
      widget.viewModel.load.execute();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScreen(
      title: 'Beneficios',
      actions: [_buildPointsChip(theme), const SizedBox(width: 20)],
      // Using a CustomScrollView for a "sliver" feel (very modern)
      child: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, child) {
            if (widget.viewModel.load.running) {
              return const Center(child: CircularProgressIndicator());
            }

            if (widget.viewModel.load.error) {
              return ErrorIndicator(
                title: 'Error cargando información',
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
                        hintText: 'Buscar beneficio...',
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
                          if (!widget.viewModel.isSearching)
                            IconButton(
                              icon: const Icon(Icons.filter_list),
                              onPressed: () => _showFilterSheet(context),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // 3. PROMO BANNER
                  // SliverToBoxAdapter(child: _buildBanner(theme)),

                  // 4. HORIZONTAL SECTION (Popular)
                  if (!widget.viewModel.isSearching)
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                            child: Text(
                              "Populares 🔥🤑",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(left: 20),
                              itemCount: 5,
                              itemBuilder: (context, index) =>
                                  _buildStoreCard(context),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 5. VERTICAL GRID (All Benefits)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        widget.viewModel.isSearching
                            ? "Resultados de búsqueda"
                            : "Todos los beneficios",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
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
      ),
    );
  }

  Widget _buildPointsChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // color: const Color.fromARGB(255, 8, 72, 7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ListenableBuilder(
            listenable: widget.viewModel.load,
            builder: (context, child) {
              if (widget.viewModel.load.running) {
                return const Center(child: CircularProgressIndicator());
              }
              return Text(
                '${widget.viewModel.points}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Icon(Icons.confirmation_number, size: 18, color: Colors.white),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Use ListenableBuilder inside the sheet so it updates if state changes
        return ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ordenar por',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildRadioTile("Sin filtro", CouponSort.none),
                  _buildRadioTile("Menor precio", CouponSort.priceAsc),
                  _buildRadioTile("Mayor precio", CouponSort.priceDesc),
                  _buildRadioTile("Próximos a caducar", CouponSort.dateAsc),
                  _buildRadioTile(
                    "Mayor tiempo de caducidad",
                    CouponSort.dateDesc,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRadioTile(String title, CouponSort value) {
    return RadioListTile<CouponSort>(
      title: Text(title),
      value: value,
      groupValue: widget.viewModel.currentSort,
      activeColor: Colors.green,
      onChanged: (CouponSort? newValue) {
        if (newValue != null) {
          widget.viewModel.updateSort(newValue);
          context.pop(); // Close the sheet after selection
        }
      },
    );
  }

  Widget _buildStoreCard(BuildContext context) {
    // Usamos colores fijos para la tarjeta interna (naranja suave)

    // porque es parte de la "Marca" de la tienda, no del tema de la app.

    final theme = Theme.of(context);

    return Container(
      width: 130,

      margin: const EdgeInsets.only(right: 15),

      child: Column(
        children: [
          Container(
            height: 120,

            width: 130,

            decoration: BoxDecoration(
              color: const Color(0xFFFFE0B2),

              borderRadius: BorderRadius.circular(15),

              // Borde sutil para que se vea bien en fondo negro
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: const [
                Icon(Icons.storefront, color: Colors.orange, size: 40),

                SizedBox(height: 5),

                Text(
                  "DOÑA AGUA\n& DON CHILE",

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontWeight: FontWeight.bold,

                    color: Colors.redAccent,

                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Doña Agua &\nDon Chile",

            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: 14,

              // Color dinámico para el texto externo
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
