import 'package:diakron_participant/data/services/database_service.dart';
import 'package:diakron_participant/models/coupon/coupon.dart';
import 'package:diakron_participant/models/users/participant.dart';
import 'package:diakron_participant/utils/result.dart';
import 'package:logger/logger.dart';

class ParticipantRepository {
  ParticipantRepository({required DatabaseService databaseService})
    : _databaseService = databaseService;

  final DatabaseService _databaseService;
  final _logger = Logger();
  Participant? _cachedParticipant;

  Future<Result<Participant>> getParticipant({
    bool forceRefresh = false,
  }) async {
    if (_cachedParticipant != null && !forceRefresh) {
      _logger.i('Returned cached ${_cachedParticipant.toString()}');
      return Future.value(Result.ok(_cachedParticipant!));
    }
    final result = await _databaseService.getParticipant();
    switch (result) {
      case Ok<Map<String, dynamic>>():
        _cachedParticipant = Participant.fromJson(result.value);

        _logger.i('Returned refreshed ${_cachedParticipant.toString()}');
        return Result.ok(_cachedParticipant!);
      case Error<Map<String, dynamic>>():
        return Result.error(result.error);
    }
  }  

  // THE NEXT CODE IS INTENDED FOR RETRIEVING COUPONS, STORES AND OTHER INFO, IT MUST BE MOVED TO SEPARATE REPOSITORIES

    Future<Result<List<Coupon>>> fetchCoupons() async {
    try {
      final result = await _databaseService.fetchCoupons();
      switch (result) {
        case Ok<List<Map<String, dynamic>>>():
          List<Coupon> centers = (result.value as List)
              .map((item) => Coupon.fromJson(item as Map<String, dynamic>))
              .toList();

          return Result.ok(centers);

        case Error<List<Map<String, dynamic>>>():
          return Result.error(result.error);
      }
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
