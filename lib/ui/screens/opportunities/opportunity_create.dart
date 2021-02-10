import 'package:bottle_crm/bloc/account_bloc.dart';
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
import 'package:textfield_tags/textfield_tags.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

class CreateOpportunity extends StatefulWidget {
  CreateOpportunity();
  @override
  State createState() => _CreateOpportunityState();
}

class _CreateOpportunityState extends State<CreateOpportunity> {
  final GlobalKey<FormState> _createOpportunityFormKey = GlobalKey<FormState>();
  FilePickerResult result;
  PlatformFile file;
  Map _errors;
  bool _isLoading = false;
  FocusNode _focuserr;
  FocusNode _nameFocusNode = new FocusNode();
  FocusNode _stageFocusNode = new FocusNode();
  FocusNode _probabilityFocusNode = new FocusNode();

  DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
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
        opportunityBloc.currentEditOpportunity['closed_on'] =
            DateFormat("dd-MM-yyyy").format(
                DateFormat("yyyy-MM-dd").parse(_selectedDate.toString()));
      });
    } else {
      _selectedDate = null;
    }
  }

  _saveForm() async {
    _focuserr = null;
    setState(() {
      _errors = null;
    });
    if (!_createOpportunityFormKey.currentState.validate()) {
      focusError();
      return;
    }
    _createOpportunityFormKey.currentState.save();
    Map _result;
    setState(() {
      _isLoading = true;
    });
    if (opportunityBloc.currentEditOpportunityId != null) {
      _result = await opportunityBloc.editOpportunity(file);
    } else {
      _result = await opportunityBloc.createOpportunity(file);
    }
    setState(() {
      _isLoading = false;
    });
    if (_result['error'] == false) {
      setState(() {
        _errors = null;
      });
      showToast(_result['message']);
      Navigator.pushReplacementNamed(context, '/opportunities');
    } else if (_result['error'] == true) {
      setState(() {
        _errors = _result['errors'];
      });
      if (_errors['name'] != null && _focuserr == null) {
        _focuserr = _nameFocusNode;
        focusError();
      }
      if (_errors['stage'] != null && _focuserr == null) {
        _focuserr = _stageFocusNode;
        focusError();
      }
      if (_errors['probability'] != null && _focuserr == null) {
        _focuserr = _probabilityFocusNode;
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
        key: _createOpportunityFormKey,
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
                      initialValue:
                          opportunityBloc.currentEditOpportunity['name'],
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
                        opportunityBloc.currentEditOpportunity['name'] = value;
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
                        selectedItem: opportunityBloc
                                    .currentEditOpportunity['account'] ==
                                ""
                            ? null
                            : opportunityBloc.currentEditOpportunity['account'],
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
                          opportunityBloc.currentEditOpportunity['account'] =
                              newValue;
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
                        'Amount :',
                        style: GoogleFonts.robotoSlab(
                            textStyle: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor,
                                fontWeight: FontWeight.w500,
                                fontSize: screenWidth / 25)),
                      )),
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      initialValue:
                          opportunityBloc.currentEditOpportunity['amount'],
                      controller: null,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(12.0),
                          enabledBorder: boxBorder(),
                          focusedErrorBorder: boxBorder(),
                          focusedBorder: boxBorder(),
                          errorBorder: boxBorder(),
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'Enter Amount',
                          errorStyle: GoogleFonts.robotoSlab(),
                          hintStyle: GoogleFonts.robotoSlab(
                              textStyle: TextStyle(fontSize: 14.0))),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      onSaved: (value) {
                        opportunityBloc.currentEditOpportunity['amount'] =
                            value;
                      },
                    ),
                  ),
                  _errors != null && _errors['amount'] != null
                      ? Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _errors['amount'][0],
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
                            text: 'Currency :',
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
                        items: opportunityBloc.currencyObjforDropDown,
                        onChanged: print,
                        selectedItem: opportunityBloc
                                    .currentEditOpportunity['currency'] ==
                                ""
                            ? null
                            : opportunityBloc
                                .currentEditOpportunity['currency'],
                        hint: "Select Currency",
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
                          hintText: "Search an Currency here.",
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
                              'Currency',
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
                          opportunityBloc.currentEditOpportunity['currency'] =
                              newValue;
                        },
                      )),
                  _errors != null && _errors['currency'] != null
                      ? Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _errors['currency'][0],
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
                          text: 'Stage',
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
                      focusNode: _stageFocusNode,
                      decoration: InputDecoration(
                          border: boxBorder(),
                          focusedBorder: boxBorder(),
                          contentPadding: EdgeInsets.all(12.0)),
                      style: GoogleFonts.robotoSlab(
                          textStyle: TextStyle(color: Colors.black)),
                      hint: Text('Select Stage'),
                      value: (opportunityBloc.currentEditOpportunity['stage'] !=
                              "")
                          ? opportunityBloc.currentEditOpportunity['stage']
                          : null,
                      onChanged: (value) {
                        FocusScope.of(context).unfocus();
                        opportunityBloc.currentEditOpportunity['stage'] = value;
                      },
                      items:
                          opportunityBloc.stageObjforDropDown.map((location) {
                        return DropdownMenuItem(
                          child: new Text(location[1]),
                          value: location[0],
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          if (_focuserr == null) {
                            _focuserr = _stageFocusNode;
                          }
                          return 'This field is required.';
                        }
                        return null;
                      },
                    ),
                  ),
                  _errors != null && _errors['stage'] != null
                      ? Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _errors['stage'][0],
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
                            text: 'Lead Source :',
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
                      hint: Text('Select Lead Source'),
                      value: (opportunityBloc
                                  .currentEditOpportunity['lead_source'] !=
                              "")
                          ? opportunityBloc
                              .currentEditOpportunity['lead_source']
                          : null,
                      onChanged: (value) {
                        FocusScope.of(context).unfocus();
                        opportunityBloc.currentEditOpportunity['lead_source'] =
                            value;
                      },
                      items: opportunityBloc.leadSourceObjforDropDown
                          .map((location) {
                        return DropdownMenuItem(
                          child: new Text(location[1]),
                          value: location[0],
                        );
                      }).toList(),
                    ),
                  ),
                  _errors != null && _errors['lead_source'] != null
                      ? Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _errors['lead_source'][0],
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
                          text: 'Probability',
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
                  Focus(
                    autofocus: true,
                    focusNode: _probabilityFocusNode,
                    child: NumberInputWithIncrementDecrement(
                      controller: TextEditingController(),
                      initialValue:
                          opportunityBloc.currentEditOpportunity['probability'],
                      widgetContainerDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          )),
                      numberFieldDecoration: InputDecoration(
                          border: null,
                          hintText: 'Input value between 1 and 100',
                          labelStyle: null),
                      onDecrement: (value) {
                        opportunityBloc.currentEditOpportunity['probability'] -=
                            1;
                      },
                      onIncrement: (value) {
                        opportunityBloc.currentEditOpportunity['probability'] +=
                            1;
                      },
                      onSubmitted: (value) {
                        opportunityBloc.currentEditOpportunity['probability'] =
                            value;
                      },
                      min: 0,
                      max: 100,
                      validator: (value) {
                        if (int.parse(value) == 0) {
                          if (_focuserr == null) {
                            _focuserr = _probabilityFocusNode;
                          }
                          return 'This field is required and needs to be greater than 0.';
                        }
                        return null;
                      },
                    ),
                  ),
                  _errors != null && _errors['probability'] != null
                      ? Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _errors['probability'][0],
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
                      initialValue:
                          opportunityBloc.currentEditOpportunity['teams'],
                      onSaved: (value) {
                        if (value == null) {
                          opportunityBloc.currentEditOpportunity['teams'] = [];
                        } else {
                          opportunityBloc.currentEditOpportunity['teams'] =
                              value;
                        }
                      },
                    ),
                  ),
                  Divider(color: Colors.grey)
                ],
              ),
            ),

            // Users MultiSelectDropDown Field. <disabled> - needs data
            // Container(
            //   child: Column(
            //     children: [
            //       Container(
            //         alignment: Alignment.centerLeft,
            //         margin: EdgeInsets.only(bottom: 5.0),
            //         child: Text(
            //           'Users :',
            //           style: GoogleFonts.robotoSlab(
            //               textStyle: TextStyle(
            //                   color: Theme.of(context).secondaryHeaderColor,
            //                   fontWeight: FontWeight.w500,
            //                   fontSize: screenWidth / 25)),
            //         ),
            //       ),
            //       Container(
            //         margin: EdgeInsets.only(bottom: 5.0),
            //         child: MultiSelectFormField(
            //           border: boxBorder(),
            //           enabled: false,
            //           fillColor: Colors.white,
            //           autovalidate: false,
            //           dataSource: [
            //             {'name': '', 'id': ''}
            //           ],
            //           textField: 'name',
            //           valueField: 'id',
            //           okButtonLabel: 'OK',
            //           chipLabelStyle: GoogleFonts.robotoSlab(
            //               textStyle: TextStyle(color: Colors.black)),
            //           dialogTextStyle: GoogleFonts.robotoSlab(),
            //           cancelButtonLabel: 'CANCEL',
            //           hintWidget: Text(
            //             "Please choose one or more",
            //             style: GoogleFonts.robotoSlab(
            //                 textStyle: TextStyle(color: Colors.grey)),
            //           ),
            //           title: Text(
            //             "Users",
            //             style: GoogleFonts.robotoSlab(),
            //           ),
            //           // initialValue: accountBloc.currentEditAccount['users'],
            //           onSaved: (value) {
            //             // accountBloc.currentEditAccount['users'] = value;
            //           },
            //         ),
            //       ),
            //       Divider(color: Colors.grey)
            //     ],
            //   ),
            // ),

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
                      initialValue:
                          opportunityBloc.currentEditOpportunity['assigned_to'],
                      onSaved: (value) {
                        if (value == null) {
                          opportunityBloc
                              .currentEditOpportunity['assigned_to'] = [];
                        } else {
                          opportunityBloc
                              .currentEditOpportunity['assigned_to'] = value;
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
                      initialValue:
                          opportunityBloc.currentEditOpportunity['contacts'],
                      onSaved: (value) {
                        if (value == null) return;
                        opportunityBloc.currentEditOpportunity['contacts'] =
                            value;
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
                      'Due Date :',
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
                              : (opportunityBloc.currentEditOpportunityId !=
                                      null)
                                  ? Text(
                                      opportunityBloc
                                          .currentEditOpportunity['closed_on'],
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
                    child: Text(
                      'Tags :',
                      style: GoogleFonts.robotoSlab(
                          textStyle: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                              fontWeight: FontWeight.w500,
                              fontSize: screenWidth / 25)),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 5.0),
                    child: TextFieldTags(
                      initialTags:
                          opportunityBloc.currentEditOpportunity['tags'],
                      textFieldStyler: TextFieldStyler(
                        contentPadding: EdgeInsets.all(12.0),
                        textFieldBorder: boxBorder(),
                        textFieldFocusedBorder: boxBorder(),
                        hintText: 'Enter Tags',
                        hintStyle: GoogleFonts.robotoSlab(
                            textStyle: TextStyle(fontSize: 14.0)),
                        helperText: null,
                      ),
                      tagsStyler: TagsStyler(
                          tagTextPadding: EdgeInsets.symmetric(horizontal: 5.0),
                          tagTextStyle: GoogleFonts.robotoSlab(),
                          tagDecoration: BoxDecoration(
                            color: Colors.lightGreen[300],
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                          tagCancelIcon: Icon(Icons.cancel,
                              size: 18.0, color: Colors.green[900]),
                          tagPadding: const EdgeInsets.all(6.0)),
                      onTag: (tag) {
                        setState(() {
                          opportunityBloc.currentEditOpportunity['tags']
                              .add(tag);
                        });
                      },
                      onDelete: (tag) {
                        setState(() {
                          opportunityBloc.currentEditOpportunity['tags']
                              .remove(tag);
                        });
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
                      initialValue:
                          opportunityBloc.currentEditOpportunity['description'],
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
                        opportunityBloc.currentEditOpportunity['description'] =
                            value;
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
                  (opportunityBloc.currentEditOpportunityId != null)
                      ? Container(
                          child: (opportunityBloc
                                      .currentEditOpportunity[
                                          'opportunity_attachment']
                                      .length >
                                  0)
                              ? Text(
                                  opportunityBloc.currentEditOpportunity[
                                          'opportunity_attachment']
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
                            opportunityBloc.currentEditOpportunityId == null
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
                      opportunityBloc.cancelCurrentEditOpportunity();
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
            "Create Opportunity",
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
