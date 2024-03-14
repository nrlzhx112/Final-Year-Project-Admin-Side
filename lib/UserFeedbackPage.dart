import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'constant.dart';

class UserFeedbackPage extends StatefulWidget {
  const UserFeedbackPage({Key? key}) : super(key: key);

  @override
  _UserFeedbackPageState createState() => _UserFeedbackPageState();
}

class _UserFeedbackPageState extends State<UserFeedbackPage> {
  late Stream<QuerySnapshot> _feedbackStream;
  List<String> _selectedFeedbackIds = [];
  bool _isAllSelected = false;
  List<String> _allFeedbackIds = [];

  @override
  void initState() {
    super.initState();
    _feedbackStream = FirebaseFirestore.instance.collection('feedbacks').snapshots();
    _feedbackStream.listen((QuerySnapshot snapshot) {
      setState(() {
        _allFeedbackIds = snapshot.docs.map((doc) => doc.id).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Feedback'),
        backgroundColor: pShadeColor1,
        automaticallyImplyLeading: false,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Add this line
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _isAllSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        _isAllSelected = value!;
                        _selectedFeedbackIds.clear();
                        if (_isAllSelected) {
                          _selectedFeedbackIds.addAll(_allFeedbackIds);
                        }
                      });
                    },
                  ),
                  Text('Select All'),
                  SizedBox(width: 15.0),
                ],
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red,),
                onPressed: _selectedFeedbackIds.isEmpty
                    ? null
                    : () => _deleteSelectedFeedbacks(),
              ),
              Text('Delete'),
              SizedBox(width: 20.0),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _feedbackStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No feedback available.'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  final feedback = snapshot.data!.docs[index];
                  final feedbackId = feedback.id;
                  final isSelected = _selectedFeedbackIds.contains(feedbackId);

                  return ListTile(
                    leading: Checkbox(
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedFeedbackIds.add(feedbackId);
                          } else {
                            _selectedFeedbackIds.remove(feedbackId);
                          }
                        });
                      },
                    ),
                    title: Text(feedback['feedback']),
                    subtitle: FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(feedback['userId'])
                          .get(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState == ConnectionState.waiting) {
                          return Text('User ID: ${feedback['userId']}');
                        } else if (userSnapshot.hasError) {
                          return Text('Error loading username');
                        } else if (userSnapshot.hasData) {
                          final username = userSnapshot.data!['username'];
                          return Text('Username: $username');
                        } else {
                          return Text('User ID: ${feedback['userId']}');
                        }
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _deleteSelectedFeedbacks() async {
    try {
      await Future.forEach(_selectedFeedbackIds, (String feedbackId) async {
        await FirebaseFirestore.instance.collection('feedbacks').doc(feedbackId).delete();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected feedback deleted successfully!')),
      );

      setState(() {
        _selectedFeedbackIds.clear();
        _isAllSelected = false; // Reset the "Select All" checkbox
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete feedback: $e')),
      );
    }
  }
}
