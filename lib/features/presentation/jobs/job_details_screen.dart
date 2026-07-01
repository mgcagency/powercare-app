import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:powercare_flutter/app/theme/text_styles.dart';
import 'package:powercare_flutter/app/widget/custom_appbar.dart';
import 'package:powercare_flutter/app/widget/custom_text.dart';
import 'package:powercare_flutter/core/navigation/app_navigator.dart';
import 'package:powercare_flutter/features/presentation/jobs/job_sheet_screen.dart';
import 'package:powercare_flutter/features/presentation/timelog/TimeSheetScreen.dart';
import '../../../app/widget/helper.dart';
import '../../alldata/api_repository/job_repository.dart';
import '../../alldata/models/job_list_response.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Material/material_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../webview_screen/web_view_screen.dart';

class JobDetailsScreen extends StatefulWidget {
  final JobModel job;
  const JobDetailsScreen({super.key, required this.job});
  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool _isUploading = false;
  bool _isDeleting = false;
  late final JobModel job = widget.job;
  final JobRepository _repository = JobRepository();
  bool _isLoadingDetails = false;
  int deleteId = -1;
  JobModel? _detailedJob;

  @override
  void initState() {
    super.initState();
    _fetchJobDetails();
  }

  Future<void> _deleteImage(int imageId) async {
    setState(() => _isDeleting = true);
    deleteId = imageId; // Reuse upload loader or create _isDeleting
    try {
      final response = await _repository.deleteJobImage(imageId);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image deleted successfully")),
        );
        _fetchJobDetails() ; // Refresh the UI
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Delete failed: ${e.toString()}")));
    } finally {
      setState(() {
        _isDeleting = false;
        deleteId = -1;
      });
    }
  }
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image != null) {
      _uploadImage(image.path);
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primary,
                ),
                title: CustomText(
                  "Take a Photo",
                  style: AppTextStyles.bodyMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
              ),
              title: CustomText(
                "Choose from Gallery",
                style: AppTextStyles.bodyMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadImage(String path) async {
    setState(() => _isUploading = true);

    try {
      final response = await _repository.uploadJobImage(
        widget.job.id.toString(),
        path,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image uploaded successfully")),
        );
        _fetchJobDetails(); // Refresh details after upload
        // Note: You might want to refresh the job data here to show the new image
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload failed: ${e.toString()}")));
    } finally {
      setState(() => _isUploading = false);
    }
  }
  Future<void> _fetchJobDetails() async {
    setState(() => _isLoadingDetails = true);
    try {
      final response = await _repository.getJobDetails(
        widget.job.id.toString(),
      );
      if (response.success == true && response.jobDetails != null) {
        setState(() {
          _detailedJob = response.jobDetails;
        });
      }
    } catch (e) {
      debugPrint("Error fetching job details: $e");
    } finally {
      setState(() => _isLoadingDetails = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    final job = _detailedJob;
    List<Engineer> engineers = [];
    if (job != null) {
      engineers = <Engineer>[
        if (job.leadEngineer != null) job.leadEngineer!,
        ...?job.otherEngineers?.map((e) => e.user).whereType<Engineer>(),
      ];
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: const CustomAppBar(title: "Job Details"),
      body: job == null
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  // ── HERO CARD ──────────────────────────────────────────
                  _HeroCard(job: job),
                  const SizedBox(height: 12),

                  // ── JOB INFORMATION ───────────────────────────────────
                  SectionCard(
                    icon: Icons.info_outline_rounded,
                    title: "Job Information",
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          label: "Location",
                          value: job.jobLocation ?? "-",
                        ),
                        _InfoRow(
                          icon: Icons.phone_outlined,
                          label: "Phone",
                          value: job.mobileNo ?? "-",
                        ),
                        _InfoRow(
                          icon: Icons.email_outlined,
                          label: "Email",
                          value: job.email ?? "-",
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── ASSIGNED TEAM ─────────────────────────────────────
                  SectionCard(
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
                  SectionCard(
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
                  const SizedBox(height: 12),
                  SectionCard(
                    icon: Icons.photo_library_outlined,
                    title: "Photos",
                    child: SizedBox(
                      height: 105,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: (job.images?.length ?? 0) + 1,
                        itemBuilder: (_, i) {
                          // Add Photo Button
                          if (i == 0) {
                            return GestureDetector(
                              onTap: () {
                                if (!_isUploading) _showPickerOptions();
                              },
                              child: Container(
                                width: 90,
                                margin: const EdgeInsets.only(
                                  top: 10,
                                  right: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(.05),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(.3),
                                    width: 1.2,
                                  ),
                                ),
                                child: _isUploading
                                    ? Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primary,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withOpacity(.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.add_a_photo_outlined,
                                              color: AppColors.primary,
                                              size: 22,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          CustomText(
                                            "Add",
                                            style: AppTextStyles.bodyExtraSmall
                                                .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                              ),
                            );
                          }

                          final image = job.images![i - 1];

                          return Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 10),
                            child: Stack(
                              children: [
                                // THE PHOTO
                                Positioned.fill(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                      top: 10,
                                      right: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.network(
                                        image.imageFullLink ?? "",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_isDeleting && deleteId == image.id)
                                  Positioned.fill(
                                    child: Container(
                                      color: Colors.black.withOpacity(0.5),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                // DELETE (CLOSE) ICON
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _deleteImage(image.id!),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.primary,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.25,
                                            ),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // ── DOCUMENTS SECTION ──────────────────────────────────
                  if (job.documentFullLink != null &&
                      job.documentFullLink!.contains('/upload/')) ...[
                    const SizedBox(height: 12),
                    SectionCard(
                      icon: Icons.insert_drive_file_outlined,
                      title: "Job Document",
                      child: _DocumentRow(
                        title: "Main Job Document",
                        url: job.documentFullLink!,
                        isLast: true,
                      ),
                    ),
                  ],

                  // ── JOB SHEETS SECTION ─────────────────────────────────
                  if (job.jobSheets?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 12),
                    SectionCard(
                      isJobSheet: true,
                      icon: Icons.assignment_outlined,
                      title: "Job Sheets",
                      child: Column(
                        children: List.generate(job.jobSheets!.length, (index) {
                          final sheet = job.jobSheets![index];
                          return _DocumentRow(
                            title:
                                sheet.description ?? "Job Sheet ${index + 1}",
                            url: sheet.documentFullLink ?? "",
                            isLast: index == job.jobSheets!.length - 1,
                            isJobSheet: true,
                          );
                        }),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  SectionCard(
                    icon: Icons.settings_suggest_outlined,
                    title: "Job Management",
                    child: Column(
                      children: [

                        _actionTile(
                          icon: Icons.more_time_rounded,
                          title: "Add Timesheet",
                          subtitle: "Track engineer hours",
                          onTap: () {
                            AppNavigator.pushAndRemoveAll(TimeSheetScreen (jobId: job!.id.toString(),

                            ));

                          },
                        ),
                        _actionTile(
                          icon: Icons.local_shipping_outlined,
                          title: "Plant Order",
                          subtitle: "Manage equipment requests",
                          onTap: () {
                            AppNavigator.pushAndRemoveAll(const MaterialScreen());

    },

                        ),
                        _actionTile(
                          icon: Icons.inventory_2_outlined,
                          title: "Order Material",
                          subtitle: "Request site materials",
                          onTap: () {
                            AppNavigator.pushAndRemoveAll(const MaterialScreen());

                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION BUTTON — Grid tile for management tasks
// ─────────────────────────────────────────────────────────────────────────────
Widget _actionTile({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withOpacity(.6)),
          ),
          child: Row(
            children: [
              Container(
                height: 35,
                width: 35,

                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    CustomText(subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    ),
  );
} // ─────────────────────────────────────────────────────────────────────────────

// DOCUMENT ROW  —  icon | title | view button
// ─────────────────────────────────────────────────────────────────────────────
class _DocumentRow extends StatelessWidget {
  final String title;
  final String url;
  final bool isLast;
  final bool isJobSheet;

  const _DocumentRow({
    required this.title,
    required this.url,
    this.isLast = false,
    this.isJobSheet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF2F2F2), width: 0.5),
              ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.file_copy_outlined,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomText(
              title,
              style: AppTextStyles.bodySmall.copyWith(
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── DOWNLOAD ICON ──
              GestureDetector(
                onTap: () async {
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.file_download_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // ── VIEW ICON ──
              GestureDetector(
                onTap: () async {
                  if (!isJobSheet) {
                    AppNavigator.push(
                      WebViewScreen(
                        url: url,
                        title: title, // This passes the document title
                      ),
                    );
                  } else {
                    AppNavigator.push(JobSheetScreen());
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (isJobSheet) const SizedBox(width: 10),
              // ── VIEW ICON ──
              if (isJobSheet)
                GestureDetector(
                  onTap: () async {
                    AppNavigator.push(JobSheetScreen());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final JobModel job;
  const _HeroCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final statusColor = Color(
      int.parse(
        job.jobTypeStatus?.colorCode?.replaceAll("#", "0xFF") ?? "0xFF000000",
      ),
    );

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 4,
                    ),
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
                style: AppTextStyles.caption.copyWith(
                  color: const Color(0xFF999999),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                children: [
                  _MiniChip(
                    icon: Icons.calendar_month_rounded,
                    label: job.jobDate ?? "-",
                  ),
                  _MiniChip(
                    icon: Icons.access_time_rounded,
                    label: job.jobTime ?? "-",
                  ),
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
            style: AppTextStyles.caption.copyWith(
              color: const Color(0xFF444444),
            ),
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

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF2F2F2), width: 0.5),
              ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 8),

          Flexible(
            child: CustomText(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.bodySmall.copyWith(),
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

  const _EngineerRow({
    required this.engineer,
    required this.isLead,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final initial = engineer.fullName.isNotEmpty
        ? engineer.fullName[0].toUpperCase()
        : "E";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF2F2F2), width: 0.5),
              ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15, // Half of your 30px width/height
            backgroundColor: isLead
                ? const Color(0xFF111111)
                : AppColors.primary,
            backgroundImage:
                (engineer.userImage != null && engineer.userImage!.isNotEmpty)
                ? NetworkImage(engineer.userImage!)
                : null,
            child: (engineer.userImage == null || engineer.userImage!.isEmpty)
                ? CustomText(
                    initial,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12, // Adjusted for smaller circular area
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  engineer.fullName,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111111),
                  ),
                ),
                CustomText(
                  isLead ? "Lead Engineer" : "Engineer",
                  style: AppTextStyles.bodyExtraSmall.copyWith(
                    color: const Color(0xFF999999),
                  ),
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
                  const Icon(
                    Icons.workspace_premium,
                    size: 13,
                    color: Color(0xFFD4900A),
                  ),
                  const SizedBox(width: 3),
                  CustomText(
                    "Lead",
                    style: AppTextStyles.bodyExtraSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFB87A00),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
