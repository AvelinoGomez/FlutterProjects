import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String _infoTeste = "Informe seus dados";

  void resetField(){
    weightController.text = "";
    heightController.text = "";
    setState(() {
      _infoTeste = "Informe seus dados";
    });
  }

  void calculate(){
    setState(() {
      double weight = double.parse(weightController.text);
      double height = double.parse(heightController.text);

      double imc = weight / ((height/100) * (height/100));

      if(imc < 18.6){
        _infoTeste = "IMC dentro da média ($imc)";
      }else if(imc < 50){
        _infoTeste = "Perto do limite ($imc)";
      }else if(imc <100){
        _infoTeste = "Obeso ($imc)";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calculadora IMC"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: resetField,
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding:  EdgeInsets.fromLTRB(25, 0, 25, 0),
        child: Form(
          key: formKey,
          autovalidate: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(Icons.person, size: 120, color: Colors.deepPurple),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Peso (kg)",
                    labelStyle: TextStyle(color: Colors.deepPurple)),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.deepPurple, fontSize: 25),
                controller: heightController,
                validator: (value) {
                  if(value.isEmpty){
                    return "Insira seu peso";
                  }
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Altura (cm)",
                    labelStyle: TextStyle(color: Colors.deepPurple)),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.deepPurple, fontSize: 25),
                controller: weightController,
                validator: (value) {
                  if(value.isEmpty){
                    return "Insira seu peso";
                  }
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: Container(
                  height: 70,
                  child: RaisedButton(
                    child: Text("Calcular",
                      style: TextStyle(fontSize: 25),
                    ),
                    color: Colors.deepPurple,
                    textColor: Colors.white,
                    onPressed: () {
                      if(formKey.currentState.validate()){
                        calculate();
                      }
                    },
                  ),
                ),
              ),
              Text(_infoTeste,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.deepPurple, fontSize: 25),)
            ],
          ),
        )
      )
    );
  }

}
