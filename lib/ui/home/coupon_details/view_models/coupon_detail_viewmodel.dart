import 'package:diakron_participant/data/repositories/user/participant_repository.dart';
import 'package:diakron_participant/models/coupon/coupon.dart';
import 'package:diakron_participant/models/store/store.dart';
import 'package:diakron_participant/models/users/participant.dart';
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
    toggleFavorite = Command0(_toggleFavorite);
  }

  final int _couponId;
  // For adding favorites
  String? _userId;
  final ParticipantRepository _participantRepository;

  late Command0 load;
  late Command0 toggleFavorite;

  Coupon? _coupon;
  Coupon? get coupon => _coupon;
  Store? _store;
  Store? get store => _store;
  final _logger = Logger();

  bool _isFavorite = false;
  bool get isFavorite => _isFavorite;

  Future<Result<void>> _load() async {
    try {
      // Get participant Id
      final user = await _participantRepository.getParticipant();
      switch (user) {
        case Ok<Participant>():
          _userId = user.value.id;
        case Error<Participant>():
          return Result.error(user.error);
      }

      // First load coupon
      final result = await _participantRepository.fetchCoupon(
        couponId: _couponId,
      );

      switch (result) {
        case Ok<Coupon>():
          // Store coupon info
          _coupon = result.value;
          _logger.w(_coupon.toString());
        case Error<Coupon>():
          _logger.e(result.error);
      }

      // Check if its a favorite
      final favoriteCoupon = await _participantRepository.favoriteCoupon(
        couponId: _couponId,
        participantId: _userId!,
      );

      switch (favoriteCoupon) {
        case Ok<bool>():
          _isFavorite = favoriteCoupon.value;
        case Error<bool>():
          return Result.error(favoriteCoupon.error);
      }

      // Finally load store
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

  Future<Result<void>> _toggleFavorite() async {
    try {
      if (_isFavorite) {
        final result = await _participantRepository.deleteFavorite(
          couponId: _couponId,
          participantId: _userId!,
        );

        switch (result) {
          case Ok<void>():
            _isFavorite = false;
          case Error<void>():
            _logger.e('Error adding fav ${result.error}');
        }
        return result;
      } else {
        final result = await _participantRepository.addFavorite(
          couponId: _couponId,
          participantId: _userId!,
        );

        switch (result) {
          case Ok<void>():
            _isFavorite = true;
          case Error<void>():
            _logger.e('Error adding fav ${result.error}');
        }
        return result;
      }
    } finally {
      notifyListeners();
    }
  }
}
