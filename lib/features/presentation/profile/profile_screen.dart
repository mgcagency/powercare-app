import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:powercare_flutter/app/theme/text_styles.dart';
import 'package:powercare_flutter/app/widget/custom_button.dart';
import 'package:powercare_flutter/app/widget/custom_text.dart';
import 'package:powercare_flutter/app/widget/custom_textfield.dart';
import 'package:powercare_flutter/core/storage/app_preferences.dart';

import '../../alldata/api_repository/auth_repository.dart';
import '../../alldata/api_repository/dashboard_repository.dart';
import '../landing/landing_screen.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _roleController;
  late TextEditingController _phoneController;

  File? selectedImage;
  final ImagePicker picker = ImagePicker();
  String profileImage = "";
  bool isLoading = false;
  String userId = "";
  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _roleController = TextEditingController();
    _phoneController = TextEditingController();

    loadProfile();
  }
/*  @override
  void initState() {
    super.initState();
    _initControllers();
    loadProfileImage();
  }

  void _initControllers() {
    _firstNameController = TextEditingController(text: "Andy");
    _lastNameController = TextEditingController(text: "Hornsby");
    _emailController = TextEditingController(text: "andy@powercare.com");
    _roleController = TextEditingController(text: "FIELD ENGINEER");
    _phoneController = TextEditingController(text: "+44 786 514 569");
  }*/
  Future<void> loadProfile() async {
    try {
      final response = await DashboardRepository().getDashboard();

      print(response);

      final user = response["user"];

      if (user == null) return;

      userId = user["id"].toString();

      _firstNameController.text = user["first_name"] ?? "";
      _lastNameController.text = user["last_name"] ?? "";
      _emailController.text = user["email"] ?? "";
      _roleController.text = user["role"] ?? "";
      _phoneController.text = user["contact_number"] ?? "";

      profileImage = user["user_image"] ?? "";

      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  Future<void> loadProfileImage() async {
    profileImage = await AppPreferences.getUserImage() ?? "";
    setState(() {});
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => selectedImage = File(image.path));
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: CustomText("Profile Settings",
            style: AppTextStyles.headline4.copyWith(color: Colors.white, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(

        child: Column(
          children: [
            _buildHeader(),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildFormSection(
                    title: "Personal Information",
                    children: [
                      _buildField("First Name", _firstNameController, Icons.person_outline),
                      _buildField("Last Name", _lastNameController, Icons.person_outline),
                      _buildField("Employment Role", _roleController, Icons.badge_outlined, readOnly: true),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildFormSection(
                    title: "Contact Details",
                    children: [
                      _buildField("Email Address", _emailController, Icons.alternate_email_rounded,readOnly: true),
                      _buildField("Mobile Number", _phoneController, Icons.phone_iphone_rounded),
                    ],
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    title: "Update Profile",
                    isLoading: isLoading,
                    onPressed: _handleUpdate,
                  ),
                  const SizedBox(height: 20),
                  _buildLogoutButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 40, top: 10),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 4),
                ),
                child: /*CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  backgroundImage: selectedImage != null
                      ? FileImage(selectedImage!)
                      : (profileImage.isNotEmpty ? FileImage(File(profileImage)) : null),
                  child: (profileImage.isEmpty && selectedImage == null)
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),*/
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  backgroundImage: selectedImage != null
                      ? FileImage(selectedImage!)
                      : profileImage.isNotEmpty
                      ? NetworkImage(profileImage)
                      : null,
                  child: selectedImage == null && profileImage.isEmpty
                      ? const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  )
                      : null,
                ),
              ),
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
         // CustomText("Andy Hornsby",
        CustomText(
          "${_firstNameController.text} ${_lastNameController.text}",
              style: AppTextStyles.headline3.copyWith(color: Colors.white, fontSize: 22)),
          //CustomText("ID: #PC882100",
/*        CustomText(
          "ID : ${AppPreferences.getUserID()}",

              style: AppTextStyles.bodyExtraSmall.copyWith(color: Colors.white70, fontWeight: FontWeight.bold)),*/
      /*    CustomText(
            "ID: #$userId",
            style: AppTextStyles.bodyExtraSmall.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),*/

          CustomText(
            _roleController.text,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: CustomText(title,
              style: AppTextStyles.bodyExtraSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2
              )),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(label, style: AppTextStyles.bodyExtraSmall.copyWith(color: Colors.grey.shade600)),
          const SizedBox(height: 6),
          CustomTextField(
            controller: controller,
            readOnly: readOnly,
            // prefixIcon: Icon(icon, size: 20, color: readOnly ? Colors.grey : AppColors.navyBlue),
          ),
          if (label != "Mobile Number" && label != "Employment Role")
            const Divider(height: 24, thickness: 0.5),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return TextButton.icon(
      onPressed: () {  showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const CustomText("Logout"),
          content: const CustomText("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const CustomText("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await AppPreferences.setLoggedIn(false);
                await AppPreferences.clear();

                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              },
              child: const CustomText("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );},
      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
      label: CustomText("Sign out from device",
          style: AppTextStyles.bodySmall.copyWith(color: Colors.redAccent, fontWeight: FontWeight.bold)),
    );
  }

  Future<void> _handleUpdate() async {
    // Basic validation
    if (_firstNameController.text.trim().isEmpty || _lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("First and Last name are required",style: TextStyle(color: Colors.white))),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1. Get the repository instance
      final repo = AuthRepository();

      // 2. Call the update API
      final response = await repo.userEdit(
        userId: userId,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        role: _roleController.text.trim(),
        email: _emailController.text.trim(),
        contactNumber: _phoneController.text.trim(),
        imageFile: selectedImage, // This is the File? picked from gallery
      );

      if (response["status_code"] == 200 || response["success"] == true) {
        // 3. Update local preferences with new image URL from API if provided
        final userData = response["data"];
        if (userData != null && userData["user_image"] != null) {
          await AppPreferences.saveUserImage(userData["user_image"]);

          await AppPreferences.saveUserName(
            "${ _firstNameController.text.trim() ?? ""} ${_lastNameController.text.trim() ?? ""}",
          );

          await AppPreferences.saveRole(
            _roleController.text.trim() ?? "",
          );

        }

        if (!mounted) return;

        // 4. Show success and exit
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const CustomText("Profile successfully updated", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context, true); // Return true to refresh previous screen
      } else {
        throw response["message"] ?? "Failed to update profile";
      }
    } catch (e) {
      debugPrint("Update Error => $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText("Error: ${e.toString()}", style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}