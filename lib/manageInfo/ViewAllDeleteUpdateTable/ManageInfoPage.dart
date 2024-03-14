import 'package:flutter/material.dart';
import '../../constant.dart';
import '../add/AddinfoPage.dart';
import '../data model/TopicModel.dart';
import 'DisplayHelpCrisisInfoForm.dart';
import 'DisplayTopicInfoForm.dart';


class ManageInfoPage extends StatefulWidget {
  final TopicModel? initialTopic;

  const ManageInfoPage({Key? key, this.initialTopic}) : super(key: key);

  @override
  _ManageInfoPageState createState() => _ManageInfoPageState();
}

class _ManageInfoPageState extends State<ManageInfoPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColors,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'About Topic Info'),
            Tab(text: 'About Help Crisis Info'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            DisplayTopicInfoForm(),
            DisplayHelpCrisisInfoForm(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: pShadeColor9,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddInfoTabPage()),
          );
        },
        child: Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}

