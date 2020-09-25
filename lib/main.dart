import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';
//import 'package:flutter_shine/flutter_shine.dart';

void main() {
  runApp(MyApp());
}

Future<Trivia> fetchTrivia() async {
  //Link del API : https://opentdb.com/api_config.php
  final response = await http.get('https://opentdb.com/api.php?amount=10&type=boolean');

  if (response.statusCode == 200) {
    return Trivia.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load Trivia');
  }
}

class Trivia {
  final int response_code;
  final List<dynamic> results;

  Trivia({this.response_code, this.results});

  factory Trivia.fromJson(Map<String, dynamic> json) {
    return Trivia(
        response_code: json['response_code'],
        results: json['results']);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trivia app',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Trivia'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum option { False, True }

class _MyHomePageState extends State<MyHomePage> {
  int question = 0;
  int correct = 0;
  final double dimensiones = 200;
  String texto;
  option _option;

  Future<Trivia> futureTrivia;
  @override
  void initState() {
    super.initState();
    futureTrivia = fetchTrivia();
  }
  _ventanaEmergente(int puntos){
    String mensaje;
    String img;
    if(puntos < 6) {
      mensaje = 'Ponte las pilas mi rey, hay que leer, tkm.';
      img = 'images/tkm.jpg';
    }
    else {
      mensaje = 'Madre mía Willy, estás que arde';
      img = 'images/mmw.jpg';
    }
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text('Resultado de la partida'),
            content: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Tus puntos fueron: '+puntos.toString(), style: TextStyle( fontSize: 22),),
                  Text(mensaje, style: TextStyle( fontSize: 20),),
                  Image(image: AssetImage(img), height: dimensiones,width: dimensiones,)
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: (){
                  Navigator.of(context).pop();
                  futureTrivia = fetchTrivia();
                  setState(() {
                    question = 0;
                  });
                  correct = 0;
                },
                child: Text('Nueva partida'),
              )
            ],
          );

        }
    );
  }

  
  Widget tarjeta(Trivia trivia, int pregunta, String opcion) {
    var unescape = new HtmlUnescape();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      alignment: Alignment.topCenter,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      unescape.convert(trivia.results[pregunta][opcion].toString()),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  int result(Trivia trivia, int pregunta, String titulo){
    String answer = trivia.results[pregunta][titulo];
    if(answer == 'True') return 1;
    else return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/fondo.jpg'), fit: BoxFit.cover)),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('TRIVIA-MANÍA', style: TextStyle(color: Colors.white, fontSize: 40),),
                  Divider(),
                  Text(
                    'Question: ' + (question + 1).toString(),
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  FutureBuilder<Trivia>(
                    future: futureTrivia,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            tarjeta(snapshot.data, question, 'category'),
                            tarjeta(snapshot.data, question, 'question'),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Radio(
                                                value: option.True,
                                                groupValue: _option,
                                                onChanged: (option value) {
                                                  setState(() {
                                                    _option = value;
                                                  });
                                                }),
                                            Text('True')
                                          ],
                                        )
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Radio(
                                                value: option.False,
                                                groupValue: _option,
                                                onChanged: (option value) {
                                                    setState(() {
                                                    _option = value;
                                                  });
                                                }),
                                            Text('False')
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            FlatButton(
                              color: Colors.deepPurpleAccent,
                              textColor: Colors.white,
                              disabledColor: Colors.grey,
                              disabledTextColor: Colors.black,
                              padding: EdgeInsets.all(8),
                              splashColor: Colors.blueAccent,
                              onPressed: () {
                                setState(() {
                                  if (question < 9) question++;
                                  else{
                                    _ventanaEmergente(correct);
                                  }
                                });
                                if(_option.index == result(snapshot.data,question,'correct_answer')) correct++;
                              },
                              child: Text(
                                "Next",
                                style: TextStyle(fontSize: 20),
                              ),
                            )
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }
                      // By default, show a loading spinner.
                      return CircularProgressIndicator();
                    },
                  ),
                ],
              ),
            ),
          )),
    );
  }
}

