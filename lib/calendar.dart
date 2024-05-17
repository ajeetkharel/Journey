import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:journey/home.dart';
import 'package:journey/journal.dart';
import 'package:journey/profile.dart';
import 'package:journey/signin.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  final SharedPreferences prefs;

  const Calendar({super.key, required this.prefs});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> with WidgetsBindingObserver {
  late List<String> journeyList;
  late List<String> displayedJourneyList;
  late Map<String, List<String>> groupedJourneyList;
  late FocusNode searchInputFocusNode;
  late TextEditingController controller;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    journeyList = widget.prefs.getStringList(
            '${widget.prefs.getString('loggedInUserId')}.journeyList') ??
        [];
    displayedJourneyList = journeyList.where((journal) {
      DateTime dateTime = DateTime.parse(
          widget.prefs.getString("$journal.date") ?? DateTime.now().toString());
      return isSameDay(_focusedDay, dateTime);
    }).toList();
    groupedJourneyList = _groupJourneys(displayedJourneyList);
    searchInputFocusNode = FocusNode();
    searchInputFocusNode.unfocus();
    controller = TextEditingController();

    WidgetsBinding.instance.addObserver(this);
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
              '${widget.prefs.getString('loggedInUserId')}.journeyList') ??
          [];
      displayedJourneyList = journeyList.where((journal) {
        DateTime dateTime = DateTime.parse(
            widget.prefs.getString("$journal.date") ??
                DateTime.now().toString());
        return isSameDay(_focusedDay, dateTime);
      }).toList();
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

  bool hasJournal(DateTime date) {
    return journeyList.any((journal) {
      DateTime dateTime = DateTime.parse(
          widget.prefs.getString("$journal.date") ?? DateTime.now().toString());
      return isSameDay(date, dateTime);
    });
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
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
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
                      (controller.text.isEmpty) ? Icons.search : Icons.close,
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
        body: Column(
          children: [
            Container(
              color: const Color(0xFF263238),
              margin: const EdgeInsets.only(top: 10),
              child: TableCalendar(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    displayedJourneyList = journeyList.where((journal) {
                      DateTime dateTime = DateTime.parse(
                          widget.prefs.getString("$journal.date") ??
                              DateTime.now().toString());
                      return isSameDay(_selectedDay, dateTime);
                    }).toList();
                    groupedJourneyList = _groupJourneys(displayedJourneyList);
                  });
                },
                calendarStyle: const CalendarStyle(
                  defaultTextStyle: TextStyle(color: Colors.white),
                  weekendTextStyle: TextStyle(color: Colors.white),
                  weekNumberTextStyle: TextStyle(color: Colors.white),
                  disabledTextStyle: TextStyle(color: Colors.white),
                  outsideTextStyle: TextStyle(color: Colors.white),
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                    color: Color.fromARGB(255, 41, 169, 228),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Color.fromARGB(255, 129, 81, 7),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(color: Colors.white),
                  selectedTextStyle: TextStyle(color: Colors.white),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
                  leftChevronIcon:
                      Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon:
                      Icon(Icons.chevron_right, color: Colors.white),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white),
                  weekendStyle: TextStyle(color: Colors.white),
                ),
                availableGestures: AvailableGestures.all,
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (hasJournal(day)) {
                      return const Positioned(
                        bottom: 8,
                        child: Icon(Icons.circle, size: 5.0, color: Color.fromARGB(255, 255, 255, 255)),
                      );
                    } else {
                      return Container();
                    }
                  },
                  headerTitleBuilder: (context, day) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat.yMMMM().format(_focusedDay),
                          style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedDay = DateTime.now();
                              _focusedDay = DateTime.now();
                              refreshList();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              backgroundColor:
                                  const Color.fromARGB(255, 70, 88, 97),
                              fixedSize: const Size(40, 25),
                              padding: EdgeInsets.zero),
                          child: const Text('Today',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 167, 192, 204),
                                  fontSize: 12)),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            displayedJourneyList.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 18.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No Journeys Found',
                            style: GoogleFonts.kulimPark(
                              textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Expanded(
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

                              String shortDescription = widget.prefs
                                      .getString("$journal.shortDesc") ??
                                  "No content";

                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 2.0),
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
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              shortDescription,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.kulimPark(
                                                textStyle: const TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 186, 195, 199),
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  onTap: () async {
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Journal(
                                                prefs: widget.prefs,
                                                journalId: journal)));
                                    setState(() {
                                      journeyList = widget.prefs.getStringList(
                                              '${widget.prefs.getString('loggedInUserId')}.journeyList') ??
                                          [];
                                      displayedJourneyList =
                                          journeyList.where((journal) {
                                        DateTime dateTime = DateTime.parse(
                                            widget.prefs.getString(
                                                    "$journal.date") ??
                                                DateTime.now().toString());
                                        return isSameDay(
                                            _selectedDay, dateTime);
                                      }).toList();
                                      groupedJourneyList =
                                          _groupJourneys(displayedJourneyList);
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          )
                        ]);
                      },
                    ),
                  ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(5),
          color: const Color(0xFF263238),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          Home(prefs: widget.prefs),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 200),
                    ),
                  );
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.home, color: Color(0xFFB0BEC5), size: 30),
                    Text(
                      'Journey',
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
                        color: const Color.fromARGB(110, 207, 216, 220),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.calendar_month_outlined,
                          color: Color.fromARGB(255, 255, 255, 255), size: 30),
                    ),
                    const Text(
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
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ProfilePage(prefs: widget.prefs);
                  }));
                },
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
                        '${widget.prefs.getString('loggedInUserId')}.journeyList') ??
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
