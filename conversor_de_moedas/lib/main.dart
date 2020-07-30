import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

//Bucando dados do site https://hgbrasil.com/status/finance
// deve ter uma conta e criar uma chave
const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=2f68a3d3";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

//Cria um metodo que retorna os dados do site como JSON
//Armazena em um tipo Future<MAP>
Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final pesoController = TextEditingController();

  double euro;
  double dolar;
  double peso;

  void _realChanged(String text) {
    if (text.isEmpty) {
      clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
    pesoController.text = (real / peso).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
    pesoController.text = (dolar * this.dolar / peso).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
    pesoController.text = (euro * this.euro / peso).toStringAsFixed(2);
  }

  void _pesoChanged(String text) {
    if (text.isEmpty) {
      clearAll();
      return;
    }
    double peso = double.parse(text);
    realController.text = (peso * this.peso).toStringAsFixed(2);
    dolarController.text = (peso * this.peso / dolar).toStringAsFixed(2);
    euroController.text = (peso * this.peso / euro).toStringAsFixed(2);
  }

  void clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
    pesoController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(
          "Conversor \$",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              clearAll();
            },
            color: Colors.white,
          )
        ],
      ),
      //Body do mesmo tipo de dado da função getData()
      //tipo <Map>
      body: FutureBuilder<Map>(
        future: getData(),
        //Função do Builder retorna um contexto e um snapshot
        //Dependendo do que retornar mostra algo diferente
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.none ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Text(
                "Carregando Dados...",
                style: TextStyle(color: Colors.amber, fontSize: 25),
                textAlign: TextAlign.center,
              ),
            );
          } else if (snapshot.connectionState == snapshot.hasError) {
            return Center(
              child: Text(
                "Erro ao Carregar os dados!!",
                style: TextStyle(color: Colors.amber, fontSize: 25),
                textAlign: TextAlign.center,
              ),
            );
          } else {
            //Caso não haja nenhum erro o que aparecerá
            //Column, Icon, TextField, TextField, TextField, TextField:
            dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
            euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
            peso = snapshot.data["results"]["currencies"]["ARS"]["buy"];

            return SingleChildScrollView(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Icon(
                    Icons.attach_money,
                    color: Colors.amber,
                    size: 150,
                  ),
                  builderTextField("Real", "R\$", realController, _realChanged),
                  Divider(color: Colors.transparent),
                  builderTextField(
                      "Dolar", "US\$", dolarController, _dolarChanged),
                  Divider(color: Colors.transparent),
                  builderTextField("Euro", "€", euroController, _euroChanged),
                  Divider(color: Colors.transparent),
                  builderTextField(
                      "Peso Argentino", "\$", pesoController, _pesoChanged),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

Widget builderTextField(String label_text, prefix_text,
    TextEditingController controller, Function function) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label_text,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix_text,
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25),
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    onChanged: function,
    cursorColor: Colors.white,
  );
}
