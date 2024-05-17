// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final SharedPreferences prefs;

  const ProfilePage({super.key, required this.prefs});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.prefs.getString("${widget.prefs.getString("loggedInUserId")}.name") ?? '';
  }

  void _saveName() {
    List<String> names = widget.prefs.getStringList('userNames') ?? [];
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name cannot be empty!'),
        ),
      );
      return;
    } else if (_nameController.text == widget.prefs.getString("${widget.prefs.getString("loggedInUserId")}.name")) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name saved!'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    } else if (!names.contains(_nameController.text)) {
      names.remove(widget.prefs.getString("${widget.prefs.getString("loggedInUserId")}.name"));
      names.add(_nameController.text);
      widget.prefs.setStringList('userNames', names);
      widget.prefs.setString('loggedInUserId', _nameController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name saved!'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile name already exists!'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.blueGrey[800],
          titleTextStyle: GoogleFonts.kulimPark(
            fontSize: 18,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
            size: 20,
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            TextButton(
              onPressed: _saveName,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
