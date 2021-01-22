import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_crm/bloc/opportunity_bloc.dart';
import 'package:flutter_crm/model/opportunities.dart';
import 'package:flutter_crm/ui/widgets/bottom_navigation_bar.dart';
import 'package:flutter_crm/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:random_color/random_color.dart';

class OpportunityDetails extends StatefulWidget {
  OpportunityDetails();
  @override
  State createState() => _OpportunityDetailsState();
}

class _OpportunityDetailsState extends State<OpportunityDetails> {
  @override
  void initState() {
    super.initState();
  }

  bool _isLoading = false;

  void showDeleteOpportunityAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
              opportunityBloc.currentOpportunity.name,
              style: GoogleFonts.robotoSlab(
                  color: Theme.of(context).secondaryHeaderColor),
            ),
            content: Text(
              "Are you sure you want to delete this Opportunity?",
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
                    deleteOpportunity();
                  },
                  child: Text(
                    "Delete",
                    style: GoogleFonts.robotoSlab(),
                  )),
            ],
          );
        });
  }

  deleteOpportunity() async {
    setState(() {
      _isLoading = true;
    });
    Map result = await opportunityBloc
        .deleteOpportunity(opportunityBloc.currentOpportunity);
    setState(() {
      _isLoading = false;
    });
    if (result['error'] == false) {
      showToast(result['message']);
      Navigator.pushReplacementNamed(context, "/opportunities");
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
      mainButton: FlatButton(
        child: Text('TRY AGAIN',
            style: GoogleFonts.robotoSlab(
                textStyle: TextStyle(color: Theme.of(context).accentColor))),
        onPressed: () {
          Navigator.of(context).pop(true);
          deleteOpportunity();
        },
      ),
      duration: Duration(seconds: 10),
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Opportunity Details",
          style: GoogleFonts.robotoSlab(),
        ),
      ),
      body: SingleChildScrollView(
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
                          '${opportunityBloc.currentOpportunity.name}',
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
                          "Amount :",
                          style: GoogleFonts.robotoSlab(
                              color: Theme.of(context).secondaryHeaderColor,
                              fontSize: screenWidth / 24),
                        ),
                      ),
                      Container(
                        child: Text(
                          opportunityBloc.currentOpportunity.amount,
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
                          opportunityBloc.currentOpportunity.account.name,
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
                          opportunityBloc.currentOpportunity.description,
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
                          "Stage :",
                          style: GoogleFonts.robotoSlab(
                              color: Theme.of(context).secondaryHeaderColor,
                              fontSize: screenWidth / 24),
                        ),
                      ),
                      Container(
                        child: Text(
                          opportunityBloc.currentOpportunity.stage,
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
                          "Lead Source :",
                          style: GoogleFonts.robotoSlab(
                              color: Theme.of(context).secondaryHeaderColor,
                              fontSize: screenWidth / 24),
                        ),
                      ),
                      Container(
                        child: Text(
                          opportunityBloc.currentOpportunity.leadSource,
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
                          "Probability :",
                          style: GoogleFonts.robotoSlab(
                              color: Theme.of(context).secondaryHeaderColor,
                              fontSize: screenWidth / 24),
                        ),
                      ),
                      Container(
                        child: Text(
                          opportunityBloc.currentOpportunity.probability
                                  .toString() +
                              "%",
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
                          DateFormat("dd MMM, yyyy").format(
                              DateFormat("yyyy-MM-dd").parse(
                                  opportunityBloc.currentOpportunity.closedOn)),
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
                          opportunityBloc
                                  .currentOpportunity.createdBy.firstName +
                              ' ' +
                              opportunityBloc
                                  .currentOpportunity.createdBy.lastName,
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
                          opportunityBloc.currentOpportunity.createdOn,
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
                            itemCount:
                                opportunityBloc.currentOpportunity.tags.length,
                            itemBuilder: (BuildContext context, int tagIndex) {
                              return Container(
                                margin: EdgeInsets.only(right: 5.0),
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: 5.0),
                                color: randomColor.randomColor(
                                    colorBrightness: ColorBrightness.light),
                                child: Text(
                                  opportunityBloc.currentOpportunity
                                      .tags[tagIndex]['name'],
                                  style: GoogleFonts.robotoSlab(
                                      textStyle: TextStyle(
                                          color: Colors.white, fontSize: 12.0)),
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
                          // await leadBloc
                          //     .updateCurrentEditLead(leadBloc.currentLead);
                          // Navigator.pushNamed(context, '/create_lead');
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
                                          color:
                                              Color.fromRGBO(117, 174, 51, 1),
                                          fontSize: screenWidth / 25)),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDeleteOpportunityAlertDialog(context);
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
                                          color: Color.fromRGBO(234, 67, 53, 1),
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
      bottomNavigationBar: BottomNavigationBarWidget(),
    );
  }
}
