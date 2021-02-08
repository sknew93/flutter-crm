import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:bottle_crm/bloc/contact_bloc.dart';
import 'package:bottle_crm/bloc/lead_bloc.dart';
import 'package:bottle_crm/ui/widgets/bottom_navigation_bar.dart';
import 'package:bottle_crm/utils/utils.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';

class CreateContact extends StatefulWidget {
  CreateContact();
  @override
  State createState() => _CreateContactState();
}

class _CreateContactState extends State<CreateContact> {
  final GlobalKey<FormState> _createContactFormKey = GlobalKey<FormState>();
  FilePickerResult result;
  PlatformFile file;
  List countiresForDropDown = leadBloc.countries;
  bool _isLoading = false;

  FocusNode _focuserr;
  FocusNode _firstNameFocusNode = new FocusNode();
  FocusNode _lastNameFocusNode = new FocusNode();
  FocusNode _phoneFocusNode = new FocusNode();
  FocusNode _emailAddressFocusNode = new FocusNode();
  Map _errors;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (_focuserr != null) {
      _focuserr.dispose();
    }
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailAddressFocusNode.dispose();
    super.dispose();
  }

  focusError() {
    setState(() {
      FocusManager.instance.primaryFocus.unfocus();
      FocusScope.of(context).unfocus();
      Focus.of(context).requestFocus(_focuserr);
    });
  }

  _saveForm() async {
    _focuserr = null;
    setState(() {
      _errors = null;
    });

    if (!_createContactFormKey.currentState.validate()) {
      focusError();
      return;
    }
    _createContactFormKey.currentState.save();
    Map _result;

    setState(() {
      _isLoading = true;
    });

    if (contactBloc.currentEditContactId == null) {
      _result = await contactBloc.createContact();
    } else {
      _result = await contactBloc.editContact();
    }

    setState(() {
      _isLoading = false;
    });

    if (_result['error'] == false) {
      setState(() {
        _errors = null;
      });
      showToast(_result['message']);
      Navigator.pushReplacementNamed(context, '/contacts');
    } else if (_result['error'] == true) {
      setState(() {
        _errors = _result['errors']['contact_errors'];
      });

      if (_errors['first_name'] != null && _focuserr == null) {
        _focuserr = _firstNameFocusNode;
        focusError();
      }

      if (_errors['last_name'] != null && _focuserr == null) {
        _focuserr = _lastNameFocusNode;
        focusError();
      }

      if (_errors['phone'] != null && _focuserr == null) {
        _focuserr = _phoneFocusNode;
        focusError();
      }

      if (_errors['email'] != null && _focuserr == null) {
        _focuserr = _emailAddressFocusNode;
        focusError();
      }
    } else {
      setState(() {
        _errors = null;
      });
      showErrorMessage(context, "Something went wrong.");
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
          _saveForm();
        },
      ),
      duration: Duration(seconds: 10),
    )..show(context);
  }

  Widget _buildForm() {
    return Container(
        child: Form(
            key: _createContactFormKey,
            child: Column(children: [
              Container(
                child: Column(
                  children: [
                    Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(bottom: 5.0),
                        child: RichText(
                          text: TextSpan(
                            text: 'First Name',
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
                            hintText: "Enter First Name",
                            errorStyle: GoogleFonts.robotoSlab(),
                            hintStyle: GoogleFonts.robotoSlab(
                                textStyle: TextStyle(fontSize: 14.0))),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value.isEmpty) {
                            if (_focuserr == null) {
                              _focuserr = _firstNameFocusNode;
                            }
                            return 'This field is required.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          contactBloc.currentEditContact['first_name'] = value;
                        },
                      ),
                    ),
                    _errors != null && _errors['first_name'] != null
                        ? Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _errors['first_name'][0],
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
                            text: 'Last Name',
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
                        maxLines: 1,
                        initialValue:
                            contactBloc.currentEditContact['last_name'],
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(12.0),
                            enabledBorder: boxBorder(),
                            focusedErrorBorder: boxBorder(),
                            focusedBorder: boxBorder(),
                            errorBorder: boxBorder(),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: 'Enter Last Name',
                            errorStyle: GoogleFonts.robotoSlab(),
                            hintStyle: GoogleFonts.robotoSlab(
                                textStyle: TextStyle(fontSize: 14.0))),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value.isEmpty) {
                            if (_focuserr == null) {
                              _focuserr = _lastNameFocusNode;
                            }
                            return 'This field is required.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          contactBloc.currentEditContact['last_name'] = value;
                        },
                      ),
                    ),
                    _errors != null && _errors['last_name'] != null
                        ? Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _errors['last_name'][0],
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
                            text: 'Phone',
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
                        focusNode: _phoneFocusNode,
                        initialValue: contactBloc.currentEditContact['phone'],
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(12.0),
                            enabledBorder: boxBorder(),
                            focusedErrorBorder: boxBorder(),
                            focusedBorder: boxBorder(),
                            errorBorder: boxBorder(),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "Enter Phone Number",
                            errorStyle: GoogleFonts.robotoSlab(),
                            hintStyle: GoogleFonts.robotoSlab(
                                textStyle: TextStyle(fontSize: 14.0))),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value.isEmpty) {
                            if (_focuserr == null) {
                              _focuserr = _phoneFocusNode;
                            }
                            return 'This field is required.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          contactBloc.currentEditContact['phone'] = value;
                        },
                      ),
                    ),
                    _errors != null && _errors['phone'] != null
                        ? Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _errors['phone'][0],
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
                            text: 'Email Address',
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
                        focusNode: _emailAddressFocusNode,
                        initialValue: contactBloc.currentEditContact['email'],
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(12.0),
                            enabledBorder: boxBorder(),
                            focusedErrorBorder: boxBorder(),
                            focusedBorder: boxBorder(),
                            errorBorder: boxBorder(),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "Enter Email Address",
                            errorStyle: GoogleFonts.robotoSlab(),
                            hintStyle: GoogleFonts.robotoSlab(
                                textStyle: TextStyle(fontSize: 14.0))),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value.isEmpty) {
                            if (_focuserr == null) {
                              _focuserr = _emailAddressFocusNode;
                            }
                            return 'This field is required.';
                          }
                          if (!RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value)) {
                            if (_focuserr == null) {
                              _focuserr = _emailAddressFocusNode;
                            }
                            return 'Enter valid email address.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          contactBloc.currentEditContact['email'] = value;
                        },
                      ),
                    ),
                    _errors != null && _errors['email'] != null
                        ? Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _errors['email'][0],
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
                      child: Text(
                        'Teams :',
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
                        dataSource: contactBloc.teamsObjForDropdown,
                        textField: 'name',
                        valueField: 'id',
                        okButtonLabel: 'OK',
                        chipLabelStyle: GoogleFonts.robotoSlab(
                            textStyle: TextStyle(color: Colors.black)),
                        dialogTextStyle: GoogleFonts.robotoSlab(),
                        cancelButtonLabel: 'CANCEL',
                        hintWidget: Text(
                          "Please choose one or more",
                          style: GoogleFonts.robotoSlab(
                              textStyle: TextStyle(color: Colors.grey)),
                        ),
                        title: Text(
                          "Teams",
                          style: GoogleFonts.robotoSlab(),
                        ),
                        initialValue: contactBloc.currentEditContact['teams'],
                        onSaved: (value) {
                          if (value == null) return;
                          contactBloc.currentEditContact['teams'] = value;
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
                        'Users :',
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
                        enabled: false,
                        fillColor: Colors.grey[300],
                        autovalidate: false,
                        dataSource: leadBloc.usersObjForDropdown,
                        textField: 'name',
                        valueField: 'id',
                        okButtonLabel: 'OK',
                        chipLabelStyle: GoogleFonts.robotoSlab(
                            textStyle: TextStyle(color: Colors.black)),
                        dialogTextStyle: GoogleFonts.robotoSlab(),
                        cancelButtonLabel: 'CANCEL',
                        hintWidget: Text("Please choose one or more",
                            style: GoogleFonts.robotoSlab(
                                textStyle: TextStyle(color: Colors.grey))),
                        title: Text(
                          "Users",
                          style: GoogleFonts.robotoSlab(),
                        ),
                        initialValue: [],
                        onSaved: (value) {
                          if (value == null) return;
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
                        'Assign Users :',
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
                        hintWidget: Text("Please choose one or more",
                            style: GoogleFonts.robotoSlab(
                                textStyle: TextStyle(color: Colors.grey))),
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
              // Build Address Field - currentEditContact to be added after update from backend
              Container(
                child: Column(
                  children: [
                    Container(
                      child: Column(
                        children: [
                          Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.only(bottom: 5.0),
                              child: RichText(
                                text: TextSpan(
                                    text: 'Billing Address :',
                                    style: GoogleFonts.robotoSlab(
                                        textStyle: TextStyle(
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: screenWidth / 25))),
                              )),
                          Container(
                            margin: EdgeInsets.only(bottom: 10.0),
                            child: TextFormField(
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(12.0),
                                  enabledBorder: boxBorder(),
                                  focusedErrorBorder: boxBorder(),
                                  focusedBorder: boxBorder(),
                                  errorBorder: boxBorder(),
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: 'Address Line',
                                  errorStyle: GoogleFonts.robotoSlab(),
                                  hintStyle: GoogleFonts.robotoSlab(
                                      textStyle: TextStyle(fontSize: 14.0))),
                              keyboardType: TextInputType.text,
                              initialValue:
                                  contactBloc.currentEditContact['address']
                                      ['address_line'],
                              onSaved: (value) {
                                contactBloc.currentEditContact['address']
                                    ['address_line'] = value;
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: screenWidth * 0.42,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(12.0),
                                        enabledBorder: boxBorder(),
                                        focusedErrorBorder: boxBorder(),
                                        focusedBorder: boxBorder(),
                                        errorBorder: boxBorder(),
                                        fillColor: Colors.white,
                                        filled: true,
                                        hintText: 'Street',
                                        errorStyle: GoogleFonts.robotoSlab(),
                                        hintStyle: GoogleFonts.robotoSlab(
                                            textStyle:
                                                TextStyle(fontSize: 14.0))),
                                    keyboardType: TextInputType.text,
                                    initialValue: contactBloc
                                            .currentEditContact['address']
                                        ['street'],
                                    onSaved: (value) {
                                      contactBloc.currentEditContact['address']
                                          ['street'] = value;
                                    },
                                  ),
                                ),
                                Container(
                                  width: screenWidth * 0.42,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(12.0),
                                        enabledBorder: boxBorder(),
                                        focusedErrorBorder: boxBorder(),
                                        focusedBorder: boxBorder(),
                                        errorBorder: boxBorder(),
                                        fillColor: Colors.white,
                                        filled: true,
                                        hintText: 'Postal Code',
                                        errorStyle: GoogleFonts.robotoSlab(),
                                        hintStyle: GoogleFonts.robotoSlab(
                                            textStyle:
                                                TextStyle(fontSize: 14.0))),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    initialValue: contactBloc
                                            .currentEditContact['address']
                                        ['postcode'],
                                    onSaved: (value) {
                                      contactBloc.currentEditContact['address']
                                          ['postcode'] = value;
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: screenWidth * 0.42,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(12.0),
                                        enabledBorder: boxBorder(),
                                        focusedErrorBorder: boxBorder(),
                                        focusedBorder: boxBorder(),
                                        errorBorder: boxBorder(),
                                        fillColor: Colors.white,
                                        filled: true,
                                        hintText: 'City',
                                        errorStyle: GoogleFonts.robotoSlab(),
                                        hintStyle: GoogleFonts.robotoSlab(
                                            textStyle:
                                                TextStyle(fontSize: 14.0))),
                                    keyboardType: TextInputType.text,
                                    initialValue: contactBloc
                                        .currentEditContact['address']['city'],
                                    onSaved: (value) {
                                      contactBloc.currentEditContact['address']
                                          ['city'] = value;
                                    },
                                  ),
                                ),
                                Container(
                                  width: screenWidth * 0.42,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(12.0),
                                        enabledBorder: boxBorder(),
                                        focusedErrorBorder: boxBorder(),
                                        focusedBorder: boxBorder(),
                                        errorBorder: boxBorder(),
                                        fillColor: Colors.white,
                                        filled: true,
                                        hintText: 'State',
                                        errorStyle: GoogleFonts.robotoSlab(),
                                        hintStyle: GoogleFonts.robotoSlab(
                                            textStyle:
                                                TextStyle(fontSize: 14.0))),
                                    keyboardType: TextInputType.text,
                                    initialValue: contactBloc
                                        .currentEditContact['address']['state'],
                                    onSaved: (value) {
                                      contactBloc.currentEditContact['address']
                                          ['state'] = value;
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: 48.0,
                            margin: EdgeInsets.only(bottom: 5.0),
                            child: DropdownSearch<String>(
                              mode: Mode.BOTTOM_SHEET,
                              items: countiresForDropDown,
                              onChanged: (value) {
                                contactBloc.currentEditContact['address']
                                    ['country'] = value;
                              },
                              selectedItem: contactBloc
                                              .currentEditContact['address']
                                          ['country'] ==
                                      ""
                                  ? null
                                  : contactBloc.currentEditContact['address']
                                      ['country'],
                              label: "Country",
                              showSearchBox: true,
                              showSelectedItem: false,
                              showClearButton: true,
                              searchBoxDecoration: InputDecoration(
                                border: boxBorder(),
                                enabledBorder: boxBorder(),
                                focusedErrorBorder: boxBorder(),
                                focusedBorder: boxBorder(),
                                errorBorder: boxBorder(),
                                contentPadding: EdgeInsets.all(12),
                                hintText: "Search a Country",
                                hintStyle: GoogleFonts.robotoSlab(),
                                errorStyle: GoogleFonts.robotoSlab(),
                              ),
                              popupTitle: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColorDark,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Countries',
                                    style: GoogleFonts.robotoSlab(
                                        textStyle: TextStyle(
                                            fontSize: screenWidth / 20,
                                            color: Colors.white)),
                                  ),
                                ),
                              ),
                              popupShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                ),
                              ),
                            ),
                          ),
                          Divider(color: Colors.grey)
                        ],
                      ),
                    ),
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
                              text: 'Description :',
                              style: GoogleFonts.robotoSlab(
                                  textStyle: TextStyle(
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: screenWidth / 25))),
                        )),
                    Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        maxLines: 5,
                        initialValue:
                            contactBloc.currentEditContact['description'],
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(12.0),
                            enabledBorder: boxBorder(),
                            focusedErrorBorder: boxBorder(),
                            focusedBorder: boxBorder(),
                            errorBorder: boxBorder(),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "Enter Description",
                            errorStyle: GoogleFonts.robotoSlab(),
                            hintStyle: GoogleFonts.robotoSlab(
                                textStyle: TextStyle(fontSize: 14.0))),
                        keyboardType: TextInputType.multiline,
                        onSaved: (value) {
                          contactBloc.currentEditContact['description'] = value;
                        },
                      ),
                    ),
                    Divider(color: Colors.grey)
                  ],
                ),
              ),

              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(bottom: 5.0),
                      child: Text(
                        'Attachments :',
                        style: GoogleFonts.robotoSlab(
                            textStyle: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor,
                                fontWeight: FontWeight.w500,
                                fontSize: screenWidth / 25)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        result = await FilePicker.platform.pickFiles();
                        setState(() {
                          file = result.files.first;
                        });
                      },
                      child: Container(
                        color: bottomNavBarTextColor,
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        child: Text(
                          "Choose File",
                          style: GoogleFonts.robotoSlab(
                              textStyle: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                    file != null
                        ? Container(
                            child: Text(
                              file.name,
                              style: GoogleFonts.robotoSlab(),
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
                              contactBloc.currentEditContactId != null
                                  ? 'Update Contact'
                                  : 'Create Contact',
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
          "Create Contact",
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
