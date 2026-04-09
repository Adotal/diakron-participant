import 'package:diakron_participant/data/repositories/user/participant_repository.dart';
import 'package:diakron_participant/models/coupon/coupon.dart';
import 'package:diakron_participant/models/store/store.dart';
import 'package:diakron_participant/utils/command.dart';
import 'package:diakron_participant/utils/result.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/web.dart';

class CouponDetailViewmodel extends ChangeNotifier {
  CouponDetailViewmodel({
    required ParticipantRepository participantRepository,
    required int couponId,
  }) : _participantRepository = participantRepository,
       _couponId = couponId {
    load = Command0(_load)..execute();
  }

  final int _couponId;
  final ParticipantRepository _participantRepository;

  late Command0 load;

  Coupon? _coupon;
  Coupon? get coupon => _coupon;
  Store? _store;
  Store? get store => _store;
  final _logger = Logger();

  Future<Result<void>> _load() async {
    try {
      // First load coupon
      final result = await _participantRepository.fetchCoupon(
        couponId: _couponId,
      );

      switch (result) {
        case Ok<Coupon>():
          _coupon = result.value; // Reset any local image choices on reload
          _logger.w(_coupon.toString());
        case Error<Coupon>():
          _logger.e(result.error);
      }

      // Danach load store
      final resultStore = await _participantRepository.fetchStore(
        storeId: _coupon!.idStore,
      );

      switch (resultStore) {
        case Ok<Store>():
          _store = resultStore.value; // Reset any local image choices on reload
          _logger.w(_store.toString());
        case Error<Store>():
          _logger.e(resultStore.error);
      }

      return resultStore;
    } finally {
      notifyListeners();
    }
  }
}
