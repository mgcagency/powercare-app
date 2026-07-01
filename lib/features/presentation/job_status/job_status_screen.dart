import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:powercare_flutter/app/theme/text_styles.dart';
import 'package:powercare_flutter/app/widget/custom_appbar.dart';
import 'package:powercare_flutter/app/widget/custom_text.dart';
import 'package:powercare_flutter/app/widget/custom_textfield.dart';

import '../../../app/widget/helper.dart';
import '../../alldata/api_repository/job_repository.dart';
import '../../alldata/models/job_list_response.dart';
import '../../alldata/models/job_type_status_response.dart';

class JobStatusScreen extends StatefulWidget {

  final bool showAppBar;

  const JobStatusScreen({
    super.key,
    this.showAppBar = true,   bool isArchive=false,

  });

  @override
  State<JobStatusScreen> createState() =>
      _JobStatusScreenState();
}
/*class JobStatusScreen extends StatefulWidget {
  const JobStatusScreen({super.key});

  @override
  State<JobStatusScreen> createState() => _JobStatusScreenState();
}*/

class _JobStatusScreenState extends State<JobStatusScreen> {
  bool _isUploading = false;
  bool _isLoadingJobs = false;
  bool _isLoadingStatuses = false;
  bool _isDeleting = false;
  int deleteId = -1;

  final JobRepository _repository = JobRepository();

  // Job Data
  List<JobModel> _jobsList = [];
  JobModel? _selectedJobModel;

  // Status Data
  List<JobTypeStatus> _statusList = [];
  JobTypeStatus? _selectedStatusModel;

  final TextEditingController _explanationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMyJobs();
    _fetchJobTypeStatuses();
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
        _fetchMyJobs(showLoading: false); // Refresh the UI
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

  Future<void> _fetchMyJobs({bool showLoading = true}) async {
    if(showLoading)
    setState(() => _isLoadingJobs = true);
    try {
      final response = await _repository.getJobs({
        "my_job": 1,
        "per_page": 100,
      });

      if (response.success == true) {
        setState(() {
          _jobsList = response.jobLists ?? response.jobListData ?? response.job?.data ?? [];
          if (_jobsList.isNotEmpty) {
            if(_selectedJobModel !=null){
              _selectedJobModel = _jobsList.firstWhere((e) => e.id == _selectedJobModel?.id);
            }else {
              _selectedJobModel = _jobsList.first;
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching jobs: $e");
    } finally {
      if(showLoading)
      setState(() => _isLoadingJobs = false);
    }
  }

  Future<void> _fetchJobTypeStatuses() async {
    setState(() => _isLoadingStatuses = true);
    try {
      final response = await _repository.getJobTypeStatusList(parameters: {'paginate':'1'});
      if (response.success == true) {
        setState(() {
          _statusList = response?.jobTypeStatusLists ?? [];
          if (_statusList.isNotEmpty) {
            _selectedStatusModel = _statusList.first;
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching status list: $e");
    } finally {
      setState(() => _isLoadingStatuses = false);
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
    if (_selectedJobModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a job first")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final response = await _repository.uploadJobImage(
        _selectedJobModel!.id.toString(),
        path,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image uploaded successfully")),
        );
        _fetchMyJobs(showLoading: false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: ${e.toString()}")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(   appBar: widget.showAppBar
        ? const CustomAppBar(
      title: "Job Status",
    )
        : null,
      body: (_isLoadingJobs || _isLoadingStatuses)
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: () async {
                await _fetchMyJobs();
                await _fetchJobTypeStatuses();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── SELECT JOB ──
                    _buildLabel("Select Job"),
                    GestureDetector(
                      onTap: () {
                        showJobBottomSheet();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [

                            Expanded(
                              child: CustomText(
                                _selectedJobModel == null
                                    ? "Select Job"
                                    : _selectedJobModel!.jobName ?? "",
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: _selectedJobModel == null
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            ),

                            Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
     /*               _buildDropdownContainer(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<JobModel>(
                          value: _selectedJobModel,
                          isExpanded: true,
                          hint: CustomText("Select a job",
                              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey)),
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                          items: _jobsList.map((JobModel job) {
                            return DropdownMenuItem<JobModel>(
                              value: job,
                              child: CustomText(job.jobName ?? "No Name",
                                  style: AppTextStyles.bodyMedium),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedJobModel = val),
                        ),
                      ),
                    ),*/

                    const SizedBox(height: 20),

                    // ── JOB STATUS ──
                    _buildLabel("Job Status"),
                    GestureDetector(
                      onTap: () {
                        showStatusBottomSheet();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomText(
                                _selectedStatusModel == null
                                    ? "Select Status"
                                    : _selectedStatusModel!.status ?? "",
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: _selectedStatusModel == null
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),    /*                _buildDropdownContainer(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<JobTypeStatus>(
                          value: _selectedStatusModel,
                          isExpanded: true,
                          hint: CustomText("Select status",
                              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey)),
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                          items: _statusList.map((JobTypeStatus status) {
                            return DropdownMenuItem<JobTypeStatus>(
                              value: status,
                              child: CustomText(status.status ?? "No Status",
                                  style: AppTextStyles.bodyMedium),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedStatusModel = val),
                        ),
                      ),
                    ),*/

                    const SizedBox(height: 20),

                    // ── CLIENT QUESTIONS ──
                    _buildLabel("Does the client require any other work or questions?"),
              /*      CustomTextField(
                      controller: _explanationController,
                      hintText: "Explain here...",
                      maxLines: 5,
                    ),*/
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: CustomTextField(
                        controller: _explanationController,
                        hintText: "Explain here...",
                        maxLines: 5,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // ── UPLOAD PHOTOS ──
                    SectionCard(
                      icon: Icons.photo_library_outlined,
                      title: "Photos",
                      child: SizedBox(
                        height: 105,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: (_selectedJobModel?.images?.length ?? 0) + 1,
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

                            final image = _selectedJobModel?.images![i - 1];

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
                                          image?.imageFullLink ?? "",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_isDeleting && deleteId == image?.id)
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
                                      onTap: () => _deleteImage(image?.id ?? -1),
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

                    const SizedBox(height: 40),

                    // ── ACTION BUTTONS ──
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildSecondaryButton("Back", () => Navigator.pop(context)),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          flex: 3,
                          child: _buildPrimaryButton("Save & Next", () {
                            // Handle logic
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
  void showJobBottomSheet() {

    showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.white,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),

      builder: (context) {

        return SizedBox(

          height: MediaQuery.of(context).size.height * 0.60,

          child: Column(

            children: [

              const SizedBox(height: 15),

              const Text(
                "Select Job",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Divider(),

              Expanded(

                child: ListView.builder(

                  itemCount: _jobsList.length,

                  itemBuilder: (_, index) {

                    final job = _jobsList[index];

                    return ListTile(

                      title: CustomText(
                        job.jobName ?? "No Name",
                        style: AppTextStyles.bodyMedium,
                      ),

                      onTap: () {

                        setState(() {
                          _selectedJobModel = job;
                        });

                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }  void showStatusBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const SizedBox(height: 15),

            const Text(
              "Select Status",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Divider(),

            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _statusList.length,
                itemBuilder: (_, index) {

                  final status =
                  _statusList[index];

                  return ListTile(
                    title: CustomText(
                      status.status ?? "",
                      style: AppTextStyles.bodyMedium,
                    ),

                    onTap: () {

                      setState(() {
                        _selectedStatusModel =
                            status;
                      });

                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
  // Helper for Labels
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: CustomText(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Helper for Custom Dropdown look
  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }

  // Helper for the Custom Photo Picker design
  Widget _buildUploadWidget() {
    return GestureDetector(
      onTap: () {
        if (!_isUploading) _showPickerOptions();
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: _isUploading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : CustomText(
                      "Upload",
                      style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 13),
                    ),
            ),
            const SizedBox(width: 15),
            CustomText(
              "Select Photos",
              style: AppTextStyles.bodySmall.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for Grey Button
  Widget _buildSecondaryButton(String title, VoidCallback onTap) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF707070),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: onTap,
        child: CustomText(title, style: AppTextStyles.button.copyWith(color: Colors.white)),
      ),
    );
  }

  // Helper for Primary Orange Button
  Widget _buildPrimaryButton(String title, VoidCallback onTap) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.3),
        ),
        onPressed: onTap,
        child: CustomText(title, style: AppTextStyles.button.copyWith(color: Colors.white)),
      ),
    );
  }
}
