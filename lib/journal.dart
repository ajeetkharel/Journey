import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_quill/flutter_quill.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class Journal extends StatefulWidget {
  final SharedPreferences prefs;
  String journalId;

  Journal({super.key, required this.prefs, this.journalId = ''});

  @override
  State<Journal> createState() => _JournalState();
}

class _JournalState extends State<Journal> {
  QuillController _controller = QuillController.basic();
  TextEditingController controller = TextEditingController();
  final _editorFocusNode = FocusNode();
  final _textFocusNode = FocusNode();
  var _isReadOnly = false;
  String journalTitle = 'Untitled Journal';
  String journalContent = '';

  @override
  void initState() {
    super.initState();

    if (widget.journalId == '') {
      widget.journalId = DateTime.now().millisecondsSinceEpoch.toString();
    } else {
      String journalC =
          widget.prefs.getString("${widget.journalId}.content") ?? '';
      List<Map<String, dynamic>> content;
      try {
        content = journalC.isNotEmpty
            ? List<Map<String, dynamic>>.from(jsonDecode(journalC))
            : Document().toDelta().toJson();
      } catch (e) {
        content = Document().toDelta().toJson();
      }
      _controller = QuillController(
        document: Document.fromJson(content),
        selection: const TextSelection.collapsed(offset: 0),
      );
      setState(() {
        journalTitle = widget.prefs.getString("${widget.journalId}.title") ??
            'Untitled Journal';
        journalContent = journalC;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _editorFocusNode.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF455A64), // Set status bar color
    ));
    _controller.readOnly = _isReadOnly;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color(0xFF455A64),
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: Icon(
                    !_isReadOnly
                        ? Icons.check_rounded
                        : Icons.arrow_back_rounded,
                    color: const Color(0xFFB0BEC5),
                    size: 25),
                onPressed: () {
                  if (_isReadOnly) {
                    Navigator.pop(context, true);
                    return;
                  }
                  setState(() => _isReadOnly = !_isReadOnly);
                  List<Map<String, dynamic>> journalContent =
                      _controller.document.toDelta().toJson();
                  String journalShortDesc =
                      _controller.document.toPlainText().length > 250
                          ? _controller.document.toPlainText().substring(0, 50)
                          : _controller.document.toPlainText();
                  saveOrUpdateJournal(jsonEncode(journalContent), journalTitle,
                      journalShortDesc);
                },
              ),
            ),
            Expanded(
              child: TextField(
                focusNode: _textFocusNode,
                controller: controller,
                enabled: !_isReadOnly,
                style: GoogleFonts.kulimPark(
                  textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
                cursorColor: const Color(0xFFB0BEC5),
                decoration: InputDecoration(
                    hintText: journalTitle,
                    hintStyle: GoogleFonts.kulimPark(
                      textStyle: const TextStyle(
                          color: Color.fromARGB(255, 202, 213, 219),
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: const Color(0xFF455A64)),
                onSubmitted: (value) {
                  setState(() {
                    journalTitle = value;
                  });
                },
                onChanged: (value) => setState(() {
                  journalTitle = value;
                }),
              ),
            ),
            !_isReadOnly
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: const Icon(Icons.close,
                          color: Color(0xFFB0BEC5), size: 25),
                      onPressed: () {
                        setState(() => _isReadOnly = !_isReadOnly);
                      },
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert,
                          color: Color(0xFFB0BEC5), size: 25),
                      onSelected: (String result) async {
                        if (result == 'Delete') {
                          bool? shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Delete'),
                                content: const Text(
                                    'Are you sure you want to delete this journal?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Delete'),
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                  ),
                                ],
                              );
                            },
                          );

                          if (shouldDelete != null && shouldDelete) {
                            widget.prefs.remove("${widget.journalId}.content");
                            widget.prefs.remove("${widget.journalId}.title");
                            widget.prefs.remove("${widget.journalId}.date");
                            widget.prefs
                                .remove("${widget.journalId}.shortDesc");

                            List<
                                String> journeyList = widget.prefs.getStringList(
                                    '${widget.prefs.getString('loggedInUserId')}.journeyList') ??
                                [];
                            journeyList.remove(widget.journalId);
                            widget.prefs.setStringList(
                                '${widget.prefs.getString('loggedInUserId')}.journeyList',
                                journeyList);

                            if (mounted) {
                              Navigator.pop(context, true);
                            }
                          }
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'Delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (!_isReadOnly)
            QuillToolbar.simple(
              configurations: QuillSimpleToolbarConfigurations(
                  controller: _controller,
                  sharedConfigurations: const QuillSharedConfigurations(
                    locale: Locale('en'),
                  ),
                  showClipboardCopy: false,
                  showClipboardCut: false,
                  showClipboardPaste: false,
                  showSearchButton: false,
                  buttonOptions: const QuillSimpleToolbarButtonOptions(
                    base: QuillToolbarBaseButtonOptions(
                        iconSize: 13,
                        iconTheme: QuillIconTheme(
                          iconButtonSelectedData: IconButtonData(
                              color: Color.fromARGB(
                                255,
                                253,
                                254,
                                255,
                              ),
                              style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    Color.fromARGB(255, 32, 88, 114)),
                              )),
                          iconButtonUnselectedData: IconButtonData(
                              color: Color.fromARGB(255, 32, 88, 114)),
                        )),
                  )),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
              child: QuillEditor.basic(
                configurations: QuillEditorConfigurations(
                  controller: _controller,
                  sharedConfigurations: const QuillSharedConfigurations(
                    locale: Locale('de'),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(!_isReadOnly ? Icons.check_rounded : Icons.edit),
        onPressed: () {
          setState(() => _isReadOnly = !_isReadOnly);
          List<Map<String, dynamic>> journalContent =
              _controller.document.toDelta().toJson();
          String journalShortDesc =
              _controller.document.toPlainText().length > 250
                  ? _controller.document.toPlainText().substring(0, 50)
                  : _controller.document.toPlainText();
          saveOrUpdateJournal(
              jsonEncode(journalContent), journalTitle, journalShortDesc);
        },
      ),
    );
  }

  void saveOrUpdateJournal(String content, String title, String shortDesc) {
    widget.prefs.setString("${widget.journalId}.content", content);
    widget.prefs.setString("${widget.journalId}.title", title);
    widget.prefs
        .setString("${widget.journalId}.date", DateTime.now().toString());
    widget.prefs.setString(
        "${widget.journalId}.shortDesc", shortDesc.replaceAll('\n', ' '));

    List<String> journeyList = widget.prefs.getStringList(
            '${widget.prefs.getString('loggedInUserId')}.journeyList') ??
        [];
    if (!journeyList.contains(widget.journalId)) {
      journeyList.add(widget.journalId);
      widget.prefs.setStringList(
          '${widget.prefs.getString('loggedInUserId')}.journeyList',
          journeyList);
    }
  }
}
