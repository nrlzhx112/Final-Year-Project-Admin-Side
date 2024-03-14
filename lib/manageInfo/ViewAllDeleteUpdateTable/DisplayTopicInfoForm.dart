import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emindmatterssystemadminside/manageInfo/data%20model/TopicModel.dart';
import 'package:intl/intl.dart';

import '../../constant.dart';
import '../edit/EditTopicInfoForm.dart';

class DisplayTopicInfoForm extends StatefulWidget {
  @override
  _DisplayTopicInfoFormState createState() => _DisplayTopicInfoFormState();
}

class _DisplayTopicInfoFormState extends State<DisplayTopicInfoForm> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<String> _selectedTopicIds = [];
  bool _isAllSelected = false;
  List<String> _allTopicIds = [];
  int _rowCounter = 0;
  // Declare the search controller
  final TextEditingController _searchController = TextEditingController();
  // Declare the search query variable
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _db.collection('topics').snapshots().listen((QuerySnapshot snapshot) {
      setState(() {
        _allTopicIds = snapshot.docs.map((doc) => doc.id).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: pShadeColor1,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by title or author',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min, // Added to keep icons together
                    children: [
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          setState(() {
                            _searchQuery = _searchController.text.toLowerCase();
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _isAllSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        _isAllSelected = value!;
                        _selectedTopicIds.clear();
                        if (_isAllSelected) {
                          _selectedTopicIds.addAll(_allTopicIds);
                        }
                      });
                    },
                  ),
                  Text('Select All'),
                  SizedBox(width: 20.0),
                ],
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red,),
                onPressed: _selectedTopicIds.isEmpty
                    ? null
                    : () => _deleteSelectedTopics(),
              ),
              Text('Delete'),
              SizedBox(width: 20.0),
              IconButton(
                icon: Icon(Icons.edit, color: pShadeColor9,),
                onPressed: _selectedTopicIds.length == 1
                    ? () => _editSelectedTopic()
                    : null,
              ),
              Text('Edit'),
              SizedBox(width: 30.0),

            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 1.0,
          child: StreamBuilder(
            stream: _searchQuery.isEmpty
                ? _db.collection('topics').snapshots()
                : _db.collection('topics').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }
        
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              _rowCounter = 0;

              return DataTable(
                columnSpacing: 20.0,
                dataRowMinHeight: 180.0,
                dataRowMaxHeight: 180.0,
                columns: [
                  DataColumn(label: Text('Number', style: TextStyle(fontWeight: FontWeight.bold)),), // Added for row numbers
                  DataColumn(label: Text('Title', style: TextStyle(fontWeight: FontWeight.bold)),),
                  DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),),
                  DataColumn(label: Text('Author', style: TextStyle(fontWeight: FontWeight.bold)),),
                  DataColumn(
                      label: SizedBox(
                          width: 120, // Set a fixed width
                          child: Text('Date Created', style: TextStyle(fontWeight: FontWeight.bold))
                      )
                  ),
                  DataColumn(label: Text('Select', style: TextStyle(fontWeight: FontWeight.bold))), // Added a DataColumn for Select
                ],
                rows: snapshot.data!.docs.map((QueryDocumentSnapshot document) {
                  _rowCounter++;
                  TopicModel topic = TopicModel.fromMap(document.data() as Map<String, dynamic>, document.id);

                  // Enhanced Search Logic
                  bool isMatch = _searchQuery.split(' ').any((word) =>
                  topic.title.toLowerCase().contains(word) ||
                      (topic.author?.toLowerCase().contains(word) ?? false)
                  );

                  if (isMatch) {
                    final isSelected = _selectedTopicIds.contains(topic.topicId);
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(_rowCounter
                              .toString()), // Use the row counter as the row number
                        ),
                        DataCell(
                          Container(
                            child: Text(
                              topic.title,
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Text(
                                  topic.description ?? 'N/A',
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            child: Text(
                              topic.author ?? 'N/A',
                              // Limit to one line
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            child: Text(DateFormat('dd/MM/yyyy').format(topic.dateCreated)),
                          ),
                        ),
                        DataCell(
                          Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedTopicIds.add(topic.topicId);
                                } else {
                                  _selectedTopicIds.remove(topic.topicId);
                                }
                              });
                            },
                          ),
                        ),
                      ],
                      color: MaterialStateColor.resolveWith((states) {
                        final int index = snapshot.data!.docs.indexOf(document);
                        return index % 2 == 0 ? Colors.white : Colors.grey.shade200;
                      }),
                    );
                  } else {
                    return null;
                  }
                }).where((element) => element != null).cast<DataRow>().toList(),
              );
            }, // Added missing closing parenthesis here
          ),
        ),
      ),
    );
  }
  Future<void> _loadTopicData() async {
    try {
      QuerySnapshot snapshot = await _db.collection('topics').get();
      setState(() {
        _allTopicIds = snapshot.docs.map((doc) => doc.id).toList();
      });
    } catch (e) {
      print('Error loading topic data: $e');
    }
  }
  Future<void> _deleteSelectedTopics() async {
    try {
      await Future.forEach(_selectedTopicIds, (String topicId) async {
        await _db.collection('topics').doc(topicId).delete();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected topics deleted successfully!')),
      );

      setState(() {
        _selectedTopicIds.clear();
        _isAllSelected = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete topics: $e')),
      );
    }
  }
  void _editSelectedTopic() {
    if (_selectedTopicIds.length == 1) {
      String selectedTopicId = _selectedTopicIds.first;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditTopicInfoForm(topicId: selectedTopicId),
        ),
      ).then((result) {
        if (result == true) { // If the data was updated
          _loadTopicData(); // Reload the data
        }
      });
    }
  }
}
