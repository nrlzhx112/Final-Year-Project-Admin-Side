import 'package:emindmatterssystemadminside/constant.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emindmatterssystemadminside/manageInfo/data%20model/HelpCrisisModel.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../edit/EditHelpCrisisForm.dart';

class DisplayHelpCrisisInfoForm extends StatefulWidget {
  @override
  _DisplayHelpCrisisInfoFormState createState() => _DisplayHelpCrisisInfoFormState();
}

class _DisplayHelpCrisisInfoFormState extends State<DisplayHelpCrisisInfoForm> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<String> _selectedCrisisIds = [];
  bool _isAllSelected = false;
  List<String> _allCrisisIds = [];
  int _rowCounter = 0;
  // Declare the search controller
  final TextEditingController _searchController = TextEditingController();
  // Declare the search query variable
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _db.collection('helpCrisis').snapshots().listen((QuerySnapshot snapshot) {
      setState(() {
        _allCrisisIds = snapshot.docs.map((doc) => doc.id).toList();
      });
    });
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
                  hintText: 'Search by name or author',
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
                        _selectedCrisisIds.clear();
                        if (_isAllSelected) {
                          _selectedCrisisIds.addAll(_allCrisisIds);
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
                onPressed: _selectedCrisisIds.isEmpty
                    ? null
                    : () => _deleteSelectedCrisis(),
              ),
              Text('Delete'),
              SizedBox(width: 20.0),
              IconButton(
                icon: Icon(Icons.edit, color: pShadeColor9,),
                onPressed: _selectedCrisisIds.length == 1 // Allow edit only when one crisis is selected
                    ? () => _editSelectedCrisis()
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
          width: MediaQuery.of(context).size.width * 1.0, // Adjust width as needed
          child: StreamBuilder(
            stream: _searchQuery.isEmpty
                ? _db.collection('helpCrisis').snapshots()
                : _db.collection('helpCrisis').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center( // Center widget added for better positioning
                  child: CircularProgressIndicator(),
                );
              }

              _rowCounter = 0;

              return DataTable(
                columnSpacing: 20.0,  // Added spacing between columns
                dataRowMinHeight: 200.0,  // Set a minimum height for each row
                dataRowMaxHeight: 200.0,  // Set a maximum height for each row
                columns: [
                  DataColumn(label: Text('Number', style: TextStyle(fontWeight: FontWeight.bold)),), // Added for row numbers
                  DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),),
                  DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),),
                  DataColumn(label: Text('Phone No', style: TextStyle(fontWeight: FontWeight.bold)),),
                  DataColumn(label: Text('Address', style: TextStyle(fontWeight: FontWeight.bold)),),
                  DataColumn(label: Text('Website Link', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Author', style: TextStyle(fontWeight: FontWeight.bold)),),
                  DataColumn(
                      label: SizedBox(
                          width: 120, // Set a fixed width
                          child: Text('Date Created', style: TextStyle(fontWeight: FontWeight.bold))
                      )
                  ),
                  DataColumn(label: Text('Select', style: TextStyle(fontWeight: FontWeight.bold)),), // Added a DataColumn for Select
                ],
                rows: snapshot.data!.docs.map((QueryDocumentSnapshot document) {
                  _rowCounter++;
                  HelpCrisisModel crisis = HelpCrisisModel.fromMap(document.data() as Map<String, dynamic>, document.id);
                  // Enhanced Search Logic
                  bool isMatch = _searchQuery.split(' ').any((word) =>
                  crisis.name.toLowerCase().contains(word) ||
                      (crisis.author?.toLowerCase().contains(word) ?? false)
                  );

                  if (isMatch) {
                    final isSelected = _selectedCrisisIds.contains(crisis
                        .crisisId);
                    return DataRow(
                      cells: [
                        DataCell(Text(_rowCounter.toString()),),
                        DataCell(Text(crisis.name,)),
                        DataCell(
                          Container(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Text(
                                  crisis.description ?? 'N/A',
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(crisis.phoneNo ?? 'N/A')),
                        DataCell(
                          Container(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Text(
                                  crisis.address ?? 'N/A',
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          GestureDetector(
                            onTap: () => _launchURL(crisis.websiteLink),
                            child: Text(
                              crisis.websiteLink ?? 'N/A',
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(crisis.author ?? 'N/A')),
                        DataCell(Text(DateFormat('dd/MM/yyyy').format(
                            crisis.dateCreated),)),
                        DataCell(
                          Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedCrisisIds.add(crisis.crisisId);
                                } else {
                                  _selectedCrisisIds.remove(crisis.crisisId);
                                }
                              });
                            },
                          ),
                        ),
                      ],
                      color: MaterialStateColor.resolveWith((states) {
                        final int index = snapshot.data!.docs.indexOf(document);
                        return index % 2 == 0 ? Colors.white : Colors.grey
                            .shade200;
                      }),
                    );
                  } else {
                    return null;
                  }
                }).where((element) => element != null).cast<DataRow>().toList(),
              );
            },
          ),
        ),
      ),
    );
  }
  Future<void> _loadCrisisData() async {
    try {
      QuerySnapshot snapshot = await _db.collection('helpCrisis').get();
      setState(() {
        _allCrisisIds = snapshot.docs.map((doc) => doc.id).toList();
      });
    } catch (e) {
      print('Error loading crisis data: $e');
    }
  }

  Future<void> _deleteSelectedCrisis() async {
    try {
      await Future.forEach(_selectedCrisisIds, (String crisisId) async {
        await _db.collection('helpCrisis').doc(crisisId).delete();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected crisis deleted successfully!')),
      );

      setState(() {
        _selectedCrisisIds.clear();
        _isAllSelected = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete crisis: $e')),
      );
    }
  }

  void _editSelectedCrisis() async {
    if (_selectedCrisisIds.length == 1) {
      String selectedCrisisId = _selectedCrisisIds.first;
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditHelpCrisisForm(crisisId: selectedCrisisId),
        ),
      );

      if (result == true) { // If the data was updated
        _loadCrisisData(); // Reload the data
      }
    }
  }
  void _launchURL(String? url) async {
    if (url != null) {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to launch the website')),
        );
      }
    }
  }
}