import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lista_contato/helpers/contact_helper.dart';
import 'package:lista_contato/ui/contact_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper();

  List<Contact> contacts = new List<Contact>();

  @override
  void initState() {
    super.initState();

    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: _showContactPage,
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return _contactCard(context, index);
          },
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index){
      return GestureDetector(
        onTap: () {
          _showContactPage(contact: contacts[index]);
        },
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: contacts[index].img != null ?
                          FileImage(File(contacts[index].img)) :
                          AssetImage("images/person.png")
                    )
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(contacts[index].name ?? "",
                        style: TextStyle(fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(contacts[index].email ?? "",
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(contacts[index].phone ?? "",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
  }

  _showContactPage({Contact contact}) async{

    final recContact = await Navigator.push(context,
      MaterialPageRoute(
        builder: (context) => ContactPage(contact: contact,))
      );

    if(recContact != null){
      if(contact != null){
        await helper.updateContact(recContact);
        _getAllContacts();
      }else{
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }

  }

  void _getAllContacts(){
    helper.getAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }

}
