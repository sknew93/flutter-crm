import 'package:bottle_crm/bloc/case_bloc.dart';
import 'package:bottle_crm/ui/widgets/bottom_navigation_bar.dart';
import 'package:bottle_crm/utils/utils.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CaseDetails extends StatefulWidget {
  CaseDetails();
  @override
  State createState() => _CaseDetailsState();
}

class _CaseDetailsState extends State<CaseDetails> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void showdeleteCaseAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
              caseBloc.currentCase.name,
              style: GoogleFonts.robotoSlab(
                  color: Theme.of(context).secondaryHeaderColor),
            ),
            content: Text(
              "Are you sure you want to delete this Case?",
              style: GoogleFonts.robotoSlab(fontSize: 15.0),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.robotoSlab(),
                  )),
              CupertinoDialogAction(
                  textStyle: TextStyle(color: Colors.red),
                  isDefaultAction: true,
                  onPressed: () async {
                    Navigator.pop(context);
                    deleteCase();
                  },
                  child: Text(
                    "Delete",
                    style: GoogleFonts.robotoSlab(),
                  )),
            ],
          );
        });
  }

  deleteCase() async {
    setState(() {
      _isLoading = true;
    });
    Map result = await caseBloc.deleteCase(caseBloc.currentCase);
    setState(() {
      _isLoading = false;
    });
    if (result['error'] == false) {
      showToast(result['message']);
      Navigator.pushReplacementNamed(context, "/cases");
    } else if (result['error'] == true) {
      showToast(result['message']);
    } else {
      showErrorMessage(context, 'Something went wrong');
    }
  }

  void showErrorMessage(BuildContext context, String errorContent) {
    Flushbar(
      backgroundColor: Colors.white,
      messageText: Text(errorContent,
          style:
              GoogleFonts.robotoSlab(textStyle: TextStyle(color: Colors.red))),
      isDismissible: false,
      mainButton: TextButton(
        child: Text('TRY AGAIN',
            style: GoogleFonts.robotoSlab(
                textStyle: TextStyle(color: Theme.of(context).accentColor))),
        onPressed: () {
          Navigator.of(context).pop(true);
          deleteCase();
        },
      ),
      duration: Duration(seconds: 10),
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    Widget loadingIndicator = _isLoading
        ? new Container(
            color: Colors.transparent,
            width: 300.0,
            height: 300.0,
            child: new Padding(
                padding: const EdgeInsets.all(5.0),
                child: new Center(child: new CircularProgressIndicator())),
          )
        : new Container();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Case Details",
          style: GoogleFonts.robotoSlab(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 5.0),
                            child: Text(
                              "Name :",
                              style: GoogleFonts.robotoSlab(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                            child: Text(
                              '${caseBloc.currentCase.name}',
                              style: GoogleFonts.robotoSlab(
                                  color: bottomNavBarTextColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.symmetric(vertical: 5.0),
                              child: Divider(color: Colors.grey))
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 5.0),
                            child: Text(
                              "Account Name :",
                              style: GoogleFonts.robotoSlab(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                            child: Text(
                              (caseBloc.currentCase.account.name != null)
                                  ? caseBloc.currentCase.name
                                  : "N/A",
                              style: GoogleFonts.robotoSlab(
                                  color: bottomNavBarTextColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.symmetric(vertical: 5.0),
                              child: Divider(color: Colors.grey))
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 5.0),
                            child: Text(
                              "Close Date :",
                              style: GoogleFonts.robotoSlab(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                            child: Text(
                              (caseBloc.currentCase.closedOn != "")
                                  ? (DateFormat("dd MMM, yyyy").format(
                                      DateFormat("yyyy-MM-dd").parse(
                                          caseBloc.currentCase.closedOn)))
                                  : "N/A",
                              style: GoogleFonts.robotoSlab(
                                  color: bottomNavBarTextColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.symmetric(vertical: 5.0),
                              child: Divider(color: Colors.grey))
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 5.0),
                            child: Text(
                              "Description :",
                              style: GoogleFonts.robotoSlab(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                            child: Text(
                              caseBloc.currentCase.description,
                              style: GoogleFonts.robotoSlab(
                                  color: bottomNavBarTextColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.symmetric(vertical: 5.0),
                              child: Divider(color: Colors.grey))
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 5.0),
                            child: Text(
                              "Status :",
                              style: GoogleFonts.robotoSlab(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                            child: Text(
                              caseBloc.currentCase.status,
                              style: GoogleFonts.robotoSlab(
                                  color: bottomNavBarTextColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.symmetric(vertical: 5.0),
                              child: Divider(color: Colors.grey))
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 5.0),
                            child: Text(
                              "Priority :",
                              style: GoogleFonts.robotoSlab(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                            child: Text(
                              caseBloc.currentCase.priority,
                              style: GoogleFonts.robotoSlab(
                                  color: bottomNavBarTextColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.symmetric(vertical: 5.0),
                              child: Divider(color: Colors.grey))
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 5.0),
                            child: Text(
                              "Type of Case :",
                              style: GoogleFonts.robotoSlab(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                            child: Text(
                              caseBloc.currentCase.caseType,
                              style: GoogleFonts.robotoSlab(
                                  color: bottomNavBarTextColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.symmetric(vertical: 5.0),
                              child: Divider(color: Colors.grey))
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 5.0),
                            child: Text(
                              "Created By :",
                              style: GoogleFonts.robotoSlab(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                            child: Text(
                              caseBloc.currentCase.createdBy.firstName +
                                  ' ' +
                                  caseBloc.currentCase.createdBy.lastName,
                              style: GoogleFonts.robotoSlab(
                                  color: bottomNavBarTextColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.symmetric(vertical: 5.0),
                              child: Divider(color: Colors.grey))
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 5.0),
                            child: Text(
                              "Created On :",
                              style: GoogleFonts.robotoSlab(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                            child: Text(
                              caseBloc.currentCase.createdOnText,
                              style: GoogleFonts.robotoSlab(
                                  color: bottomNavBarTextColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.symmetric(vertical: 5.0),
                              child: Divider(color: Colors.grey))
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await caseBloc
                                  .updateCurrentEditCase(caseBloc.currentCase);
                              Navigator.pushNamed(context, '/create_case');
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300])),
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 15.0),
                              child: Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 10.0),
                                    child: Icon(
                                      Icons.edit_outlined,
                                      color: Color.fromRGBO(117, 174, 51, 1),
                                      size: screenWidth / 18,
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      "Edit",
                                      style: GoogleFonts.robotoSlab(
                                          textStyle: TextStyle(
                                              color: Color.fromRGBO(
                                                  117, 174, 51, 1),
                                              fontSize: screenWidth / 25)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showdeleteCaseAlertDialog(context);
                            },
                            child: Container(
                              margin: EdgeInsets.only(left: 10.0),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300])),
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 15.0),
                              child: Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 10.0),
                                    child: Icon(
                                      Icons.delete_outlined,
                                      color: Color.fromRGBO(234, 67, 53, 1),
                                      size: screenWidth / 18,
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      "Delete",
                                      style: GoogleFonts.robotoSlab(
                                          textStyle: TextStyle(
                                              color: Color.fromRGBO(
                                                  234, 67, 53, 1),
                                              fontSize: screenWidth / 25)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          new Align(
            child: loadingIndicator,
            alignment: FractionalOffset.center,
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(),
    );
  }
}
