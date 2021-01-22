import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_crm/bloc/contact_bloc.dart';
import 'package:flutter_crm/bloc/lead_bloc.dart';
import 'package:flutter_crm/ui/widgets/bottom_navigation_bar.dart';
import 'package:flutter_crm/utils/utils.dart';
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
  List _myActivities;
  String _selectedStatus = 'Open';
  List countiresForDropDown = leadBloc.countries;
  bool _isLoading = false;

  FocusNode _focusErr;
  FocusNode _firstNameFocusNode = FocusNode();
  FocusNode _lastNameFocusNode = FocusNode();
  FocusNode _phoneFocusNode = FocusNode();
  FocusNode _emailAddressFocusNode = FocusNode();
  Map _errors;

  @override
  void initState() {
    super.initState();
  }

  focusError() {
    setState(() {
      FocusManager.instance.primaryFocus.unfocus();
      Focus.of(context).requestFocus(_focusErr);
    });
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
          _saveForm();
        },
      ),
      duration: Duration(seconds: 10),
    )..show(context);
  }

  _saveForm() async {
    // _focusErr = null;
    // setState(() {
    //   _errors = null;
    // });

    // if (!_createTeamFormKey.currentState.validate()) {
    //   focusError();
    //   return;
    // }
    // _createTeamFormKey.currentState.save();
    // Map _result;

    // setState(() {
    //   _isLoading = true;
    // });

    // if (contactBloc.currentEditContactId == null) {
    //   _result = await contactBloc.createTeam();
    // } else {
    //   _result = await contactBloc.editContact();
    // }

    // setState(() {
    //   _isLoading = false;
    // });

    // if (_result['error'] == false) {
    //   setState(() {
    //     _errors = null;
    //   });
    //   showToast(_result['message']);
    //   Navigator.pushReplacementNamed(context, '/contacts');
    // } else if (_result['error'] == true) {
    //   setState(() {
    //     _errors = _result['errors'];
    //   });

    //   if (_errors['first_name'] != null && _focusErr == null) {
    //     _focusErr = _firstNameFocusNode;
    //     focusError();
    //   }

    //   if (_errors['last_name'] != null && _focusErr == null) {
    //     _focusErr = _lastNameFocusNode;
    //     focusError();
    //   }

    //   if (_errors['phone'] != null && _focusErr == null) {
    //     _focusErr = _phoneFocusNode;
    //     focusError();
    //   }

    //   if (_errors['email_address'] != null && _focusErr == null) {
    //     _focusErr = _emailAddressFocusNode;
    //     focusError();
    //   } else {
    //     print(_errors);
    //   }
    // } else {
    //   setState(() {
    //     _errors = null;
    //   });

    //   showErrorMessage(context, "Something went wrong.");
    // }
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
                        focusNode: _firstNameFocusNode,
                        maxLines: 1,
                        initialValue:
                            contactBloc.currentEditContact['first_name'],
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
                          contactBloc.currentEditContact['first_name'] = value;
                        },
                      ),
                    ),
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
                        focusNode: _lastNameFocusNode,
                        maxLines: 5,
                        // initialValue:
                        //     teamBLoc.currentEditTeam['description'],
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
                          // teamBLoc.currentEditTeam['description'] = value;
                        },
                      ),
                    ),
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
                      child: Text(
                        'Assigned Users :',
                        style: GoogleFonts.robotoSlab(
                            textStyle: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor,
                                fontWeight: FontWeight.w500,
                                fontSize: screenWidth / 25)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 5.0),
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
                        // required: true,
                        hintWidget: Text(
                          "Please choose one or more",
                          style: GoogleFonts.robotoSlab(),
                        ),
                        title: Text(
                          "Assigned To",
                          style: GoogleFonts.robotoSlab(),
                        ),
                        initialValue:
                            contactBloc.currentEditContact['assigned_to'],

                        onSaved: (value) {
                          if (value == null) return;
                          contactBloc.currentEditContact['assigned_to'] = value;
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Select one or more",
                        style: GoogleFonts.robotoSlab(
                            textStyle: TextStyle(color: Colors.grey)),
                      ),
                    ),
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
                              // contactBloc.currentEditContactId != null
                              //     ? 'Update Team'
                              //     : 'Create Team',
                              'Create Team',
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
