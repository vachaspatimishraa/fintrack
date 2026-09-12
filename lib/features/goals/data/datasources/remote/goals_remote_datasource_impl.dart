import 'package:fintrack/features/goals/domain/repositories/goals_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoalsRemoteDatasourceImpl implements GoalsRemoteDatasource {
  final SupabaseClient supabase;

  GoalsRemoteDatasourceImpl(this.supabase);

  @override
  Future<void> uploadGoals() async {
    // Logic to upload goals to Supabase
  }

  @override
  Future<void> downloadGoals() async {
    // Logic to download goals from Supabase
  }

  @override
  Future<void> synchronize() async {
    // Bidirectional sync logic
  }
}
