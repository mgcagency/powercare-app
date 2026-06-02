import 'package:flutter/material.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:powercare_flutter/app/theme/text_styles.dart';
import 'package:powercare_flutter/app/widget/custom_appbar.dart';
import 'package:powercare_flutter/app/widget/custom_text.dart';
import '../../alldata/models/job_list_response.dart';

class JobDetailsScreen extends StatelessWidget {
  final JobModel job;
  const JobDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final engineers = <Engineer>[
      if (job.leadEngineer != null) job.leadEngineer!,
      ...?job.otherEngineers?.map((e) => e.user).whereType<Engineer>(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: const CustomAppBar(title: "Job Details"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // ── HERO CARD ──────────────────────────────────────────
            _HeroCard(job: job),
            const SizedBox(height: 12),

            // ── JOB INFORMATION ───────────────────────────────────
            _SectionCard(
              icon: Icons.info_outline_rounded,
              title: "Job Information",
              child: Column(
                children: [
                  _InfoRow(icon: Icons.location_on_outlined, label: "Location", value: job.jobLocation ?? "-"),
                  _InfoRow(icon: Icons.phone_outlined, label: "Phone", value: job.mobileNo ?? "-"),
                  _InfoRow(icon: Icons.email_outlined, label: "Email", value: job.email ?? "-", isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── ASSIGNED TEAM ─────────────────────────────────────
            _SectionCard(
              icon: Icons.group_outlined,
              title: "Assigned Team",
              child: Column(
                children: List.generate(engineers.length, (i) {
                  final e = engineers[i];
                  return _EngineerRow(
                    engineer: e,
                    isLead: job.leadEngineer?.id == e.id,
                    isLast: i == engineers.length - 1,
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),

            // ── DESCRIPTION ───────────────────────────────────────
            _SectionCard(
              icon: Icons.description_outlined,
              title: "Description",
              child: CustomText(
                job.jobDescription ?? "No description available.",
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF555555),
                  height: 1.7,
                ),
              ),
            ),

            // ── PHOTOS ────────────────────────────────────────────
            if (job.images?.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              _SectionCard(
                icon: Icons.photo_library_outlined,
                title: "Photos",
                child: SizedBox(
                  height: 95,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: job.images!.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        job.images![i].imageFullLink ?? "",
                        width: 115,
                        height: 95,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],

            // ── QUOTE ─────────────────────────────────────────────
            if (job.quote != null) ...[
              const SizedBox(height: 12),
              _SectionCard(
                icon: Icons.receipt_long_outlined,
                title: "Quote",
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF6F1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.receipt_long, color: Color(0xFF1A8A45), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          job.quote?.quoteNumber ?? "",
                          style: AppTextStyles.caption.copyWith(color: const Color(0xFF888888)),
                        ),
                        const SizedBox(height: 2),
                        CustomText(
                          "£${job.quote?.amountDue ?? "0"}",
                          style: AppTextStyles.headline3.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111111),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final JobModel job;
  const _HeroCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final statusColor = Color(int.parse(job.jobTypeStatus?.colorCode?.replaceAll("#", "0xFF") ?? "0xFF000000"));

    return Container(
      padding: const EdgeInsets.only(top: 4, left: 1, right: 1, bottom: 1),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomText(
                      job.jobName ?? "Job",
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111111),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3EE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: CustomText(
                      job.jobTypeStatus?.status ?? "",
                      style: AppTextStyles.bodyExtraSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFCC4400),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              CustomText(
                "Job #${job.jobNumber}",
                style: AppTextStyles.caption.copyWith(color: const Color(0xFF999999)),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                children: [
                  _MiniChip(icon: Icons.calendar_month_rounded, label: job.jobDate ?? "-"),
                  _MiniChip(icon: Icons.access_time_rounded, label: job.jobTime ?? "-"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MiniChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 5),
          CustomText(
            label,
            style: AppTextStyles.caption.copyWith(color: const Color(0xFF444444)),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _SectionCard({required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEBEBEB), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 0),
            child: Row(
              children: [
                Icon(icon, size: 17, color: AppColors.primary),
                const SizedBox(width: 7),
                CustomText(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111111),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({required this.icon, required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFF2F2F2), width: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 8),

          Flexible(
            child: CustomText(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.bodySmall.copyWith(

              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EngineerRow extends StatelessWidget {
  final Engineer engineer;
  final bool isLead;
  final bool isLast;

  const _EngineerRow({required this.engineer, required this.isLead, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final initial = engineer.fullName.isNotEmpty ? engineer.fullName[0].toUpperCase() : "E";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFF2F2F2), width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isLead ? const Color(0xFF111111) : AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomText(
                initial,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  engineer.fullName,
                  style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF111111)),
                ),
                CustomText(
                  isLead ? "Lead Engineer" : "Engineer",
                  style: AppTextStyles.bodyExtraSmall.copyWith(color: const Color(0xFF999999)),
                ),
              ],
            ),
          ),
          if (isLead)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBE6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.workspace_premium, size: 13, color: Color(0xFFD4900A)),
                  const SizedBox(width: 3),
                  CustomText(
                    "Lead",
                    style: AppTextStyles.bodyExtraSmall.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFFB87A00)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}