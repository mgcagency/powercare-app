class ContactBookData {
  int? id;
  String? name;
  String? companyName;
  String? email;
  String? contactNo;
  String? contactImage;
  String? address;

  ContactBookData({
    this.id,
    this.name,
    this.companyName,
    this.email,
    this.contactNo,
    this.contactImage,
    this.address,
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
      address: "${json['address1'] ?? ''} ${json['address2'] ?? ''}".trim(),    );
  }
}