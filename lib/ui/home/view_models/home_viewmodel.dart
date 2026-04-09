// home_viewmodel.dart
import 'package:diakron_participant/data/repositories/user/participant_repository.dart';
import 'package:diakron_participant/models/coupon/coupon.dart';
import 'package:diakron_participant/models/users/participant.dart';
import 'package:diakron_participant/utils/command.dart';
import 'package:diakron_participant/utils/result.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/web.dart';


enum CouponSort { none, priceAsc, priceDesc, dateAsc, dateDesc }

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required ParticipantRepository participantRepository})
    : _participantRepository = participantRepository {
    load = Command0(_load)..execute();
  }

  final _logger = Logger();

  final ParticipantRepository _participantRepository;
  late Command0<void> logout;
  late Command0 load;
  int _points = 0;
  int get points => _points;

    // Two list, one for source of truth and second for search and filters
  List<Coupon> _allCoupons = [];   
  List<Coupon> _filteredCoupons = [];

  // The UI should ONLY read from _filteredCoupons
  List<Coupon> get coupons => _filteredCoupons;

  // Checks if there are absolutely zero coupons in the system 
  String _searchQuery = '';

  CouponSort _currentSort = CouponSort.none;
  CouponSort get currentSort => _currentSort;

  // We consider it "searching" if the text is not empty 
  // OR if a specific sort/filter (other than default) is applied.
 bool get isSearching => _searchQuery.isNotEmpty || _currentSort != CouponSort.none;


  Future<Result<void>> _load() async {
    try {
      // First fetch participant user (for number of points)
      final participantResult = await _participantRepository.getParticipant();
      switch (participantResult) {
        case Ok<Participant>():
          _points = participantResult.value.points;
        case Error<Participant>():
          return Result.error(participantResult.error);
      }

      // Fetch list of coupons
           // Fetch Coupons
      final result = await _participantRepository.fetchCoupons();

      switch (result) {
        case Ok<List<Coupon>>():
          _allCoupons = result.value;
          _applyFilters();
          // Removed map((e) => e.toJson()).toList()
          // Serializing a whole list to JSON purely for a debug log is a massive CPU waste.
          _logger.d('Loaded ${_allCoupons.length} Coupons');

        case Error<List<Coupon>>():
          _logger.w('Failed to load Coupons ${result.error}');
      }


      return Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      notifyListeners();
    }
  }


  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void updateSort(CouponSort sort) {
    _currentSort = sort;
    _applyFilters();
  }

  void _applyFilters() {
    // 1. Apply Text Search (by title)
    var temp = _allCoupons.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // 2. Apply Sort Filters
    switch (_currentSort) {
      case CouponSort.priceAsc:
        temp.sort((a, b) => a.pricePoints.compareTo(b.pricePoints));
        break;
      case CouponSort.priceDesc:
        temp.sort((a, b) => b.pricePoints.compareTo(a.pricePoints));
        break;
      case CouponSort.dateAsc:
        temp.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
        break;
      case CouponSort.dateDesc:
        temp.sort((a, b) => b.expirationDate.compareTo(a.expirationDate));
        break;
      case CouponSort.none:
      default:
        // Optional: Default sort (e.g., newest first based on ID or creation date)
        break;
    }

    _filteredCoupons = temp;
    notifyListeners();
  }
  // Function to clean everything
  void clearFilters() {
    _searchQuery = "";
    _currentSort = CouponSort.none;
    _applyFilters();
  }
}
