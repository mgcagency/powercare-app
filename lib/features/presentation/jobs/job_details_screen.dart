import 'package:flutter/material.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:powercare_flutter/app/theme/text_styles.dart';
import 'package:powercare_flutter/app/widget/custom_appbar.dart';
import '../../../app/widget/custom_text.dart';
import '../../alldata/models/job_list_response.dart';

class JobDetailsScreen extends StatelessWidget {
  final JobModel job;

  const JobDetailsScreen({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    final engineers = <Engineer>[
      if (job.leadEngineer != null) job.leadEngineer!,
      ...?job.otherEngineers
          ?.map((e) => e.user)
          .whereType<Engineer>(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),
      appBar: const CustomAppBar(
        title: "Job Details",
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// HEADER
            _HeaderCard(job: job),

            const SizedBox(height: 16),

            /// JOB INFO
            _SectionCard(
              title: "Job Information",
              child: Column(
                children: [
                  _InfoTile(
                    icon: Icons.location_on_outlined,
                    title: "Location",
                    value: job.jobLocation ?? "-",
                  ),
                  const Divider(),
                  _InfoTile(
                    icon: Icons.calendar_today_outlined,
                    title: "Date",
                    value: job.jobDate ?? "-",
                  ),
                  const Divider(),
                  _InfoTile(
                    icon: Icons.schedule_outlined,
                    title: "Time",
                    value: job.jobTime ?? "-",
                  ),
                  const Divider(),
                  _InfoTile(
                    icon: Icons.phone_outlined,
                    title: "Phone",
                    value: job.mobileNo ?? "-",
                  ),
                  const Divider(),
                  _InfoTile(
                    icon: Icons.email_outlined,
                    title: "Email",
                    value: job.email ?? "-",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// TEAM
            _SectionCard(
              title: "Assigned Team",
              child: Column(
                children: engineers
                    .map(
                      (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _EngineerTile(
                      engineer: e,
                      isLead:
                      job.leadEngineer?.id == e.id,
                    ),
                  ),
                )
                    .toList(),
              ),
            ),

            const SizedBox(height: 16),

            /// DESCRIPTION
            _SectionCard(
              title: "Description",
              child: Text(
                job.jobDescription ??
                    "No description available.",
                style: const TextStyle(
                  height: 1.7,
                  fontSize: 15,
                ),
              ),
            ),

            if (job.images?.isNotEmpty ?? false) ...[
              const SizedBox(height: 16),

              _SectionCard(
                title: "Photos",
                child: SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: job.images!.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(width: 12),
                    itemBuilder: (_, index) {
                      return ClipRRect(
                        borderRadius:
                        BorderRadius.circular(14),
                        child: Image.network(
                          job.images![index]
                              .imageFullLink ??
                              "",
                          width: 130,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],

            if (job.quote != null) ...[
              const SizedBox(height: 16),

              _SectionCard(
                title: "Quote",
                child: Row(
                  children: [
                    Container(
                      padding:
                      const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green
                            .withOpacity(.1),
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.quote?.quoteNumber ??
                                "",
                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                          Text(
                            "£${job.quote?.amountDue ?? "0"}",
                            style:
                            const TextStyle(
                              fontSize: 20,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
class _HeaderCard extends StatelessWidget {
  final JobModel job;

  const _HeaderCard({required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job.jobName ?? "Job",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withOpacity(.1),
                  borderRadius:
                  BorderRadius.circular(30),
                ),
                child: Text(
                  job.jobTypeStatus?.status ??
                      "",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Job #${job.jobNumber}",
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
class _EngineerTile extends StatelessWidget {
  final Engineer engineer;
  final bool isLead;

  const _EngineerTile({
    required this.engineer,
    required this.isLead,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor:
          AppColors.primary.withOpacity(.1),
          child: Text(
            engineer.fullName.isNotEmpty
                ? engineer.fullName[0]
                : "E",
            style: TextStyle(
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                engineer.fullName,
                style: const TextStyle(
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
              if (isLead)
                const Text(
                  "Lead Engineer",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),

        if (isLead)
          const Icon(
            Icons.workspace_premium,
            color: Colors.amber,
          ),
      ],
    );
  }
}