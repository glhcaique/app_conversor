import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';

import 'dart:convert';

const request = 'https://api.hgbrasil.com/finance';

void main(){
  runApp(
      MaterialApp(
        title: "Conversor de moedas",
        home:Home(),
      )
  );
}

Future<Map> getData() async{
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolar, bitcoins;
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final bitcoinsController = TextEditingController();
  String titulo  = "Conversor V ";
  double versao = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: Text(
          "$titulo" + "${versao.toString()}",
          style: TextStyle(
              fontFamily: 'Open Sans',
              fontSize: 20.0,
              color: Colors.white
          ),
        ),
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context,snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              if(snapshot.hasError){
                return Center(
                  child: Text(
                    "Erro ao carregar os dados"
                  ),
                );
              }else{
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                bitcoins = snapshot.data["results"]["currencies"]["BTC"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      buildTextField("Reais", "R\$ ", realController,
                          _realChanged),
                      Divider(),
                      buildTextField("Dolar", "US\$ ",dolarController,
                          _dollarChanged),
                      Divider(),
                      buildTextField("Bitcoins", "BTC ",bitcoinsController,
                          _bitcoinsChanged),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          'Deus seja louvado',
                          style: TextStyle(
                              fontSize: 11.0,
                              color: Colors.grey
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }
          }
        },
      )
    );
  }

  void _realChanged(String text){
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    bitcoinsController.text = (real/bitcoins).toStringAsFixed(5);
  }

  void _dollarChanged(String text){
    double _dolar = double.parse(text);
    realController.text = (_dolar * dolar).toStringAsFixed(2);
    bitcoinsController.text = (_dolar * dolar / bitcoins).toStringAsFixed(5);
  }

  void _bitcoinsChanged(String text){
    double _bitcoins = double.parse(text);
    realController.text = (_bitcoins * bitcoins).toStringAsFixed(2);
    dolarController.text = (_bitcoins * bitcoins / dolar).toStringAsFixed(2);
  }
}


Widget buildTextField(String label, String prefix,
    TextEditingController c, Function f){
  return TextField(
      controller: c,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          labelText: "$label",
          border: OutlineInputBorder(),
          prefixText: "$prefix "
      ),
    onChanged: f,
    );
}