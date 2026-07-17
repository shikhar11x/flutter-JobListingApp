import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/job_provider.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/job_card.dart';
import '../widgets/state_views.dart';
import 'job_detail_screen.dart';

class JobListTab extends StatefulWidget {
  final JobType jobType;
  const JobListTab({super.key, required this.jobType});

  @override
  State<JobListTab> createState() => _JobListTabState();
}

class _JobListTabState extends State<JobListTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Since ActiveJobProvider and ArchivedJobProvider are distinct types,
  /// we can't pick one with a single `context.watch<T>()` call using a
  /// runtime `widget.jobType` value — generics need to be known at
  /// compile time. So we branch here and return the shared base type.
  JobProvider _watchProvider(BuildContext context) {
    return widget.jobType == JobType.active
        ? context.watch<ActiveJobProvider>()
        : context.watch<ArchivedJobProvider>();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = _watchProvider(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 14),
          child: SearchBarWidget(
            hintText: widget.jobType == JobType.active
                ? 'Search active roles…'
                : 'Search archived roles…',
            onChanged: provider.search,
          ),
        ),
        Expanded(child: _buildBody(provider)),
      ],
    );
  }

  Widget _buildBody(JobProvider provider) {
    switch (provider.state) {
      case ViewState.idle:
      case ViewState.loading:
        return const LoadingView();
      case ViewState.error:
        return ErrorView(
          message: provider.errorMessage,
          onRetry: provider.fetchJobs,
        );
      case ViewState.empty:
        return EmptyView(onRefresh: provider.refresh);
      case ViewState.loaded:
        return RefreshIndicator(
          color: const Color(0xFF6366F1),
          onRefresh: provider.refresh,
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
            itemCount: provider.jobs.length,
            itemBuilder: (context, index) {
              final job = provider.jobs[index];
              return JobCard(
                job: job,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobDetailScreen(job: job),
                    ),
                  );
                },
              );
            },
          ),
        );
    }
  }
}
