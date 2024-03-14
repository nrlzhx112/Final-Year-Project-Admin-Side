import 'package:emindmatterssystemadminside/constant.dart';
import 'package:flutter/material.dart';

import 'HelpCrisisForm.dart';
import 'TopicInfoForm.dart';

class AddInfoTabPage extends StatefulWidget {
  @override
  _AddInfoTabPageState createState() => _AddInfoTabPageState();
}

class _AddInfoTabPageState extends State<AddInfoTabPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
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
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: pShadeColor9,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Topic Info'),
            Tab(text: 'Help Crisis Info'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TopicInfoForm(),
          HelpCrisisForm(),
        ],
      ),
    );
  }
}
