import 'package:flutter/material.dart';

class BottomNavigationBarWidget extends StatefulWidget{
  final int selectedIndex;
  late int _points;
  late String _specialisation;
  BottomNavigationBarWidget({Key? key, required points, required specialisation, required this.selectedIndex}) {
    _points = points;
    _specialisation = specialisation;
  }

  @override
  _BottomNavigationBarState createState() => _BottomNavigationBarState();
}

class _BottomNavigationBarState extends State<BottomNavigationBarWidget>{
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect (
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          topLeft: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 15,
          selectedIconTheme:
          const IconThemeData(color: Colors.white, size: 30),
          selectedItemColor: Colors.white,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: _colorSPr(specialisation: widget._specialisation),
          items: [
            const BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag), label: "Boutique"),
            (widget._points <= 0)
                ? const BottomNavigationBarItem(
                icon: Icon(Icons.person), label: "Profil")
                : const BottomNavigationBarItem(
                icon: Icon(Icons.person, color: Colors.green),
                label: "Profil"),
            const BottomNavigationBarItem(
                icon: Icon(Icons.gamepad), label: "Combat"),
            const BottomNavigationBarItem(
                icon: Icon(Icons.flag), label: "Guilde"),
            const BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "Options"),
          ],
        ));
  }


  /// Permet de déterminer quel state est appelé.
  dynamic _colorSPr({required String specialisation}) {
    Object colorSp = {
      "archer": Colors.green.withOpacity(0.3),
      "sorcier": Colors.blue.withOpacity(0.3),
      "guerrier": Colors.red.withOpacity(0.3),
    }.putIfAbsent(
        specialisation,
            () => Colors.black87);
    return colorSp;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}