import 'package:bottle_crm/bloc/account_bloc.dart';
import 'package:bottle_crm/bloc/case_bloc.dart';
import 'package:bottle_crm/bloc/contact_bloc.dart';
import 'package:bottle_crm/bloc/opportunity_bloc.dart';
import 'package:bottle_crm/ui/widgets/bottom_navigation_bar.dart';
import 'package:bottle_crm/utils/utils.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';

class CreateCase extends StatefulWidget {
  CreateCase();
  @override
  State createState() => _CreateCaseState();
}

class _CreateCaseState extends State<CreateCase> {
  final GlobalKey<FormState> _createCaseFormKey = GlobalKey<FormState>();
  FilePickerResult result;
  PlatformFile file;
  Map _errors;
  bool _isLoading = false;
  FocusNode _focuserr;
  FocusNode _nameFocusNode = new FocusNode();
  FocusNode _statusFocusNode = new FocusNode();
  FocusNode _priorityFocusNode = new FocusNode();

  DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
  }

  _selectDate(BuildContext context) async {
    _selectedDate = DateTime.now();
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(_selectedDate.year - 5),
      lastDate: DateTime(_selectedDate.year + 5),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _selectedDate = picked;
        caseBloc.currentEditCase['closed_on'] = DateFormat("dd-MM-yyyy")
            .format(DateFormat("yyyy-MM-dd").parse(_selectedDate.toString()));
      });
    } else {
      _selectedDate = null;
    }
  }

  // @override
  // void dispose() {
  //   if (_focuserr != null) {
  //     _focuserr.dispose();
  //   }
  //   _nameFocusNode.dispose();
  //   _stageFocusNode.dispose();
  //   _probabilityFocusNode.dispose();

  //   super.dispose();
  // }

  focusError() {
    setState(() {
      FocusManager.instance.primaryFocus.unfocus();
      FocusScope.of(context).requestFocus(_focuserr);
    });
  }

  _saveForm() async {
    _focuserr = null;
    setState(() {
      _errors = null;
    });
    if (!_createCaseFormKey.currentState.validate()) {
      focusError();
      return;
    }
    _createCaseFormKey.currentState.save();
    Map _result;
    setState(() {
      _isLoading = true;
    });
    if (caseBloc.currentEditCaseId != null) {
      _result = await caseBloc.editCase(file);
    } else {
      _result = await caseBloc.createCase(file);
    }
    setState(() {
      _isLoading = false;
    });
    if (_result['error'] == false) {
      setState(() {
        _errors = null;
      });
      showToast(_result['message']);
      Navigator.pushReplacementNamed(context, '/cases');
    } else if (_result['error'] == true) {
      setState(() {
        _errors = _result['errors'];
      });
      if (_errors['name'] != null && _focuserr == null) {
        _focuserr = _nameFocusNode;
        focusError();
      }
      if (_errors['status'] != null && _focuserr == null) {
        _focuserr = _statusFocusNode;
        focusError();
      }
      if (_errors['priority'] != null && _focuserr == null) {
        _focuserr = _priorityFocusNode;
        focusError();
      }
    } else {
      setState(() {
        _errors = null;
      });
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
          _saveForm();
        },
      ),
      duration: Duration(seconds: 10),
    )..show(context);
  }

  Widget _buildForm() {
    return Container(
      child: Form(
        key: _createCaseFormKey,
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
                          text: 'Name',
                          style: GoogleFonts.robotoSlab(
                              textStyle: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: screenWidth / 25)),
                          children: <TextSpan>[
                            TextSpan(
                                text: '* ',
                                style: GoogleFonts.robotoSlab(
                                    textStyle: TextStyle(color: Colors.red))),
                            TextSpan(
                                text: ': ', style: GoogleFonts.robotoSlab())
                          ],
                        ),
                      )),
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      focusNode: _nameFocusNode,
                      initialValue: caseBloc.currentEditCase['name'],
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(12.0),
                          enabledBorder: boxBorder(),
                          focusedErrorBorder: boxBorder(),
                          focusedBorder: boxBorder(),
                          errorBorder: boxBorder(),
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'Enter Name',
                          errorStyle: GoogleFonts.robotoSlab(),
                          hintStyle: GoogleFonts.robotoSlab(
                              textStyle: TextStyle(fontSize: 14.0))),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value.isEmpty) {
                          if (_focuserr == null) {
                            _focuserr = _nameFocusNode;
                          }
                          return 'This field is required.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        caseBloc.currentEditCase['name'] = value;
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
                          text: 'Status',
                          style: GoogleFonts.robotoSlab(
                              textStyle: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: screenWidth / 25)),
                          children: <TextSpan>[
                            TextSpan(
                                text: '* ',
                                style: GoogleFonts.robotoSlab(
                                    textStyle: TextStyle(color: Colors.red))),
                            TextSpan(
                                text: ': ', style: GoogleFonts.robotoSlab())
                          ],
                        ),
                      )),
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: DropdownButtonFormField(
                      focusNode: _statusFocusNode,
                      decoration: InputDecoration(
                          border: boxBorder(),
                          focusedBorder: boxBorder(),
                          contentPadding: EdgeInsets.all(12.0)),
                      style: GoogleFonts.robotoSlab(
                          textStyle: TextStyle(color: Colors.black)),
                      hint: Text('Select Status'),
                      value: (caseBloc.currentEditCase['status'] != "")
                          ? caseBloc.currentEditCase['status']
                          : null,
                      onChanged: (value) {
                        FocusScope.of(context).unfocus();
                        caseBloc.currentEditCase['status'] = value;
                      },
                      items: caseBloc.statusObjForDropDown.map((location) {
                        return DropdownMenuItem(
                          child: new Text(location[1]),
                          value: location[0],
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          if (_focuserr == null) {
                            _focuserr = _statusFocusNode;
                          }
                          return 'This field is required.';
                        }
                        return null;
                      },
                    ),
                  ),
                  _errors != null && _errors['status'] != null
                      ? Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _errors['status'][0],
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
                            text: 'Priority :',
                            style: GoogleFonts.robotoSlab(
                                textStyle: TextStyle(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: screenWidth / 25))),
                      )),
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                          border: boxBorder(),
                          contentPadding: EdgeInsets.all(12.0)),
                      style: GoogleFonts.robotoSlab(
                          textStyle: TextStyle(color: Colors.black)),
                      hint: Text('Select Priority'),
                      value: (caseBloc.currentEditCase['priority'] != "")
                          ? caseBloc.currentEditCase['priority']
                          : null,
                      onChanged: (value) {
                        FocusScope.of(context).unfocus();
                        caseBloc.currentEditCase['priority'] = value;
                      },
                      items: caseBloc.priorityObjForDropDown.map((location) {
                        return DropdownMenuItem(
                          child: new Text(location[1]),
                          value: location[0],
                        );
                      }).toList(),
                    ),
                  ),
                  _errors != null && _errors['priority'] != null
                      ? Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _errors['priority'][0],
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
                            text: 'Type of Case :',
                            style: GoogleFonts.robotoSlab(
                                textStyle: TextStyle(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: screenWidth / 25))),
                      )),
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                          border: boxBorder(),
                          contentPadding: EdgeInsets.all(12.0)),
                      style: GoogleFonts.robotoSlab(
                          textStyle: TextStyle(color: Colors.black)),
                      hint: Text('Select Case Type'),
                      value: (caseBloc.currentEditCase['case_type'] != "")
                          ? caseBloc.currentEditCase['case_type']
                          : null,
                      onChanged: (value) {
                        FocusScope.of(context).unfocus();
                        caseBloc.currentEditCase['case_type'] = value;
                      },
                      items: caseBloc.typeOfCaseObjForDropDown.map((location) {
                        return DropdownMenuItem(
                          child: new Text(location[1]),
                          value: location[0],
                        );
                      }).toList(),
                    ),
                  ),
                  _errors != null && _errors['case_type'] != null
                      ? Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _errors['case_type'][0],
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(bottom: 5.0),
                    child: Text(
                      'Close Date :',
                      style: GoogleFonts.robotoSlab(
                          textStyle: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                              fontWeight: FontWeight.w500,
                              fontSize: screenWidth / 25)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _selectDate(context);
                    },
                    child: Container(
                        height: 48.0,
                        margin: EdgeInsets.only(bottom: 5.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            border: Border.all(color: Colors.grey, width: 1)),
                        child: Center(
                          child: (_selectedDate != null)
                              ? Text(
                                  DateFormat("dd-MM-yyyy").format(
                                      DateFormat("yyyy-MM-dd")
                                          .parse(_selectedDate.toString())),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.robotoSlab(),
                                )
                              : (caseBloc.currentEditCaseId != null)
                                  ? Text(caseBloc.currentEditCase['closed_on'],
                                      style: GoogleFonts.robotoSlab())
                                  : Text('Please choose a Due Date.',
                                      style: GoogleFonts.robotoSlab(
                                          color: Colors.grey)),
                        )),
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
                            text: 'Account :',
                            style: GoogleFonts.robotoSlab(
                                textStyle: TextStyle(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: screenWidth / 25))),
                      )),
                  Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      height: 48.0,
                      child: DropdownSearch<String>(
                        mode: Mode.BOTTOM_SHEET,
                        items: opportunityBloc.accountsObjforDropDown,
                        onChanged: print,
                        selectedItem: caseBloc.currentEditCase['account'] == ""
                            ? null
                            : caseBloc.currentEditCase['account'],
                        hint: "Select Account",
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
                          hintText: "Search an Account here.",
                          hintStyle: GoogleFonts.robotoSlab(),
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
                              'Account',
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
                        onSaved: (newValue) {
                          caseBloc.currentEditCase['account'] = newValue;
                        },
                      )),
                  _errors != null && _errors['account'] != null
                      ? Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _errors['account'][0],
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
                      initialValue: caseBloc.currentEditCase['teams'],
                      onSaved: (value) {
                        if (value == null) {
                          caseBloc.currentEditCase['teams'] = [];
                        } else {
                          caseBloc.currentEditCase['teams'] = value;
                        }
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
                      'Assign To :',
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
                      dataSource: accountBloc.assignedToList,
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
                        "Assigned To",
                        style: GoogleFonts.robotoSlab(),
                      ),
                      initialValue: caseBloc.currentEditCase['assigned_to'],
                      onSaved: (value) {
                        if (value == null) {
                          caseBloc.currentEditCase['assigned_to'] = [];
                        } else {
                          caseBloc.currentEditCase['assigned_to'] = value;
                        }
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
                            text: 'Contacts :',
                            style: GoogleFonts.robotoSlab(
                                textStyle: TextStyle(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: screenWidth / 25))),
                      )),
                  Container(
                    margin: EdgeInsets.only(bottom: 5.0),
                    child: MultiSelectFormField(
                      border: boxBorder(),
                      fillColor: Colors.white,
                      autovalidate: false,
                      validator: (value) {
                        if (value == null) {
                          return 'Please select one or more options';
                        }
                        return null;
                      },
                      dataSource: contactBloc.contactsObjForDropdown,
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
                        "Contacts",
                        style: GoogleFonts.robotoSlab(),
                      ),
                      initialValue: caseBloc.currentEditCase['contacts'],
                      onSaved: (value) {
                        if (value == null) return;
                        caseBloc.currentEditCase['contacts'] = value;
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
                            text: 'Description :',
                            style: GoogleFonts.robotoSlab(
                                textStyle: TextStyle(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: screenWidth / 25))),
                      )),
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      maxLines: 5,
                      initialValue: caseBloc.currentEditCase['description'],
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
                      onSaved: (value) {
                        caseBloc.currentEditCase['description'] = value;
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
                      result = await FilePicker.platform.pickFiles(
                        allowMultiple: false,
                      );
                      setState(() {
                        _isLoading = true;
                        file = result.files.first;
                        _isLoading = false;
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
                  (caseBloc.currentEditCaseId != null)
                      ? Container(
                          child: (caseBloc.currentEditCase['case_attachment'] !=
                                  null)
                              ? Text(
                                  caseBloc.currentEditCase['case_attachment']
                                      .split('/')
                                      .last,
                                  style: GoogleFonts.robotoSlab(),
                                )
                              : Container(),
                        )
                      : (file != null)
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
            // Save Form
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
                      width: screenWidth * 0.52,
                      decoration: BoxDecoration(
                        color: submitButtonColor,
                        borderRadius: BorderRadius.all(Radius.circular(3.0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            caseBloc.currentEditCaseId == null
                                ? 'Create Opportunity'
                                : 'Edit Opportunity',
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
                      Navigator.pop(context);
                      caseBloc.cancelCurrentEditCase();
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
          ],
        ),
      ),
    );
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
            "Create Case",
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
        bottomNavigationBar: BottomNavigationBarWidget());
  }
}
