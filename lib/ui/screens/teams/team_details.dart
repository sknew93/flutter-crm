import 'package:bottle_crm/bloc/team_bloc.dart';
import 'package:bottle_crm/ui/widgets/bottom_navigation_bar.dart';
import 'package:bottle_crm/ui/widgets/profile_pic_widget.dart';
import 'package:bottle_crm/utils/utils.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class TeamDetails extends StatefulWidget {
  TeamDetails();
  @override
  State createState() => _TeamDetailsState();
}

class _TeamDetailsState extends State<TeamDetails> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void showDeleteTeamAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
              teamBloc.currentTeam.name,
              style: GoogleFonts.robotoSlab(
                  color: Theme.of(context).secondaryHeaderColor),
            ),
            content: Text(
              "Are you sure you want to delete this team?",
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
                    deleteTeam();
                  },
                  child: Text(
                    "Delete",
                    style: GoogleFonts.robotoSlab(),
                  )),
            ],
          );
        });
  }

  deleteTeam() async {
    setState(() {
      _isLoading = true;
    });
    Map result = await teamBloc.deleteTeam(teamBloc.currentTeam);
    setState(() {
      _isLoading = false;
    });
    if (result['error'] == false) {
      showToast(result['message']);
      Navigator.pushReplacementNamed(context, "/teams");
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
          deleteTeam();
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
          "Team Details",
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
                        children: [
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: screenWidth * 0.7,
                                  child: Text(
                                    "${teamBloc.currentTeam.name}",
                                    style: GoogleFonts.robotoSlab(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        fontSize: screenWidth / 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.symmetric(vertical: 5.0),
                              child: Divider(color: bottomNavBarTextColor))
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
                              teamBloc.currentTeam.description,
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
                              "Assigned To :",
                              style: GoogleFonts.robotoSlab(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                            child: Row(
                              children: [
                                ProfilePicViewWidget(teamBloc.currentTeam.users
                                    .map((e) => e.profileUrl)
                                    .toList()),
                              ],
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
                              teamBloc.currentTeam.createdBy.firstName +
                                  ' ' +
                                  teamBloc.currentTeam.createdBy.lastName,
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
                              teamBloc.currentTeam.createdOn,
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
                              await teamBloc
                                  .updateCurrentEditTeam(teamBloc.currentTeam);
                              Navigator.pushNamed(context, '/create_team');
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
                                    child: SvgPicture.asset(
                                      'assets/images/Icon_edit_color.svg',
                                      width: screenWidth / 25,
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
                              showDeleteTeamAlertDialog(context);
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
                                    child: SvgPicture.asset(
                                      'assets/images/icon_delete_color.svg',
                                      width: screenWidth / 25,
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
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(),
    );
  }
}
