import 'package:bottle_crm/bloc/contact_bloc.dart';
import 'package:bottle_crm/bloc/lead_bloc.dart';
import 'package:bottle_crm/bloc/team_bloc.dart';
import 'package:bottle_crm/ui/widgets/bottom_navigation_bar.dart';
import 'package:bottle_crm/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';

class CreateTeam extends StatefulWidget {
  CreateTeam();
  @override
  State createState() => _CreateTeamState();
}

class _CreateTeamState extends State<CreateTeam> {
  final GlobalKey<FormState> _createTeamFormKey = GlobalKey<FormState>();
  FilePickerResult result;
  PlatformFile file;
  bool _isLoading = false;
  Map _errors;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
          _saveForm();
        },
      ),
      duration: Duration(seconds: 10),
    )..show(context);
  }

  _saveForm() async {
    setState(() {
      _errors = null;
    });

    if (!_createTeamFormKey.currentState.validate()) {
      return;
    }
    _createTeamFormKey.currentState.save();
    Map _result;

    setState(() {
      _isLoading = true;
    });

    if (teamBloc.currentEditTeamId == null) {
      _result = await teamBloc.createTeam();
    } else {
      _result = await teamBloc.editTeam();
    }

    setState(() {
      _isLoading = false;
    });

    if (_result['error'] == false) {
      setState(() {
        _errors = null;
      });
      showToast(_result['message']);
      Navigator.pushReplacementNamed(context, '/teams');
    } else if (_result['error'] == true) {
      setState(() {
        _errors = _result['errors'];
      });
    } else {
      setState(() {
        _errors = null;
      });
      showErrorMessage(context, "Something went wrong.");
    }
  }

  Widget _buildForm() {
    return Container(
        child: Form(
            key: _createTeamFormKey,
            child: Column(children: [
              Container(
                child: Column(
                  children: [
                    Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(bottom: 5.0),
                        child: RichText(
                          text: TextSpan(
                            text: 'Name',
                            style: GoogleFonts.robotoSlab(
                                textStyle: TextStyle(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: screenWidth / 25)),
                            children: <TextSpan>[
                              TextSpan(
                                  text: '*',
                                  style: GoogleFonts.robotoSlab(
                                      textStyle: TextStyle(color: Colors.red))),
                              TextSpan(
                                  text: ' :', style: GoogleFonts.robotoSlab())
                            ],
                          ),
                        )),
                    Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        maxLines: 1,
                        initialValue: teamBloc.currentEditTeam['name'],
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(12.0),
                            enabledBorder: boxBorder(),
                            focusedErrorBorder: boxBorder(),
                            focusedBorder: boxBorder(),
                            errorBorder: boxBorder(),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "Enter Name",
                            errorStyle: GoogleFonts.robotoSlab(),
                            hintStyle: GoogleFonts.robotoSlab(
                                textStyle: TextStyle(fontSize: 14.0))),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'This field is required.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          teamBloc.currentEditTeam['name'] = value;
                        },
                      ),
                    ),
                    _errors != null && _errors['name'] != null
                        ? Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _errors['name'][0],
                              style: GoogleFonts.robotoSlab(
                                  textStyle: TextStyle(
                                      color: Colors.red[700], fontSize: 12.0)),
                            ),
                          )
                        : Container(),
                    Divider(color: Colors.grey)
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(bottom: 5.0),
                        child: RichText(
                          text: TextSpan(
                            text: 'Description',
                            style: GoogleFonts.robotoSlab(
                                textStyle: TextStyle(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: screenWidth / 25)),
                            children: <TextSpan>[
                              TextSpan(
                                  text: '*',
                                  style: GoogleFonts.robotoSlab(
                                      textStyle: TextStyle(color: Colors.red))),
                              TextSpan(
                                  text: ' :', style: GoogleFonts.robotoSlab())
                            ],
                          ),
                        )),
                    Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        maxLines: 5,
                        initialValue: teamBloc.currentEditTeam['description'],
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(12.0),
                            enabledBorder: boxBorder(),
                            focusedErrorBorder: boxBorder(),
                            focusedBorder: boxBorder(),
                            errorBorder: boxBorder(),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: 'Enter Description',
                            errorStyle: GoogleFonts.robotoSlab(),
                            hintStyle: GoogleFonts.robotoSlab(
                                textStyle: TextStyle(fontSize: 14.0))),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'This field is required.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          teamBloc.currentEditTeam['description'] = value;
                        },
                      ),
                    ),
                    _errors != null && _errors['description'] != null
                        ? Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _errors['description'][0],
                              style: GoogleFonts.robotoSlab(
                                  textStyle: TextStyle(
                                      color: Colors.red[700], fontSize: 12.0)),
                            ),
                          )
                        : Container(),
                    Divider(color: Colors.grey)
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(bottom: 5.0),
                        child: RichText(
                          text: TextSpan(
                            text: 'Assigned Users',
                            style: GoogleFonts.robotoSlab(
                                textStyle: TextStyle(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: screenWidth / 25)),
                            children: <TextSpan>[
                              TextSpan(
                                  text: '*',
                                  style: GoogleFonts.robotoSlab(
                                      textStyle: TextStyle(color: Colors.red))),
                              TextSpan(
                                  text: ' :', style: GoogleFonts.robotoSlab())
                            ],
                          ),
                        )),
                    Container(
                      margin: EdgeInsets.only(bottom: 5.0),
                      child: Focus(
                        child: MultiSelectFormField(
                          border: boxBorder(),
                          fillColor: Colors.white,
                          autovalidate: false,
                          dataSource: leadBloc.usersObjForDropdown,
                          textField: 'name',
                          valueField: 'id',
                          okButtonLabel: 'OK',
                          chipLabelStyle: GoogleFonts.robotoSlab(
                              textStyle: TextStyle(color: Colors.black)),
                          dialogTextStyle: GoogleFonts.robotoSlab(),
                          cancelButtonLabel: 'CANCEL',
                          hintWidget: Text(
                            "Please choose one or more",
                            style: GoogleFonts.robotoSlab(),
                          ),
                          title: Text(
                            "Assigned To",
                            style: GoogleFonts.robotoSlab(),
                          ),
                          initialValue:
                              teamBloc.currentEditTeam['assign_users'],
                          validator: (value) {
                            if (value.length == 0) {
                              return 'This field is required.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            if (value == null) return;
                            teamBloc.currentEditTeam['assign_users'] = value;
                          },
                        ),
                      ),
                    ),
                    _errors != null && _errors['users'] != null
                        ? Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _errors['users'],
                              style: GoogleFonts.robotoSlab(
                                  textStyle: TextStyle(
                                      color: Colors.red[700], fontSize: 12.0)),
                            ),
                          )
                        : Container(),
                    Divider(color: Colors.grey)
                  ],
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        _saveForm();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: screenHeight * 0.06,
                        width: screenWidth * 0.5,
                        decoration: BoxDecoration(
                          color: submitButtonColor,
                          borderRadius: BorderRadius.all(Radius.circular(3.0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              teamBloc.currentEditTeamId != null
                                  ? 'Update Team'
                                  : 'Create Team',
                              style: GoogleFonts.robotoSlab(
                                  textStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: screenWidth / 24)),
                            ),
                            SvgPicture.asset('assets/images/arrow_forward.svg')
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        contactBloc.cancelCurrentEditContact();
                        Navigator.pop(context);
                      },
                      child: Container(
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.robotoSlab(
                              textStyle: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: bottomNavBarTextColor,
                                  fontSize: screenWidth / 24)),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ])));
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
          "Create Team",
          style: GoogleFonts.robotoSlab(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(10.0),
            child: Container(
              color: Colors.white,
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: _buildForm(),
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
