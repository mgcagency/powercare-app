/*
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: "Andy");
    _lastNameController = TextEditingController(text: "Hornsby");
    _emailController = TextEditingController(text: "powercareelectrical@icloud.com");
    _roleController = TextEditingController(text: "ENGINEER");
    _phoneController = TextEditingController(text: "0786514569");
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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final profileImageSize = width * 0.30;
    final headerHeight = height * 0.25;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Container(
              height: headerHeight,
              width: width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/icons/login_bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
          */
/*    decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFF5B1F),
                    Color(0xFFFF7A00),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),*//*

            ),
            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.05,
                        vertical: 12,
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: headerHeight * 0.2),
                    Container(
                      width: profileImageSize,
                      height: profileImageSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                        image: const DecorationImage(
                          image: NetworkImage(
                            "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400",
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Change photo")),
                            );
                          },
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF5B1F),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: width * 0.05,
                        vertical: 20,
                      ),
                      padding: EdgeInsets.all(width * 0.05),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Andy Hornsby",
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Engineer",
                            style: TextStyle(
                              color: Color(0xFFFF5B1F),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: width * 0.08),
                          _buildProfileField(
                            Icons.person_outline,
                            "First name",
                            _firstNameController,
                          ),
                          SizedBox(height: width * 0.05),
                          _buildProfileField(
                            Icons.person_outline,
                            "Last name",
                            _lastNameController,
                          ),
                          SizedBox(height: width * 0.05),
                          _buildProfileField(
                            Icons.email_outlined,
                            "Email",
                            _emailController,
                          ),
                          SizedBox(height: width * 0.05),
                          _buildProfileField(
                            Icons.work_outline,
                            "Role",
                            _roleController,
                          ),
                          SizedBox(height: width * 0.05),
                          _buildProfileField(
                            Icons.phone_outlined,
                            "Contact number",
                            _phoneController,
                          ),
                          SizedBox(height: width * 0.08),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton.icon(
                              onPressed: _updateProfile,
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text("Update Profile"),
                              style: ElevatedButton.styleFrom(

                                backgroundColor: const Color(0xFFFF5B1F),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: width * 0.05),

                        ],
                      ),
                    ),
                    SizedBox(height: width * 0.05),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String title) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(title)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFF5B1F),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: const Color(0xFFFF5B1F),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFFF5B1F),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(
      IconData icon,
      String label,
      TextEditingController controller,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFFF5B1F),
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFFFF5B1F),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _updateProfile() {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile updated successfully"),
        backgroundColor: Colors.green,
      ),
    );
  }


}*/
import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/widget/custom_button.dart';
import '../../../app/widget/custom_textfield.dart';

class AnimatedProfileScreen extends StatefulWidget {
  const AnimatedProfileScreen({super.key});

  @override
  State<AnimatedProfileScreen> createState() => _AnimatedProfileScreenState();
}

class _AnimatedProfileScreenState extends State<AnimatedProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _roleController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();

    _firstNameController = TextEditingController(text: "Andy");
    _lastNameController = TextEditingController(text: "Hornsby");
    _emailController = TextEditingController(text: "andy@powercare.com");
    _roleController = TextEditingController(text: "ENGINEER");
    _phoneController = TextEditingController(text: "+44 786 514 569");
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          Container(
            height: height * 0.35,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/icons/login_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
/*            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF667EEA).withOpacity(0.95),
                  const Color(0xFF764BA2).withOpacity(0.95),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),*/
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.06,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                  /*      const Text(
                          "Profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),*/
            /*            Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.settings_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),*/
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Curves.elasticOut,
                        ),
                      ),
                      child: Container(
                        width: width * 0.35,
                        height: width * 0.35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 6,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.navyBlue,
                              blurRadius: 30,
                              spreadRadius: 8,
                            ),
                          ],
                          image: const DecorationImage(
                            image: NetworkImage(
                              "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Update Profile Picture"),
                                  backgroundColor: Color(0xFF667EEA),
                                ),
                              );
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                             /*   boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF667EEA)
                                        .withOpacity(0.5),
                                    blurRadius: 15,
                                    spreadRadius: 3,
                                  ),
                                ],*/
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: width * 0.06,
                          vertical: 12,
                        ),
                        padding: EdgeInsets.all(width * 0.06),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Andy Hornsby",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFff5b1f),
                                    Color(0xFF0F2D52),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Engineer",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            SizedBox(height: width * 0.08),
                            CustomTextField(

                              controller: _firstNameController,
                              label: "First Name",
                              hintText: "Enter first name",
                            ),
                            SizedBox(height: width * 0.05),
                            CustomTextField(
                              controller: _lastNameController,
                              label: "Last Name",
                              hintText: "Enter last name",
                            ),
                            SizedBox(height: width * 0.05),
                            CustomTextField(
                              controller: _roleController,
                              label: "Role",
                              hintText: "Enter your email",
                            ),
                            SizedBox(height: width * 0.05),
                            CustomTextField(
                              controller: _emailController,
                              label: "Email",
                              hintText: "Enter your email",
                            ),

                            SizedBox(height: width * 0.05),
                            CustomTextField(
                              controller: _phoneController,
                              label: "Phone Number",
                              hintText: "Enter phone number",
                            ),
                            SizedBox(height: width * 0.08),
                            CustomButton(background: AppColors.primary,
                              title: "Update",
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      "✓ Profile Updated Successfully",
                                    ),
                                    backgroundColor: AppColors.navyBlue,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                            ),
/*
                            Container(color: AppColors.navyBlue,
                        */

                            SizedBox(height: width * 0.04),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: width * 0.06),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}