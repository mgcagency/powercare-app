import 'package:flutter/material.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:powercare_flutter/app/theme/text_styles.dart';
import 'package:powercare_flutter/core/navigation/app_navigator.dart';
import '../../../app/widget/custom_appbar.dart';
import '../../../app/widget/custom_text.dart';
import '../../alldata/api_repository/job_repository.dart';
import '../../alldata/models/UserModel.dart';
import '../../alldata/models/job_list_response.dart';
import 'job_details_screen.dart';

class JobListScreen extends StatefulWidget {

  final bool showAppBar;
  final bool isArchive;

  const JobListScreen({
    super.key,
    this.showAppBar = true,
    this.isArchive = false,

  });

  @override
  State<JobListScreen> createState() =>
      _JobListScreenState();
}
/*class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}*/

class _JobListScreenState extends State<JobListScreen> {
  // Theme and Repository
  final Color primaryColor = AppColors.primary;
  final Color primaryLightColor = AppColors.primaryLightbubbleBack;
  final JobRepository _repository = JobRepository();
  bool isArchive=false;
  // State Variables
  int selected = 0; // 0 for All Jobs, 1 for My Jobs
  List<JobModel> jobs = [];
  bool isLoading = true; // Initial full-screen loading
  String? errorMessage;
  final Set<int> expandedJobIds = {};

  // Pagination Variables
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isFetchingMore = false;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    fetchJobs();

    isArchive = widget.isArchive;

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!_isFetchingMore && _hasMoreData && !isLoading) {
          fetchJobs();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchJobs({bool isRefresh = false}) async {

    if (isRefresh) {
      setState(() {
        _currentPage = 1;
        _hasMoreData = true;
        isLoading = true;
      });
    }

    if (!_hasMoreData || _isFetchingMore) return;

    setState(() {
      if (_currentPage == 1) {
        isLoading = true;
      } else {
        _isFetchingMore = true;
      }
      errorMessage = null;
    });
    try {

      JobListResponse response;

      if (isArchive) {

        response = await _repository.getArchivedJobs({
          "specific_date": "",
        });

      } else {

        response = await _repository.getJobs({
          "page": _currentPage,
          "my_job": selected,
          "job_date": "",
        });

      }

      if (response.statusCode == 200) {

        final List<JobModel> newItems =
            response.job?.data ?? [];

        setState(() {

          if (_currentPage == 1) {
            jobs = newItems;
          } else {
            jobs.addAll(newItems);
          }

          _hasMoreData =
              _currentPage < (response.job?.lastPage ?? 1);

          if (_hasMoreData) {
            _currentPage++;
          }

          isLoading = false;
          _isFetchingMore = false;
        });
      }

    } catch (e) {

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
        _isFetchingMore = false;
      });

    }
/*    try {
      final response = await _repository.getJobs({
        'page': _currentPage,
        'my_job': selected,
        'job_date': '',
      });

      if (response.statusCode == 200) {
        final List<JobModel> newItems = response.job?.data ?? [];

        setState(() {
          if (_currentPage == 1) {
            jobs = newItems;
          } else {
            jobs.addAll(newItems);
          }

          _hasMoreData = _currentPage < (response.job?.lastPage ?? 1);
          if (_hasMoreData) _currentPage++;

          isLoading = false;
          _isFetchingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
        _isFetchingMore = false;
      });
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? CustomAppBar(
        title:  isArchive
            ? "Archived Jobs"
            : "Jobs",
      )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // ---------------- FILTER BAR ----------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tabWidth = constraints.maxWidth / 2;

                  return Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        left: selected * tabWidth + (selected==0?4:0),
                        top: 4,
                        bottom: 4,
                        child: Container(
                          width: tabWidth-4,

                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Row(
                        children: [
                          _tabButton("All Jobs", 0),
                          _tabButton("My Jobs", 1),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

            const SizedBox(height: 12),

            // ---------------- LIST ----------------
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                  : RefreshIndicator(
                      onRefresh: () => fetchJobs(isRefresh: true),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: jobs.length + (_isFetchingMore ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i == jobs.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: primaryColor,
                                ),
                              ),
                            );
                          }
                          final job = jobs[i];
                          return TweenAnimationBuilder(
                            duration: Duration(milliseconds: 300 + (i * 80)),
                            tween: Tween<double>(begin: 0, end: 1),
                            curve: Curves.easeOut,
                            builder: (context, double value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(opacity: value, child: child),
                              );
                            },
                            child: _ticketCard(job, i),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- CHIP ----------------
  Widget _chip(String text, int index) {
    final active = selected == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (selected != index) {
            setState(() => selected = index);
            fetchJobs(isRefresh: true);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: CustomText(
              text,
              style: AppTextStyles.button.copyWith(
                color: active ? Colors.white : primaryColor.withOpacity(0.8),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _tabButton(String text, int index) {
    final active = selected == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () {
          if (selected != index) {
            setState(() => selected = index);
            fetchJobs(isRefresh: true);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: AppTextStyles.button.copyWith(
              color: active ? Colors.white : Colors.black87,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }
  // ---------------- JOB CARD ----------------
  Widget _ticketCard(JobModel job, int index) {
    final statusColor = Color(
      int.parse(
        job.jobTypeStatus?.colorCode?.replaceAll("#", "0xFF") ?? "0xFF000000",
      ),
    );
    final isExpanded = expandedJobIds.contains(job.id);
    List<UserModel> assignedEngineers = [
      if (job.leadEngineer != null) job.leadEngineer!,
      ...?job.otherEngineers
          ?.map((e) => e.user)
          .whereType<UserModel>()
          .where((e) => e.id != job.leadEngineer?.id),
    ];
    return GestureDetector(
        onTap: (){
        AppNavigator.push(JobDetailsScreen(job: job));
        },
        child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        margin: const EdgeInsets.only(left: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomText(
                    job.jobName ?? "",
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: CustomText(
                    job.jobTypeStatus?.status ?? "Unknown",
                    style: AppTextStyles.bodyExtraSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CustomText(
              job.jobDescription ?? "No description",
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _info(
                    Icons.pin_drop_rounded,
                    job.jobLocation ?? "No location",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 8,
              children: [
                _info(Icons.phone, job.mobileNo ?? "N/A"),
                _info(Icons.calendar_month, job.jobDate ?? "N/A"),
                _info(Icons.access_time, job.jobTime ?? "N/A"),
              ],
            ),
            const SizedBox(height: 12),
            if(assignedEngineers.isNotEmpty)
            GestureDetector(
              onTap: () => toggleEngineers(job.id!),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  children: [
                    CustomText(
                      "Assigned Engineers",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textColor,
                      ),
                    ),
                    const Spacer(),
                    Stack(
                      children: [
                        Positioned(
                          left: 0,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: primaryColor,
                            backgroundImage:
                                job.leadEngineer?.userImage != null &&
                                    job.leadEngineer?.userImage != ""
                                ? NetworkImage(
                                    job.leadEngineer!.userImage ?? "",
                                  )
                                : null,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 15),
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: primaryLightColor,

                            child: CustomText(
                              "+${(job.otherEngineers ?? []).length}",
                              style: AppTextStyles.bodyExtraSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(Icons.keyboard_arrow_down, size: 20),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  axis: Axis.vertical,
                  axisAlignment: -1.0, // expand downward from top
                  child: child,
                );
              },
              child: isExpanded
                  ? Container(
                      key: const ValueKey('expanded'),
                      padding: const EdgeInsets.only(top: 12),
                      child: _engineers(assignedEngineers),
                    )
                  : const SizedBox(key: ValueKey('collapsed')),
            ),
          ],
        ),
      ),
    ));
  }

  void toggleEngineers(int jobId) {
    setState(() {
      if (expandedJobIds.contains(jobId)) {
        expandedJobIds.remove(jobId);
      } else {
        expandedJobIds.add(jobId);
      }
    });
  }

  Widget _engineers(List<UserModel> list) {
    if (list.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: list.map((engineer) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.03),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: primaryColor.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: primaryColor,
                backgroundImage:
                    engineer.userImage != null && engineer.userImage!.isNotEmpty
                    ? NetworkImage(engineer.userImage!)
                    : null,
                child: engineer.userImage == null || engineer.userImage!.isEmpty
                    ? CustomText(
                        engineer.fullName.isNotEmpty
                            ? engineer.fullName[0].toUpperCase()
                            : "?",
                        style: AppTextStyles.bodyExtraSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              CustomText(
                engineer.fullName,
                style: AppTextStyles.bodyExtraSmall.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _info(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: primaryColor),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
