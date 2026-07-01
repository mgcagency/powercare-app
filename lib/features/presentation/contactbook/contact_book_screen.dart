import 'dart:async';
import 'package:flutter/material.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:powercare_flutter/app/widget/custom_search_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/widget/custom_appbar.dart';
import '../../alldata/api_repository/contact_repository.dart';
import '../../alldata/models/contact_book_model.dart';
import '../../../app/theme/text_styles.dart';
import '../../../app/widget/custom_text.dart';

class ContactBookScreen extends StatefulWidget {
  final bool showAppBar;

  const ContactBookScreen({super.key, this.showAppBar = true});

  @override
  State<ContactBookScreen> createState() => _ContactBookScreenState();
}

class _ContactBookScreenState extends State<ContactBookScreen> {
  final ContactRepository repository = ContactRepository();
  final ScrollController scrollController = ScrollController();

  List<ContactBookData> contacts = [];
  Timer? _debounce;
  int page = 1;
  int lastPage = 1;
  bool isLoading = false;
  bool isFirstLoad = true; // Track initial load for center loader
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    callContactBookListApi();

    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        if (!isLoading && page <= lastPage) {
          callContactBookListApi();
        }
      }
    });
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> callContactBookListApi() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final response = await repository.getContactList(
        page: page,
        search: searchController.text,
      );

      final contactData = response["contactLists"]["data"];

      setState(() {
        if (page == 1) contacts.clear(); // Clear for new search
        contacts.addAll(
          contactData.map<ContactBookData>((e) => ContactBookData.fromJson(e)).toList(),
        );
        lastPage = response["contactLists"]["last_page"] ?? 1;
        page++;
        isFirstLoad = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: widget.showAppBar ? const CustomAppBar(title: "Contact Book") : null,
      body: Column(
        children: [
          CustomSearchBar(
            controller: searchController,
            onChanged: (value) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                page = 1;
                isFirstLoad = true;
                callContactBookListApi();
              });
            },
          ),
          Expanded(
            child: isFirstLoad && isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : contacts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.only(bottom: 100),
              // Add 1 to itemCount if loading more to show bottom loader
              itemCount: contacts.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < contacts.length) {
                  return _buildAnimatedItem(index);
                } else {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Staggered Animation for list items
  Widget _buildAnimatedItem(int index) {
    final contact = contacts[index];

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + (index % 10 * 50)), // Stagger effect
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: _buildContactCard(contact),
    );
  }

  Widget _buildContactCard(ContactBookData contact) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: CustomText(
                    (() {
                      if (contact.name == null || contact.name!.trim().isEmpty) return "U";
                      List<String> nameParts = contact.name!.trim().split(" ");
                      return (nameParts.length > 1
                          ? nameParts.first[0] + nameParts.last[0]
                          : nameParts.first[0]).toUpperCase();
                    })(),
                    style: AppTextStyles.headline4.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        contact.name ?? "Unknown",
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.navyBlue,
                        ),
                      ),
                      const SizedBox(height: 2),
                      CustomText(
                        contact.companyName ?? "Independent",
                        style: AppTextStyles.bodyExtraSmall.copyWith(
                          color: Colors.blueGrey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filled(
                  onPressed: () => makePhoneCall(contact.contactNo ?? ""),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green.shade500,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.call, size: 20),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.alternate_email_rounded, size: 14, color: AppColors.primary.withOpacity(0.6)),
                const SizedBox(width: 6),
                Expanded(
                  child: CustomText(
                    contact.email ?? "No email",
                    style: AppTextStyles.bodyExtraSmall.copyWith(color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(Icons.phone_android_rounded, size: 14, color: AppColors.primary.withOpacity(0.6)),
                const SizedBox(width: 4),
                CustomText(
                  contact.contactNo ?? "",
                  style: AppTextStyles.bodyExtraSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.navyBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.contact_page_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          CustomText("No contacts found",
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }
}