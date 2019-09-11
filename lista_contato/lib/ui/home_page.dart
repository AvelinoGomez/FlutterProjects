import 'package:flutter/material.dart';
import 'package:lista_contato/helpers/contact_helper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper();


  @override
  void initState() {
    super.initState();

    Contact c = Contact();
    c.name = "Avelino";
    c.email = "avelino.gomez.jr@hotmail.com";
    c.phone = "994381513";
    c.img = "img.test";

    helper.saveContact(c);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
