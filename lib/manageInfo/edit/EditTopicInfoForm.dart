import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emindmatterssystemadminside/manageInfo/data%20model/TopicModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constant.dart';

class EditTopicInfoForm extends StatefulWidget {
  final String? topicId;

  EditTopicInfoForm({Key? key, this.topicId}) : super(key: key);

  @override
  _EditTopicInfoFormState createState() => _EditTopicInfoFormState();
}

class _EditTopicInfoFormState extends State<EditTopicInfoForm> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  DateTime _datecreated = DateTime.now();

  AnimationController? _animationController;
  Animation<double>? _opacityAnimation;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  TopicModel? _currentTopic;

  @override
  void initState() {
    super.initState();
    if (widget.topicId != null) {  // Check if topicId is not null
      _loadTopicData(widget.topicId!);  // Provide the topicId here
    }
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController!);
    _animationController!.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _authorController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _loadTopicData(String topicId) async {
    try {
      DocumentSnapshot topicSnapshot = await _db.collection('topics').doc(topicId).get();
      if (topicSnapshot.exists) {
        Map<String, dynamic> topicData = topicSnapshot.data() as Map<String, dynamic>;
        _currentTopic = TopicModel.fromMap(topicData, topicId);
        // Set the UI fields with the data from the loaded topic
        _titleController.text = _currentTopic!.title;
        _descriptionController.text = _currentTopic!.description ?? '';
        _authorController.text = _currentTopic!.author ?? '';
        _datecreated = _currentTopic!.dateCreated;
        setState(() {}); // Call setState to refresh the UI with the loaded data
      }
    } catch (e) {
      _showErrorMessage('Failed to load topic: $e');
    }
  }

  Future<void> _saveTopic() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorMessage('Please fill all required fields correctly.');
      return;
    }

    if (_titleController.text.isEmpty) {
      _showErrorMessage('Topic title cannot be empty.');
      return;
    }

    try {
      User? currentAdmin = FirebaseAuth.instance.currentUser;
      if (currentAdmin == null) {
        _showErrorMessage('Admin is not authenticated.');
        return;
      }

      if (_currentTopic == null) {
        _showErrorMessage('Topic data is not initialized.');
        return;
      }

      // Update the current topic's data
      _currentTopic = TopicModel(
        topicId: _currentTopic!.topicId, // Preserve the original topicId
        title: _titleController.text,
        description: _descriptionController.text,
        author: _authorController.text,
        dateCreated: _datecreated,
      );

      await _db.collection('topics').doc(_currentTopic!.topicId).update(_currentTopic!.toMap());

      Navigator.pop(context, true);
    } catch (e) {
      _showErrorMessage('Failed to save topic: $e');
    }
  }

  void _showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColors,
        title: Text(
          "Update Topic Info",
          style: TextStyle(
            color: pShadeColor8,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close, color: pShadeColor9),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: FadeTransition(
          opacity: _opacityAnimation!,
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                _buildTextField(_titleController, 'Title', validator: validateTitle),
                SizedBox(height: 20),
                _buildTextField(_descriptionController, 'Description', maxLines: null),
                SizedBox(height: 20),
                _buildDatePicker('Creation date', (date) => setState(() => _datecreated = date)),
                SizedBox(height: 20),
                _buildTextField(_authorController, 'Author'),
                SizedBox(height: 30),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int? maxLines, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator, // Set the validator for the TextFormField
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: pShadeColor9), // Custom border color
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: pShadeColor4), // Custom border color for enabled state
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title cannot be empty.';
    }
    return null; // Return null if the value is valid
  }

  Widget _buildDatePicker(String label, ValueChanged<DateTime> onDateChanged) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: pShadeColor4), // Custom border color
        borderRadius: BorderRadius.circular(8), // Border radius
        color: Colors.white, // Background color
      ),
      child: ListTile(
        title: Text(DateFormat('dd/MM/yyyy').format(_datecreated)), // Display the date from _datecreated
        trailing: Icon(Icons.calendar_today, color: pShadeColor9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _saveTopic,
      child: Text(
        'Submit',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: pShadeColor4,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    );
  }

}