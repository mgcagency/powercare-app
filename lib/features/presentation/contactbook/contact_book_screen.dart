import 'dart:async';

import 'package:flutter/material.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/widget/custom_appbar.dart';
import '../../alldata/api_repository/contact_repository.dart';
import '../../alldata/models/contact_book_model.dart';

class ContactBookScreen extends StatefulWidget {

  final bool showAppBar;

  const ContactBookScreen({
    super.key,
    this.showAppBar = true,
  });

  @override
  State<ContactBookScreen> createState() =>
      _ContactBookScreenState();
}

/*class ContactBookScreen extends StatefulWidget {
  const ContactBookScreen({super.key});

  @override
  State<ContactBookScreen> createState() =>
      _ContactBookScreenState();
}*/

class _ContactBookScreenState
    extends State<ContactBookScreen> {
  final ContactRepository repository =
  ContactRepository();

  final ScrollController scrollController =
  ScrollController();

  List<ContactBookData> contacts = [];
  Timer? _debounce;
  int page = 1;
  int lastPage = 1;
  bool isLoading = false;
  final TextEditingController searchController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    callContactBookListApi();

    scrollController.addListener(() {

      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {

        if (!isLoading &&
            page <= lastPage) {

          callContactBookListApi();
        }
      }
    });
  }
  Future<void> makePhoneCall(String phoneNumber) async {

    final Uri phoneUri =
    Uri.parse('tel:$phoneNumber');

    await launchUrl(phoneUri);
  }
  Future<void> callContactBookListApi() async {

    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {

      final response =
      await repository.getContactList(
        page: page,
        search: searchController.text,
      );

      final contactData =
      response["contactLists"]["data"];

      setState(() {

        contacts.addAll(
          contactData
              .map<ContactBookData>(
                (e) =>
                ContactBookData.fromJson(e),
          )
              .toList(),
        );

        lastPage =
            response["contactLists"]
            ["last_page"] ??
                1;

        page++;
      });

    } catch (e) {

      debugPrint(e.toString());

    } finally {

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      //appBar: const CustomAppBar(title: "Contact Book"),
      appBar: widget.showAppBar
          ? const CustomAppBar(
        title: "Contact Book",
      )
          : null,

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: (value) {

                if (_debounce?.isActive ?? false) {
                  _debounce!.cancel();
                }

                _debounce = Timer(
                  const Duration(milliseconds: 500),
                      () {

                    page = 1;
                    lastPage = 1;

                    contacts.clear();

                    callContactBookListApi();
                  },
                );
              },
            /*  onChanged: (value) {

                page = 1;
                lastPage = 1;

                contacts.clear();

                callContactBookListApi();
              },*/
              decoration: InputDecoration(
                hintText: "Search Contact",
                prefixIcon:
                const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${contacts.length} Contacts",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {

                final contact =
                contacts[index];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),

/*
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.orange.shade100,

                      backgroundImage:
                      contact.contactImage != null &&
                          contact.contactImage!.isNotEmpty
                          ? NetworkImage(
                        contact.contactImage!,
                      )
                          : null,

                      child:
                      contact.contactImage == null ||
                          contact.contactImage!.isEmpty
                          ? Text(
                        (contact.name ?? "U")
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      )
                          : null,
                    ),
*/
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor:AppColors.navyBlue.withOpacity(0.9), /*Colors.red.shade100,*/

                      child: Text(
                        (contact.name ?? "U")
                            .substring(0, 1)
                            .toUpperCase(),  style: const TextStyle(
                       color:AppColors.pureWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      ),
                    ),                    title: Text(
                      contact.name ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),

                    subtitle: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        if ((contact.companyName ?? "")
                            .isNotEmpty)
                          const SizedBox(height: 10),

                        Text(
                            contact.companyName ?? "",
                            style: const TextStyle(
                              color: Colors.black54,
                            ),
                          ),

                        const SizedBox(height: 10),

                        Text(
                          contact.contactNo ?? "",
                          style: const TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Text(
                          contact.email ?? "",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),

                      ],
                    ),

                    trailing: Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.call,
                          color: Colors.green,
                        ),
                        onPressed: () async {
                            if ((contact.contactNo ?? "")
                                .isNotEmpty) {

                              await makePhoneCall(
                              contact.contactNo!,
                              );
                            }
                         /* print(
                            "Call ${contact.contactNo}",
                          );*/
                        },
                      ),
                    ),
                  ),
                );              },
            ),
          ),
        ],
      ),
    );
  }
}