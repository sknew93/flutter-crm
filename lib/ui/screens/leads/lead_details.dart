import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:bottle_crm/bloc/lead_bloc.dart';
import 'package:bottle_crm/ui/widgets/bottom_navigation_bar.dart';
import 'package:bottle_crm/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:random_color/random_color.dart';

class LeadDetails extends StatefulWidget {
  LeadDetails();
  @override
  State createState() => _LeadDetailsState();
}

class _LeadDetailsState extends State<LeadDetails> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void showDeleteLeadAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
              leadBloc.currentLead.firstName +
                  " " +
                  leadBloc.currentLead.lastName,
              style: GoogleFonts.robotoSlab(
                  color: Theme.of(context).secondaryHeaderColor),
            ),
            content: Text(
              "Are you sure you want to delete this Lead?",
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
                    deleteLead();
                  },
                  child: Text(
                    "Delete",
                    style: GoogleFonts.robotoSlab(),
                  )),
            ],
          );
        });
  }

  deleteLead() async {
    setState(() {
      _isLoading = true;
    });
    Map result = await leadBloc.deleteLead(leadBloc.currentLead);
    setState(() {
      _isLoading = false;
    });
    if (result['error'] == false) {
      showToast(result['message']);
      Navigator.pushReplacementNamed(context, "/leads_list");
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
          deleteLead();
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
          "Lead Details",
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
                                    '${leadBloc.currentLead.title}',
                                    style: GoogleFonts.robotoSlab(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        fontSize: screenWidth / 20),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    leadBloc.currentLeadType,
                                    style: GoogleFonts.robotoSlab(
                                        color: leadBloc.currentLeadType ==
                                                "Open"
                                            ? Color.fromRGBO(117, 174, 51, 1)
                                            : Color.fromRGBO(234, 67, 53, 1),
                                        fontSize: screenWidth / 22),
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
                              "Name :",
                              style: GoogleFonts.robotoSlab(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                            child: Text(
                              '${leadBloc.currentLead.firstName} ${leadBloc.currentLead.lastName}',
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
                              leadBloc.currentLead.accountName,
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
                              "Mobile Number :",
                              style: GoogleFonts.robotoSlab(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                            child: Text(
                              leadBloc.currentLead.phone,
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
                              "Email Address :",
                              style: GoogleFonts.robotoSlab(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                            child: Text(
                              leadBloc.currentLead.email,
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
                              leadBloc.currentLead.status,
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
                              "Source :",
                              style: GoogleFonts.robotoSlab(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                            child: Text(
                              leadBloc.currentLead.source,
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
                              "Website :",
                              style: GoogleFonts.robotoSlab(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                            child: Text(
                              leadBloc.currentLead.website,
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
                              leadBloc.currentLead.description,
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
                              "Billing Address :",
                              style: GoogleFonts.robotoSlab(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                            child: Text(
                              leadBloc.currentLead.addressLine +
                                  ', ' +
                                  leadBloc.currentLead.street +
                                  ', ' +
                                  leadBloc.currentLead.city +
                                  ', ' +
                                  leadBloc.currentLead.state +
                                  ', ' +
                                  leadBloc.currentLead.postcode +
                                  ', ' +
                                  leadBloc.currentLead.country +
                                  '.',
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
                              leadBloc.currentLead.createdBy.firstName +
                                  ' ' +
                                  leadBloc.currentLead.createdBy.lastName,
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
                              leadBloc.currentLead.createdOn,
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
                              "Tags :",
                              style: GoogleFonts.robotoSlab(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: screenWidth / 24),
                            ),
                          ),
                          Container(
                            height: screenHeight / 33,
                            child: ListView.builder(
                                // physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: leadBloc.currentLead.tags.length,
                                itemBuilder:
                                    (BuildContext context, int tagIndex) {
                                  return Container(
                                    margin: EdgeInsets.only(right: 5.0),
                                    alignment: Alignment.center,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5.0),
                                    color: randomColor.randomColor(
                                        colorBrightness: ColorBrightness.light),
                                    child: Text(
                                      leadBloc.currentLead.tags[tagIndex]
                                          ['name'],
                                      style: GoogleFonts.robotoSlab(
                                          textStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.0)),
                                    ),
                                  );
                                }),
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
                              await leadBloc
                                  .updateCurrentEditLead(leadBloc.currentLead);
                              Navigator.pushNamed(context, '/create_lead');
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
                              showDeleteLeadAlertDialog(context);
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
