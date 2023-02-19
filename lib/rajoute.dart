import 'package:flutter/material.dart';
import 'package:ydde/controller/accueil_controller.dart';
import 'package:percent_indicator/percent_indicator.dart';

class AccueilState extends State<AccueilController> {
  late double _percent = 0;
  late int _vie = 50;
  late bool _dead = false;
  @override
  void initState() {
    setState(() {
      _percent = _percent;
      _vie = _vie;
      _dead = _dead;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CircleAvatar(
            child: Image.network(widget.personnage.picture, fit: BoxFit.cover),
            backgroundColor: Colors.grey),
        title: Text(widget.personnage.pseudo),
        actions: [
          Row(
            children: [
              Text(
                "Level : ${widget.personnage.level.toString()}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              LinearPercentIndicator(
                width: 80.0,
                lineHeight: 14.0,
                percent: _percent,
                backgroundColor: Colors.grey,
                progressColor: Colors.red,
              ),
              const Icon(
                Icons.attach_money,
                size: 18,
              ),
              Text(
                " : ${widget.personnage.or.toString()}",
                style: TextStyle(fontSize: 18),
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 16)),
            ],
          ),
        ],
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black),
          GestureDetector(
              onTap: () async {
                setState(() {
                  if (_percent >= 0.95) {
                    _percent = 0;
                    widget.personnage.level = widget.personnage.level + 1;
                    widget.personnage.or = widget.personnage.or + 10;
                  } else {
                    if (_vie == 0) {
                      _dead = true;
                    } else {
                      _percent = _percent + 0.03;
                      _vie = _vie - 1;
                    }
                  }
                });
              },
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Dofly - Vie : $_vie",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const Padding(padding: EdgeInsets.all(30)),
                      (_vie == 0)
                          ? Image.network(
                              "https://assets.stickpng.com/images/589f095464b351149f22a8a3.png")
                          : Image.network(
                              "http://image.over-blog.com/o-Filrwx8OdwGXGuyfFW6_e6OfY=/filters:no_upscale()/image%2F0402291%2F20220324%2Fob_4d7933_ddayouk-17b66044-3708-4c68-9862-5ae422.gif")
                    ],
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
