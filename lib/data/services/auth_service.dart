import 'package:diakron_participant/utils/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
final SupabaseClient _supabase = Supabase.instance.client;

  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;
  Session? get currentSession => _supabase.auth.currentSession;
  String? get currentUserId => _supabase.auth.currentUser?.id;
  bool get isLogged => currentSession != null;

  Future<Result<AuthResponse>> signInEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Check user role is participant, maybeSingle() to prevent Postgrest exceptions if row is missing
      final data = await _supabase
          .from('users')
          .select('user_type')
          .eq('id', currentUserId!)
          .maybeSingle();

      // Check the data
      bool isParticipant = data != null && data['user_type'] == 'participant';

      if (!isParticipant) {
        await _supabase.auth.signOut(); // Ensure explicit sign-out
        return Result.error(Exception('Not participant credentials'));
      }

      return Result.ok(result);
    } on AuthException catch (error) {
      return Result.error(Exception(error.message));
    } catch (error) {
      return Result.error(Exception("Unknown error")); // Fixed typo
    }
  }

  // Sign up
  Future<Result<AuthResponse>> sigUpEmailPassword({
    required String email,
    required String password,
    required String username,
    required String surnames,
    required String phoneNumber,
  }) async {
    try {
      final result = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'user_name': username,
          'surnames': surnames,
          'phone_number': phoneNumber,
          // Empieza desactivado porque es solicitud de registro
          'is_active': false,
          // As partiicipant user
          'user_type': 'participant',
          'is_superadmin': false,
        },
      );

      return Result.ok(result);
    } catch (error) {
      return Result.error(Exception(error));
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Send email password recover

  Future<Result<void>> sendEmailforgetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.diakron.participant://reset-password/',
      );
      return Result.ok(null);
    } catch (error) {
      return Result.error(Exception(error));
    }
  }

  // Update user password
  Future<Result<UserResponse>> updatePassword({
    required String password,
  }) async {
    try {
      final result = await _supabase.auth.updateUser(
        UserAttributes(password: password),
      );
      return Result.ok(result);
    } catch (error) {
      return Result.error(Exception(error));
    }
  }

  // get Email
  String? getEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;

    return user?.email;
  }
}
