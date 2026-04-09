import 'package:diakron_participant/utils/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
final SupabaseClient _supabase = Supabase.instance.client;
    Future<Result<Map<String, dynamic>>> getParticipant() async {
    try {
      if (_supabase.auth.currentUser != null) {
        final participant = await _supabase
            .from('full_participants')
            .select()
            .eq('id', _supabase.auth.currentUser!.id)
            .single();
        return Result.ok(participant);
      }
      return Result.error(Exception('Null user'));
    } on Exception catch (error) {
      return Result.error(error);
    }
  }


   Future<Result<List<Map<String, dynamic>>>> fetchCoupons(   
  ) async {
    try {
      // Retrieve MAX 100 records
      final result = await _supabase
          .from('coupons')
          .select()
          .limit(100);
      return Result.ok(result);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }
  
}