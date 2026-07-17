import 'package:flutter/foundation.dart';
import '../models/job_model.dart';
import '../services/api_service.dart';

enum ViewState { idle, loading, loaded, error, empty }

class JobProvider extends ChangeNotifier {
  final ApiService _apiService;
  final JobType jobType;

  JobProvider(this._apiService, this.jobType);

  List<Job> _allJobs = [];
  List<Job> _filteredJobs = [];
  ViewState _state = ViewState.idle;
  String _errorMessage = '';
  String _searchQuery = '';

  List<Job> get jobs => _filteredJobs;
  ViewState get state => _state;
  String get errorMessage => _errorMessage;

  Future<void> fetchJobs() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      final jobs = await _apiService.fetchJobs(jobType);
      _allJobs = jobs;
      _applyFilter();
      _state = _filteredJobs.isEmpty ? ViewState.empty : ViewState.loaded;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = ViewState.error;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      _state = ViewState.error;
    }
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    _state = _filteredJobs.isEmpty ? ViewState.empty : ViewState.loaded;
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.trim().isEmpty) {
      _filteredJobs = List.from(_allJobs);
      return;
    }
    final q = _searchQuery.toLowerCase();
    _filteredJobs = _allJobs.where((job) {
      return job.name.toLowerCase().contains(q) ||
          job.companyName.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> refresh() => fetchJobs();
}

/// Distinct type so `provider` package can tell this apart from
/// [ArchivedJobProvider] in the widget tree. Without this, both
/// active/archived providers would register as plain `JobProvider`
/// and any `context.watch<JobProvider>()` would only ever resolve
/// to whichever one was registered last.
class ActiveJobProvider extends JobProvider {
  ActiveJobProvider(ApiService apiService)
      : super(apiService, JobType.active);
}

/// See [ActiveJobProvider] — same reasoning, for archived roles.
class ArchivedJobProvider extends JobProvider {
  ArchivedJobProvider(ApiService apiService)
      : super(apiService, JobType.archived);
}