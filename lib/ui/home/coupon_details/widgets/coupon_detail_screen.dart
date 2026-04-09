import 'package:diakron_participant/models/coupon/coupon.dart';
import 'package:diakron_participant/ui/core/ui/error_indicator.dart';
import 'package:diakron_participant/ui/home/coupon_details/view_models/coupon_detail_viewmodel.dart';
import 'package:diakron_participant/ui/home/coupon_details/widgets/business_card.dart';
import 'package:diakron_participant/ui/home/coupon_details/widgets/business_details_dialog.dart';
import 'package:flutter/material.dart';

class CouponDetailScreen extends StatefulWidget {
  const CouponDetailScreen({super.key, required this.viewModel});

  final CouponDetailViewmodel viewModel;

  @override
  State<CouponDetailScreen> createState() => _CouponDetailScreenState();
}

class _CouponDetailScreenState extends State<CouponDetailScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.toggleFavorite.addListener(_onAddFavorite);
  }

  @override
  void didUpdateWidget(covariant CouponDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel != widget.viewModel) {
      oldWidget.viewModel.toggleFavorite.removeListener(_onAddFavorite);
      widget.viewModel.toggleFavorite.addListener(_onAddFavorite);
    }
  }

  @override
  void dispose() {
    widget.viewModel.toggleFavorite.removeListener(_onAddFavorite);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = Colors.green[800]!; // Match your green

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      extendBodyBehindAppBar:
          true, // Crucial to place the image behind the app bar
      body: ListenableBuilder(
        listenable: widget.viewModel.load,
        builder: (context, child) {
          if (widget.viewModel.load.running) {
            return const Center(child: CircularProgressIndicator());
          }
          if (widget.viewModel.load.error) {
            return Center(
              child: ErrorIndicator(
                title: 'Error loading Coupon Info',
                label: 'Try again',
                onPressed: widget.viewModel.load.execute,
              ),
            );
          }
          // If succes store nor coupon arenull
          final store = widget.viewModel.store!;
          final coupon = widget.viewModel.coupon!;
          return CustomScrollView(
            slivers: [
              // Upper Section (Stacked Header + Floating Card)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 400, // Fixed height for the stacked part
                  child: Stack(
                    children: [
                      // 1. Big Network Image (Background)
                      _buildHeaderImage(coupon),
                    ],
                  ),
                ),
              ),

              // Lower Section (Static Content + Button)
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      InkWell(
                        child: BusinessCard(store: store),
                        onTap: () {
                          // showBusinessDetails(context, businessData)

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return BusinessDetailsDialog(store: store);
                            },
                          );
                          // showBusinessDetails(context, store);
                        },
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title + Heart Icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  coupon.title,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                              ListenableBuilder(
                                listenable: widget.viewModel.toggleFavorite,
                                builder: (context, _) {
                                  final bool isFavorite = widget
                                      .viewModel
                                      .isFavorite; // Assuming this bool exists

                                  return IconButton(
                                    iconSize: 28,
                                    onPressed:
                                        widget.viewModel.toggleFavorite.execute,
                                    icon: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      transitionBuilder:
                                          (
                                            Widget child,
                                            Animation<double> animation,
                                          ) {
                                            // This creates a "pop" effect by scaling the heart up and down
                                            return ScaleTransition(
                                              scale: animation,
                                              child: child,
                                            );
                                          },
                                      // Unique keys are required so AnimatedSwitcher knows when to swap
                                      child: isFavorite
                                          ? const Icon(
                                              Icons.favorite,
                                              key: ValueKey('favorite_solid'),
                                              color: Colors.red,
                                            )
                                          : const Icon(
                                              Icons.favorite_border,
                                              key: ValueKey('favorite_border'),
                                              color: Colors.black,
                                            ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // Static Lorem Ipsum Description
                          Text(
                            coupon.descript,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textTheme.bodyMedium?.color,
                              height: 1.5, // Line height for readability
                            ),
                          ),
                          const SizedBox(height: 25),

                          // Points (Static Color for emphasis)
                          RichText(
                            text: TextSpan(
                              text: "Puntos: ",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87, // Match the grey text
                              ),
                              children: [
                                TextSpan(
                                  text: '${coupon.pricePoints}',
                                  style: TextStyle(
                                    color: primaryColor, // The dominant green
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Call to Action Button
                          SizedBox(
                            width: double.infinity,
                            height: 55, // Fixed height for impact
                            child: ElevatedButton(
                              onPressed: () {
                                // Redeem logic
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                              ),
                              child: const Text(
                                "Canjear Recompensa",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30), // Bottom padding
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onAddFavorite() {
    if (widget.viewModel.toggleFavorite.completed) {
      widget.viewModel.toggleFavorite.clearResult();

      if (widget.viewModel.isFavorite) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cupón añadido a favoritos!"),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cupón eliminado de favoritos!"),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }

    if (widget.viewModel.toggleFavorite.error) {
      widget.viewModel.toggleFavorite.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error añadiendo cupón a favoritos")),
      );
    }
  }
}

// --- WIDGET BUILDER METHODS ---
Widget _buildHeaderImage(Coupon coupon) {
  return Positioned.fill(
    child: Image.network(
      coupon.urlImage,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Center(child: Text("Error cargando imagen")),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
    ),
  );
}
