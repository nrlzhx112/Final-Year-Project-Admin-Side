class TopicModel {
  String topicId;
  String title;
  String? description;
  DateTime dateCreated;
  String? author;

  TopicModel({
    required this.topicId,
    required this.title,
    this.description,
    this.author,
    DateTime? dateCreated,  // Add this line
  }) : dateCreated = dateCreated ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'topicId':topicId,
      'title': title,
      'description': description,
      'dateCreated': dateCreated.toIso8601String(),
      'author': author,
    };
  }

  factory TopicModel.fromMap(Map<String, dynamic> map, String id) {
    return TopicModel(
      topicId: id,
      title: map['title'],
      description: map['description'],
      dateCreated: DateTime.parse(map['dateCreated']),
      author: map['author'],
    );
  }

}
