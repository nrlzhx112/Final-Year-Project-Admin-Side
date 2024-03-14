import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import '../auth/LogoutPage.dart';
import '../dashboard/DashboardPage.dart';
import 'UserFeedbackPage.dart';
import 'manageInfo/ViewAllDeleteUpdateTable/ManageInfoPage.dart';
import 'manageUser/ManageUserPage.dart';

class SideBarPage extends StatefulWidget {

  const SideBarPage({Key? key}) : super(key: key);

  @override
  _SideBarPageState createState() => _SideBarPageState();
}

class _SideBarPageState extends State<SideBarPage> {
  final _controller = SidebarXController(selectedIndex: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SidebarX(
            controller: _controller,
            theme: SidebarXTheme(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: canvasColor,
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: const TextStyle(color: Colors.white),
              selectedTextStyle: const TextStyle(color: Colors.white),
              itemTextPadding: const EdgeInsets.only(left: 30),
              selectedItemTextPadding: const EdgeInsets.only(left: 30),
              itemDecoration: BoxDecoration(
                border: Border.all(color: canvasColor),
              ),
              selectedItemDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: actionColor.withOpacity(0.37),
                ),
                gradient: LinearGradient(
                  colors: [ Colors.white70, Colors.white70],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.28),
                    blurRadius: 30,
                  )
                ],
              ),
              iconTheme: const IconThemeData(
                color: Colors.white,
                size: 20,
              ),
            ),
            extendedTheme: const SidebarXTheme(
              width: 200,
              decoration: BoxDecoration(
                color: canvasColor,
              ),
              margin: EdgeInsets.only(right: 10),
            ),
            footerDivider: divider,
            headerBuilder: (context, extended) {
              return SizedBox(
                height: 100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset('lib/assets/logo1.png'),
                ),
              );
            },
            items: [
              SidebarXItem(
                icon: Icons.dashboard,
                label: 'Dashboard',
              ),
              SidebarXItem(
                icon: Icons.info,
                label: 'Manage Info',
              ),
              SidebarXItem(
                icon: Icons.people,
                label: 'Manage User',
              ),
              SidebarXItem(
                icon: Icons.feedback,
                label: 'User Feedback',
              ),
              SidebarXItem(
                icon: Icons.logout,
                label: 'Logout',
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: _ScreensSideBar(controller: _controller),
            ),
          ),
        ],
      ),
    );
  }
}


class _ScreensSideBar extends StatelessWidget {
  const _ScreensSideBar({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final SidebarXController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        switch (controller.selectedIndex) {
          case 0:
            return DashboardPage();
          case 1:
            return ManageInfoPage();
          case 2:
            return ManageUserPage();
          case 3:
            return UserFeedbackPage();
          case 4:
            return LogoutPage();
          default:
            return Text(
              'Not found page',
              style: theme.textTheme.headlineSmall,
            );
        }
      },
    );
  }
}

const primaryColor = Color(0xFFD15BFF);
const canvasColor = Color(0xFF452E48);
const scaffoldBackgroundColor = Color(0xFF604667);
const accentCanvasColor = Color(0xFF5C3E61);
const white = Colors.white;
final actionColor = const Color(0xFF9A5FA7).withOpacity(0.6);

final divider = Divider(color: Colors.white.withOpacity(0.3), height: 1);