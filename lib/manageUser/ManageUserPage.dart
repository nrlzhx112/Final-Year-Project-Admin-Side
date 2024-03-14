import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constant.dart';

class ManageUserPage extends StatefulWidget {
  const ManageUserPage({Key? key}) : super(key: key);

  @override
  _ManageUserPageState createState() => _ManageUserPageState();
}

class _ManageUserPageState extends State<ManageUserPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<String> _selectedUserIds = [];
  bool _isAllSelected = false;
  List<String> _allUserIds = [];
  int _rowCounter = 0;

  // Declare the search controller
  final TextEditingController _searchController = TextEditingController();
  // Declare the search query variable
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _db.collection('users').snapshots().listen((QuerySnapshot snapshot) {
      setState(() {
        _allUserIds = snapshot.docs.map((doc) => doc.id).toList();
      });
    });
  }

  Future<void> _editSelectedUsers() async {
    if (_selectedUserIds.length == 1) {
      String userIdToEdit = _selectedUserIds.first;
      // Fetch the user details from Firestore
      DocumentSnapshot userSnapshot = await _db.collection('users').doc(userIdToEdit).get();
      Map<String, dynamic> userDetails = userSnapshot.data() as Map<String, dynamic>;

      // Now, open a dialog or another widget to edit the user details
      _openEditDialog(userDetails, userIdToEdit);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select only one user to edit')),
      );
    }
  }

  void _openEditDialog(Map<String, dynamic> userDetails, String userId) {
    TextEditingController nameController = TextEditingController(text: userDetails['username']);
    TextEditingController birthdateController = TextEditingController(text: userDetails['birthdate']);
    TextEditingController bioController = TextEditingController(text: userDetails['bio']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: birthdateController,
                  decoration: InputDecoration(labelText: 'Birthdate'),
                ),
                TextField(
                  controller: bioController,
                  decoration: InputDecoration(labelText: 'Bio'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                _updateUserDetails(userId, nameController.text, birthdateController.text, bioController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateUserDetails(String userId, String name, String birthdate, String bio) async {
    try {
      await _db.collection('users').doc(userId).update({
        'username': name,
        'birthdate': birthdate,
        'bio': bio,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User details updated successfully')));
      setState(() {
        _selectedUserIds.clear();
        _isAllSelected = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update user: $e')));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: pShadeColor1,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name or email',
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
            children: [
              Checkbox(
                value: _isAllSelected,
                onChanged: (bool? value) {
                  setState(() {
                    _isAllSelected = value!;
                    _selectedUserIds.clear();
                    if (_isAllSelected) {
                      _selectedUserIds.addAll(_allUserIds);
                    }
                  });
                },
              ),
              Text('Select All'),
              SizedBox(width: 20.0),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red,),
                onPressed: _selectedUserIds.isEmpty
                    ? null
                    : () => _deleteSelectedUsers(),
              ),
              Text('Delete'),
              SizedBox(width: 20.0),
              IconButton(
                icon: Icon(Icons.edit, color: pShadeColor9,),
                onPressed: _selectedUserIds.isEmpty
                    ? null
                    : () => _editSelectedUsers(),
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
            stream: _db.collection('users').snapshots(),
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

              var filteredDocs = snapshot.data!.docs.where((doc) {
                var data = doc.data() as Map<String, dynamic>;
                String userId = doc.id;
                String username = (data['username'] ?? '').toString().toLowerCase();
                String email = (data['email'] ?? '').toString().toLowerCase();

                // Check if any field contains the search query
                return userId.contains(_searchQuery) ||
                    username.contains(_searchQuery) ||
                    email.contains(_searchQuery);
              });

              return SingleChildScrollView( // Allow horizontal scrolling
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columnSpacing: 5.0,
                  columns: [
                    DataColumn(label: Text('Number', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Birthdate', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Bio', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Select', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: filteredDocs.map((QueryDocumentSnapshot document) {
                    _rowCounter++;
                    final userId = document.id;
                    final isSelected = _selectedUserIds.contains(userId);
                    return DataRow(
                      cells: [
                        DataCell(Text(_rowCounter.toString())),
                        DataCell(Text(document['username'] ?? 'N/A')),
                        DataCell(Text(document['email'] ?? 'N/A')),
                        DataCell(Text(document['birthdate'] ?? 'N/A')),
                        DataCell(Text(document['bio'] ?? 'N/A')),
                        DataCell(
                          Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedUserIds.add(userId);
                                } else {
                                  _selectedUserIds.remove(userId);
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
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  Future<void> _deleteSelectedUsers() async {
    try {
      await Future.forEach(_selectedUserIds, (String userId) async {
        await _db.collection('users').doc(userId).delete();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected users deleted successfully!')),
      );

      setState(() {
        _selectedUserIds.clear();
        _isAllSelected = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete users: $e')),
      );
    }
  }
}
