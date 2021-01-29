import 'package:bottle_crm/bloc/opportunity_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bottle_crm/bloc/account_bloc.dart';
import 'package:bottle_crm/bloc/contact_bloc.dart';
import 'package:bottle_crm/bloc/document_bloc.dart';
import 'package:bottle_crm/bloc/lead_bloc.dart';
import 'package:bottle_crm/bloc/user_bloc.dart';
import 'package:bottle_crm/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';

class SquareFloatingActionButton extends StatelessWidget {
  final String _route;
  final String btnTitle;
  final String moduleName;

  SquareFloatingActionButton(this._route, this.btnTitle, this.moduleName);

  void showAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
              "Alert",
              style: GoogleFonts.robotoSlab(
                  color: Theme.of(context).secondaryHeaderColor),
            ),
            content: Text(
              "You don't have any contacts, Please create contact first.",
              style: GoogleFonts.robotoSlab(fontSize: 15.0),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () {
                    currentBottomNavigationIndex = "3";
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/contacts");
                  },
                  child: Text(
                    "Create",
                    style: GoogleFonts.robotoSlab(),
                  )),
              CupertinoDialogAction(
                  textStyle: TextStyle(color: Colors.red),
                  isDefaultAction: true,
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.robotoSlab(),
                  )),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (moduleName == "Accounts" && contactBloc.contacts.length == 0) {
          showAlertDialog(context);
        } else {
          accountBloc.cancelCurrentEditAccount();
          leadBloc.cancelCurrentEditLead();
          contactBloc.cancelCurrentEditContact();
          userBloc.cancelCurrentEditUser();
          documentBLoc.cancelCurrentEditDocument();
          opportunityBloc.cancelCurrentEditOpportunity();
          Navigator.pushNamed(context, _route);
        }
      },
      child: Container(
        width: screenWidth * 0.4,
        padding: EdgeInsets.symmetric(vertical: 5.0),
        decoration: BoxDecoration(
            color: Colors.red[50],
            border: Border.all(color: Color.fromRGBO(234, 67, 53, 1))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              child: Icon(
                Icons.add,
                size: screenWidth / 18,
                color: Color.fromRGBO(234, 67, 53, 1),
              ),
            ),
            Container(
              child: Text(
                btnTitle,
                style: GoogleFonts.robotoSlab(
                    textStyle: TextStyle(
                        color: Color.fromRGBO(234, 67, 53, 1),
                        fontSize: screenWidth / 25)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
