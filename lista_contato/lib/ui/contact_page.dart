import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lista_contato/helpers/contact_helper.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {

  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  Contact _editedContact;

  bool _userEdited = false;

  @override
  void initState() {
    super.initState();

    if(widget.contact == null ){
      _editedContact = new Contact();
    }else{
      _editedContact = Contact.fromMap(widget.contact.toMap());

      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }


  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editedContact.name ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if(_editedContact.name != null && _editedContact.name.isNotEmpty){
              Navigator.pop(context, _editedContact);
            }else{
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () async {
                  _showOptions(context);
                },
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: _editedContact.img != null ?
                          FileImage(File(_editedContact.img)) :
                          AssetImage("images/person.png"),
                          fit: BoxFit.cover
                      )
                  ),
                ),
              ),
              TextField(
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (texto) {
                  _userEdited = true;
                  setState(() {
                    _editedContact.name = texto;
                  });
                },
                controller: _nameController,
                focusNode: _nameFocus,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Email"),
                onChanged: (texto) {
                  _userEdited = true;
                  _editedContact.email = texto;
                },
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Phone"),
                onChanged: (texto) {
                  _userEdited = true;
                  _editedContact.phone = texto;
                },
                keyboardType: TextInputType.phone,
                controller: _phoneController,
              )
            ],
          ),
        ),
      )
    );
  }

  Future<bool> _requestPop(){
    if(_userEdited){
      showDialog(context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Descartar alterações?"),
            content: Text("Se sair as alterações serão perdidas"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: (){
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("Sim"),
                onPressed: (){
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              )
            ],
          );
        }
      );
      return Future.value(false);
    }else{
      return Future.value(true);
    }

  }

  void _showOptions(BuildContext context){
    showModalBottomSheet(
        context: context,
        builder: (context){
          return BottomSheet(
            onClosing: () {},
            builder: (context){
              return Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: FlatButton(
                        child: Text("Galeria",style: TextStyle(color: Colors.red, fontSize: 20),),
                        onPressed: (){
                          Navigator.pop(context);

                          ImagePicker.pickImage(source: ImageSource.gallery).then((file) {
                            if(file == null) return;

                            setState(() {
                              _editedContact.img = file.path;
                            });

                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: FlatButton(
                        child: Text("Camera",style: TextStyle(color: Colors.red, fontSize: 20),),
                        onPressed: (){
                          ImagePicker.pickImage(source: ImageSource.camera).then((file) {
                            if(file == null) return;

                            setState(() {
                              _editedContact.img = file.path;
                            });

                          });
                        },
                      ),
                    ),

                  ],
                ),
              );
            },
          );
        }
    );
  }

}
