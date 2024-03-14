import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emindmatterssystemadminside/manageInfo/data%20model/HelpCrisisModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constant.dart';

class EditHelpCrisisForm extends StatefulWidget {
  final String? crisisId;

  EditHelpCrisisForm({Key? key, this.crisisId}) : super(key: key);

  @override
  _EditHelpCrisisFormState createState() => _EditHelpCrisisFormState();
}

class _EditHelpCrisisFormState extends State<EditHelpCrisisForm> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _websiteLinkController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  DateTime _datecreated = DateTime.now();
  AnimationController? _animationController;
  Animation<double>? _opacityAnimation;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  HelpCrisisModel? _currentCrisis;

  @override
  void initState() {
    super.initState();
    if (widget.crisisId != null) {  // Check if topicId is not null
      _loadCrisisData(widget.crisisId!);  // Provide the topicId here
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
    _nameController.dispose();
    _descriptionController.dispose();
    _authorController.dispose();
    _addressController.dispose();
    _phoneNoController.dispose();
    _websiteLinkController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _loadCrisisData(String crisisId) async {
    try {
      DocumentSnapshot topicSnapshot = await _db.collection('helpCrisis').doc(crisisId).get();
      if (topicSnapshot.exists) {
        Map<String, dynamic> crisisData = topicSnapshot.data() as Map<String, dynamic>;
        _currentCrisis = HelpCrisisModel.fromMap(crisisData, crisisId);
        // Set the UI fields with the data from the loaded topic
        _nameController.text = _currentCrisis!.name;
        _descriptionController.text = _currentCrisis!.description ?? '';
        _phoneNoController.text = _currentCrisis!.phoneNo ?? '';
        _addressController.text = _currentCrisis!.address ?? '';
        _websiteLinkController.text = _currentCrisis!.websiteLink ?? '';
        _authorController.text = _currentCrisis!.author ?? '';
        _datecreated = _currentCrisis!.dateCreated;
        setState(() {}); // Call setState to refresh the UI with the loaded data
      }
    } catch (e) {
      _showErrorMessage('Failed to load crisis: $e');
    }
  }

  Future<void> _saveTopic() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorMessage('Please fill all required fields correctly.');
      return;
    }

    if (_nameController.text.isEmpty) {
      _showErrorMessage('Name cannot be empty.');
      return;
    }

    try {
      User? currentAdmin = FirebaseAuth.instance.currentUser;
      if (currentAdmin == null) {
        _showErrorMessage('Admin is not authenticated.');
        return;
      }

      // Create the topic model with the unique ID
      _currentCrisis = HelpCrisisModel(
        name: _nameController.text,
        description: _descriptionController.text,
        phoneNo: _phoneNoController.text,
        address: _addressController.text,
        websiteLink: _websiteLinkController.text,
        author: _authorController.text,
        dateCreated: _datecreated,
        crisisId: _currentCrisis!.crisisId, // Use the generated unique ID
      );

      await _db.collection('helpCrisis').doc(_currentCrisis!.crisisId).update(_currentCrisis!.toMap());

      Navigator.pop(context, true); // true indicates the data was updated
      _showSuccessMessage('Help crisis added successfully.');
    } catch (e) {
      _showErrorMessage('Failed to save help crisis: $e');
    }
  }

  void _showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showSuccessMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColors,
        title: Text(
          "Update Help Crisis Info",
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
                _buildTextField(_nameController, 'Name', validator: validateName),
                SizedBox(height: 20),
                _buildTextField(_descriptionController, 'Description', maxLines: null),
                SizedBox(height: 20),
                _buildTextField(_phoneNoController, 'Phone Number', validator: validatePhoneNumber),
                SizedBox(height: 20),
                _buildTextField(_addressController, 'Address', validator: validateAddress),
                SizedBox(height: 20),
                _buildTextField(_websiteLinkController, 'Website link', validator: validateWebsiteLink),
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

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name cannot be empty.';
    }
    return null; // Return null if the value is valid
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // No error message if the value is empty
    }

    // General pattern to match phone numbers, including international formats
    RegExp pattern = RegExp(
      r'^\+?[0-9]{1,4}[-. ]?\(?\d{1,4}\)?[-. ]?\d{1,4}[-. ]?\d{1,4}$',
    );

    if (!pattern.hasMatch(value)) {
      return 'Invalid phone number format';
    }

    return null; // Return null if the value is valid
  }

  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return null; // No error message if the value is empty
    }

    return null; // Return null if the value is valid
  }

  String? validateWebsiteLink(String? value) {
    if (value == null || value.isEmpty) {
      return null; // No error message if the value is empty
    }

    // Using a more relaxed pattern for website URLs
    RegExp pattern = RegExp(
      r'^(http://|https://)?[a-zA-Z0-9]+([-.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,5}(:[0-9]{1,5})?(/.*)?$',
    );

    if (!pattern.hasMatch(value)) {
      return 'Invalid website link format';
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