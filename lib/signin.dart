import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: depend_on_referenced_packages
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:journey/home.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';



class SignInPage extends StatelessWidget {
  final SharedPreferences prefs;

  SignInPage({super.key, required this.prefs});

  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(height: 50),
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
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Form(
              key: _formKey,
              child: SizedBox(
                height: 80,
                child: TextFormField(
                  controller: _nameController,
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'Name',
                    hintStyle: GoogleFonts.kulimPark(
                      textStyle: const TextStyle(
                        color: Color(0xFFB0BEC5),
                        fontSize: 20,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(0),
                      borderSide: const BorderSide(
                        color: Colors.white,
                      ),
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
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  onChanged: (value) => {_formKey.currentState!.validate()},
                ),
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
          const SizedBox(height: 120),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    prefs.setString('userName', _nameController.text);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Home(prefs: prefs)));
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
