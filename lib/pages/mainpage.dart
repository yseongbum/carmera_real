import 'package:flutter/material.dart';
import 'package:carmera_real/pages/photopage.dart';
import 'package:carmera_real/pages/searchpage.dart';
import 'package:carmera_real/pages/settingpage.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          PhotoPage(),
          SearchPage(),
          SettingPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        backgroundColor: Colors.lightGreen[50],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        selectedLabelStyle: TextStyle(
          height: 1.6,
          fontSize:20,
          color: Colors.black,),
        unselectedLabelStyle: TextStyle(
          height: 1.6,
          fontSize:20,
          color: Colors.black54,
        ),// your text style
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: "촬영",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "검색",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "설정",
          ),
        ],
      ),
    );
  }
}
