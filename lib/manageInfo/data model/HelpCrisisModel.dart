class HelpCrisisModel {
  String crisisId;
  String name;
  String? phoneNo;
  String? address;
  String? websiteLink;
  String? description;
  DateTime dateCreated;
  String? author;

  HelpCrisisModel({
    required this.crisisId,
    required this.name,
    this.phoneNo,
    this.address,
    this.websiteLink,
    this.description,
    this.author,
    DateTime? dateCreated, // Add this line
  }) : dateCreated = dateCreated ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'crisisId': crisisId,
      'name': name,
      'phoneNo': phoneNo,
      'address': address,
      'websiteLink': websiteLink,
      'description': description,
      'dateCreated': dateCreated.toIso8601String(),
      'author': author,
    };
  }

  factory HelpCrisisModel.fromMap(Map<String, dynamic> map, String id) {
    return HelpCrisisModel(
      crisisId: id,
      name: map['name'],
      phoneNo: map['phoneNo'],
      address: map['address'],
      websiteLink: map['websiteLink'],
      description: map['description'],
      dateCreated: DateTime.parse(map['dateCreated']),
      author: map['author'],
    );
  }
}
