import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance/quotations?key=7ead73b8";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        primaryColorBrightness: Brightness.dark,
        hintColor: Colors.amber,
        primaryColor: Colors.amber,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);

  return jsonDecode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String text) {
    double real = double.parse(text);

    if (text.isEmpty) {
      _clearAll();
      return;
    }

    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    double dolar = double.parse(text);

    if (text.isEmpty) {
      _clearAll();
      return;
    }

    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = ((dolar * this.dolar) / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    double euro = double.parse(text);

    if (text.isEmpty) {
      _clearAll();
      return;
    }

    realController.text = (euro * this.euro).toStringAsFixed(2);
    euroController.text = ((euro * this.euro) / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "\$ Conversor \$",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    "Carregando Dados...",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao carregar dados!",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                      child: Padding(
                    padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(
                          Icons.monetization_on,
                          color: Colors.amber,
                          size: 150.0,
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
                          child: buildTextField(
                              "Reais", "R\$", realController, _realChanged),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
                          child: buildTextField("Dólares", "US\$",
                              dolarController, _dolarChanged),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
                          child: buildTextField(
                              "Euros", "€", euroController, _euroChanged),
                        )
                      ],
                    ),
                  ));
                }
            }
          }),
    );
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController textController, Function textChanged) {
  return TextField(
    controller: textController,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix,
        prefixStyle: TextStyle(color: Colors.amber)),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    onChanged: textChanged,
  );
}
