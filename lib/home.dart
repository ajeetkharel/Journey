import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:journey/write_journal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  final SharedPreferences prefs;

  const Home({super.key, required this.prefs});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    List<String> journeyList = widget.prefs.getStringList('journeyList') ?? [];
    FocusNode searchInputFocusNode = FocusNode();
    TextEditingController controller = TextEditingController();

    void performSearch(String query) {}

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.blueGrey[800],
        appBar: AppBar(
          elevation: 2,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blueGrey[800],
          titleSpacing: 8,
          title: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF455A64),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset('assets/logo.png', height: 35, width: 35),
                ),
                Expanded(
                  child: TextField(
                    focusNode: searchInputFocusNode,
                    controller: controller,
                    style: GoogleFonts.kulimPark(
                      textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                    cursorColor: Color(0xFFB0BEC5),
                    decoration: InputDecoration(
                        hintText: 'Search Journey',
                        hintStyle: GoogleFonts.kulimPark(
                          textStyle: const TextStyle(
                              color: Color(0xFFB0BEC5),
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                        border: InputBorder.none,
                        filled: true,
                        fillColor: const Color(0xFF455A64)),
                    onSubmitted: (value) {
                      performSearch(value);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: Color(0xFFB0BEC5),
                    size: 25,
                  ),
                  onPressed: () {
                    performSearch(controller.text);
                  },
                ),
              ],
            ),
          ),
        ),
        body: journeyList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Write your Story',
                      style: GoogleFonts.kulimPark(
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      'Tap the big PLUS button',
                      style: GoogleFonts.kulimPark(
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Image.asset("assets/downPointIcon.png",
                        height: 100, width: 100)
                  ],
                ),
              )
            : ListView.builder(
                itemCount: journeyList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      journeyList[index],
                      style: GoogleFonts.kulimPark(
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                },
              ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(5),
          color: const Color(0xFF263238),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () {},
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(110, 207, 216, 220),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.home,
                          color: Color.fromARGB(255, 255, 255, 255), size: 30),
                    ),
                    const Text(
                      'Journey',
                      style: TextStyle(color: Color(0xFFB0BEC5)),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () {},
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        color: Color(0xFFB0BEC5), size: 30),
                    Text(
                      'Calendar',
                      style: TextStyle(color: Color(0xFFB0BEC5)),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () {},
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(0, 207, 216, 220),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.add,
                          color: Color.fromARGB(0, 255, 255, 255), size: 30),
                    ),
                    const Text(
                      'Journey',
                      style: TextStyle(color: Color.fromARGB(0, 176, 190, 197)),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () {},
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 50,
                        decoration: const BoxDecoration(
                          color: Color(0xFFCCCCCC),
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(Icons.person,
                              color: Color(0xFF263238), size: 25),
                        )),
                    const Text(
                      'Profile',
                      style: TextStyle(color: Color(0xFFB0BEC5)),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () {},
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 50,
                        decoration: const BoxDecoration(
                          color: Color(0xFFCCCCCC),
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(Icons.more_horiz,
                              color: Color(0xFF263238), size: 25),
                        )),
                    const Text(
                      'More',
                      style: TextStyle(color: Color(0xFFB0BEC5)),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: FloatingActionButton(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(50.0))),
            onPressed: () {
              searchInputFocusNode.unfocus();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WriteJournal()));
            },
            backgroundColor: const Color(0xFFf44336),
            child: const SizedBox(
                height: 90,
                width: 60,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                )),
          ),
        ));
  }
}
