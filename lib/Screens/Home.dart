import 'package:ezzybill/Controller/HomeConttroller.dart';
import 'package:ezzybill/Screens/Historyscreen.dart';
import 'package:ezzybill/Screens/HomeScreen/Homescreen.dart';
import 'package:ezzybill/Screens/ProfileScreen/ProfileScreen.dart';
import 'package:ezzybill/consts/colors.dart';
import 'package:ezzybill/consts/images.dart';
import 'package:ezzybill/consts/strings.dart';
import 'package:ezzybill/consts/styles.dart';
import 'package:ezzybill/widgetsCommon/BgWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var controller = Get.put(HomeController());
    var navbarItem = [
      BottomNavigationBarItem(
          icon: Image.asset(icHome, width: 26), label: home),
      BottomNavigationBarItem(
          icon: Image.asset(icHistory, width: 26), label: history),
      BottomNavigationBarItem(
          icon: Image.asset(icProfile, width: 26), label: profile),
    ];
    var navBody = [
      Homescreen(),
      Historyscreen(),
      ProfileScreen(),
    ];
    return BgWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Obx(() => Expanded(
                child: navBody.elementAt(controller.ContNavIndex.value))),
          ],
        ),
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
            currentIndex: controller.ContNavIndex.value,
            selectedItemColor: primaryColor,
            selectedLabelStyle: TextStyle(fontFamily: semibold),
            type: BottomNavigationBarType.fixed,
            backgroundColor: secondaryColor,
            items: navbarItem,
            onTap: (value) {
              controller.ContNavIndex.value = value;
            },
          ),
        ),
      ),
    );
  }
}
