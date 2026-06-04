class ContactBookData {
  int? id;
  String? name;
  String? companyName;
  String? email;
  String? contactNo;
  String? contactImage;

  ContactBookData({
    this.id,
    this.name,
    this.companyName,
    this.email,
    this.contactNo,
    this.contactImage,
  });

  factory ContactBookData.fromJson(
      Map<String, dynamic> json) {
    return ContactBookData(
      id: json['id'],
      name: json['name'],
      companyName: json['company_name'],
      email: json['email'],
      contactNo: json['contact_no'],
      contactImage: json['contact_image'],
    );
  }
}