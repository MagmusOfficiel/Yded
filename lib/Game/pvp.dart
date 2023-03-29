import 'package:flutter/material.dart';

class PvP extends StatefulWidget{
  const PvP({super.key});

  @override
  _PvPState createState() => _PvPState();
}

class _PvPState extends State<PvP> with SingleTickerProviderStateMixin{
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    // Définir la durée de l'animation et initialiser le contrôleur d'animation
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    // Définir l'animation pour déplacer l'image
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -0.1),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Image.asset('assets/images/pvp.png',fit: BoxFit.cover
          ,),
      ),
      Center(
        child: SlideTransition(
          position: _animation,
          child: Image.asset(
            'assets/images/pvpenter.png',
            fit: BoxFit.cover,
            height: 150,
            width: 150,
          ),
        ),
      )
    ],);
  }

}