import 'package:diakron_participant/models/coupon/coupon.dart';
import 'package:diakron_participant/ui/core/themes/colors.dart';
import 'package:diakron_participant/ui/home/widgets/custom_network_image.dart';
import 'package:flutter/material.dart';

class CouponCardGrid extends StatelessWidget {
  const CouponCardGrid({super.key, required this.coupon});

  final Coupon coupon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // color: Theme.of(context).cardColor,
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Expanded(
                child: Center(
                  child: CustomNetworkImage(urlImage: coupon.urlImage),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon.title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${coupon.pricePoints} puntos',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 0, 40, 95),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
