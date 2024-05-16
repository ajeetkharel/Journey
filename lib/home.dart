import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:journey/journal.dart';
import 'package:journey/signin.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class Home extends StatefulWidget {
  final SharedPreferences prefs;

  const Home({super.key, required this.prefs});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  late List<String> journeyList;
  late List<String> displayedJourneyList;
  late Map<String, List<String>> groupedJourneyList;
  late FocusNode searchInputFocusNode;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    journeyList = widget.prefs.getStringList(
            '${widget.prefs.getString('loggedInUserName')}.journeyList') ??
        [];
    displayedJourneyList = List.from(journeyList);
    groupedJourneyList = _groupJourneys(displayedJourneyList);
    searchInputFocusNode = FocusNode();
    searchInputFocusNode.unfocus();
    controller = TextEditingController();

    WidgetsBinding.instance.addObserver(this);
    refreshList();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshList();
    }
  }

  void refreshList() {
    setState(() {
      journeyList = widget.prefs.getStringList(
              '${widget.prefs.getString('loggedInUserName')}.journeyList') ??
          [];
      displayedJourneyList = List.from(journeyList);
      groupedJourneyList = _groupJourneys(displayedJourneyList);
    });
  }

  Map<String, List<String>> _groupJourneys(List<String> list) {
    return groupBy(list, (journal) {
      DateTime dateTime = DateTime.parse(
          widget.prefs.getString("$journal.date") ?? DateTime.now().toString());
      return DateFormat('d MMMM y - E').format(dateTime);
    });
  }

  void performSearch(String query) {
    setState(() {
      if (query.isNotEmpty) {
        displayedJourneyList = journeyList.where((journal) {
          String journalTitle =
              widget.prefs.getString("$journal.title") ?? "Untitled Journal";
          String shortDescription =
              widget.prefs.getString("$journal.shortDesc") ?? "No content";
          return journalTitle.toLowerCase().contains(query.toLowerCase()) ||
              shortDescription.toLowerCase().contains(query.toLowerCase());
        }).toList();
      } else {
        displayedJourneyList = List.from(journeyList);
      }
      groupedJourneyList = _groupJourneys(displayedJourneyList);
    });
  }

  void logout() {
    // Navigate to the login page
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) => SignInPage(
                prefs: widget.prefs,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        searchInputFocusNode.unfocus();
      },
      child: Scaffold(
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
            margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
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
                      cursorColor: const Color(0xFFB0BEC5),
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
                      onChanged: performSearch),
                ),
                IconButton(
                  icon: Icon(
                      (controller.text.isNotEmpty) ? Icons.search : Icons.close,
                      color: const Color(0xFFB0BEC5),
                      size: 25),
                  onPressed: () {
                    // clear the search input
                    controller.clear();
                  },
                ),
              ],
            ),
          ),
        ),
        body: displayedJourneyList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.prefs.getString("loggedInUserName")!.split(" ")[0]}, Write your Story',
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
            : RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    journeyList = widget.prefs.getStringList(
                            '${widget.prefs.getString('loggedInUserName')}.journeyList') ??
                        [];
                    displayedJourneyList = List.from(journeyList);
                    groupedJourneyList = _groupJourneys(displayedJourneyList);
                  });
                },
                child: ListView.builder(
                  itemCount: groupedJourneyList.keys.length,
                  itemBuilder: (context, index) {
                    String date = groupedJourneyList.keys.elementAt(index);
                    return Column(children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: Text(
                            date,
                            style: GoogleFonts.kulimPark(
                                textStyle: const TextStyle(
                                    color: Color(0xFFCFD8DC),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                      Column(
                        children: groupedJourneyList[date]!.map((journal) {
                          String journalTitle =
                              widget.prefs.getString("$journal.title") ??
                                  "Untitled Journal";
                          // extract the time from the date as 2:44 pm
                          DateTime dateTime = DateTime.parse(
                              widget.prefs.getString("$journal.date") ??
                                  DateTime.now().toString());
                          String time = DateFormat.jm().format(dateTime);

                          String shortDescription =
                              widget.prefs.getString("$journal.shortDesc") ??
                                  "No content";

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 2.0),
                            child: ListTile(
                              title: Container(
                                width: double.infinity,
                                // background color
                                decoration: BoxDecoration(
                                    color: const Color(0xFF455A64),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xFF263238),
                                        blurRadius: 3,
                                        offset: Offset(0, 2),
                                      )
                                    ]),
                                // left align
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        time,
                                        style: GoogleFonts.kulimPark(
                                          textStyle: const TextStyle(
                                              color: Color(0xFFCFD8DC),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 3.0),
                                        child: Text(
                                          journalTitle,
                                          style: GoogleFonts.kulimPark(
                                            textStyle: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                fontSize: 19,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          shortDescription,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.kulimPark(
                                            textStyle: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 186, 195, 199),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Journal(
                                            prefs: widget.prefs,
                                            journalId: journal)));
                              },
                            ),
                          );
                        }).toList(),
                      )
                    ]);
                  },
                ),
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
                        color: const Color.fromARGB(0, 207, 216, 220),
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
                child: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'Logout') {
                      logout();
                    }
                  },
                  offset: const Offset(0, -70),
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'Logout',
                      child: Text('Logout'),
                    ),
                  ],
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
            onPressed: () async {
              searchInputFocusNode.unfocus();
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Journal(prefs: widget.prefs)));
              setState(() {
                journeyList = widget.prefs.getStringList(
                        '${widget.prefs.getString('loggedInUserName')}.journeyList') ??
                    [];
                displayedJourneyList = List.from(journeyList);
                groupedJourneyList = _groupJourneys(displayedJourneyList);
              });
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
        ),
      ),
    );
  }
}
