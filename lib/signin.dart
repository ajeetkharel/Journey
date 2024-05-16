import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: depend_on_referenced_packages
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:journey/home.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  final SharedPreferences prefs;

  const SignInPage({super.key, required this.prefs});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late List<String> names;

  @override
  void initState() {
    super.initState();
    _loadUserNames();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserNames();
  }

  void _loadUserNames() {
    names = widget.prefs.getStringList('userNames') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    List<String> names = widget.prefs.getStringList('userNames') ?? [];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
              padding: const EdgeInsets.fromLTRB(30, 50, 10, 0),
              child: Column(children: [
                Row(
                  children: [
                    Image.asset("assets/logo.png", height: 68, width: 68),
                    const SizedBox(width: 10),
                    Container(
                      height: 50,
                      width: 1,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    // font family - Pacifico
                    Text('Journey',
                        style: GoogleFonts.pacifico(
                          textStyle: const TextStyle(
                            fontSize: 48,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                offset: Offset(0, 3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    'Where every keystroke becomes a treasure trove of memories',
                    style: GoogleFonts.kulimPark(
                      textStyle: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFFCFD8DC),
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
                const SizedBox(height: 90),
              ])),
          Center(
            child: Text(
              'What\'s your name?',
              style: GoogleFonts.kulimPark(
                textStyle: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.solid,
                  decorationColor: Colors.white,
                  decorationThickness: 1,
                ),
              ),
            ),
          ),
          Text(
            "Enter your name or select a saved profile",
            style: GoogleFonts.kulimPark(
              textStyle: const TextStyle(
                fontSize: 15,
                color: Color(0xFFB0BEC5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Form(
              key: _formKey,
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextFormField(
                    controller: _nameController,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: 'login as...',
                      hintStyle: GoogleFonts.kulimPark(
                        textStyle: const TextStyle(
                            color: Color(0xFFB0BEC5),
                            fontSize: 17,
                            fontWeight: FontWeight.w500),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF455A64),
                      errorStyle: GoogleFonts.kulimPark(
                        textStyle: const TextStyle(
                          color: Color.fromARGB(255, 255, 38, 0),
                          fontSize: 15,
                        ),
                      ),
                    ),
                    style: GoogleFonts.kulimPark(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter or select a name';
                      }
                      return null;
                    },
                  ),
                  PopupMenuButton<String>(
                    onSelected: (String value) {
                      _nameController.text = value;
                    },
                    itemBuilder: (BuildContext context) {
                      return names.map((String name) {
                        return PopupMenuItem<String>(
                          value: name,
                          child: Text(name),
                        );
                      }).toList();
                    },
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: const Color(0xFFB0BEC5),
                      size: names.isEmpty ? 0 : 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text("Or",
              style: GoogleFonts.kulimPark(
                textStyle: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              )),
          const SizedBox(height: 50),
          ElevatedButton.icon(
            onPressed: () async {},
            icon: Image.asset("assets/google.png", height: 25, width: 25),
            label: Text("Continue with Google",
                style: GoogleFonts.kulimPark(
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFECEFF1),
                  ),
                )),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 69, 92, 102),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5),
          ),
          const SizedBox(height: 90),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.prefs
                        .setString('loggedInUserName', _nameController.text);
                    if (!names.contains(_nameController.text)) {
                      names.add(_nameController.text);
                    }
                    widget.prefs.setStringList('userNames', names);

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Home(prefs: widget.prefs)));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB92121),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Add this
                  children: <Widget>[
                    Text(
                      "Start",
                      style: GoogleFonts.kulimPark(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFECEFF1),
                        ),
                      ),
                    ),
                    const SizedBox(
                        width:
                            10), // Optional: add space between the text and icon
                    const FaIcon(FontAwesomeIcons.angleRight,
                        size: 25, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("By continuing, you are indicating that you accept our ",
                  style: GoogleFonts.kulimPark(
                    textStyle: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  )),
              Text("Terms of Service",
                  style: GoogleFonts.kulimPark(
                    textStyle: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  )),
              Text(" and ",
                  style: GoogleFonts.kulimPark(
                    textStyle: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  )),
              Text("Privacy Policy.",
                  style: GoogleFonts.kulimPark(
                    textStyle: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ))
            ],
          ),
        ],
      ),
      backgroundColor: Colors.blueGrey[800],
    );
  }
}
