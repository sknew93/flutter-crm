import 'package:bottle_crm/bloc/setting_bloc.dart';
import 'package:bottle_crm/ui/widgets/bottom_navigation_bar.dart';
import 'package:bottle_crm/utils/utils.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateSetting extends StatefulWidget {
  CreateSetting();
  @override
  State createState() => _CreateSettingState();
}

class _CreateSettingState extends State<CreateSetting> {
  final GlobalKey<FormState> _createSettingFormKey = GlobalKey<FormState>();
  Map _errors;
  bool _isLoading = false;
  FocusNode _focuserr;
  FocusNode _titleFocusNode = new FocusNode();
  FocusNode _emailFocusNode = new FocusNode();
  bool accessError = false;
  String _errorKey;

  @override
  void initState() {
    super.initState();
  }

  // @override
  // void dispose() {
  //   if (_focuserr != null) {
  //     _focuserr.dispose();
  //   }
  //   _titleFocusNode.dispose();
  //   _emailFocusNode.dispose();

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
    if (!_createSettingFormKey.currentState.validate()) {
      focusError();
      return;
    }
    _createSettingFormKey.currentState.save();
    dynamic _result;

    setState(() {
      _isLoading = true;
    });
    if (settingsBloc.currentEditSettingId != null) {
      _result = await settingsBloc.editSetting();
    } else {
      _result = await settingsBloc.createSetting();
    }
    setState(() {
      _isLoading = false;
    });

    if (_result['error'] == false) {
      setState(() {
        _errors = null;
      });
      showToast(_result['message']);
      Navigator.pushReplacementNamed(context, '/settings_list');
    } else if (_result['error'] == true) {
      setState(() {
        _errors = _result['errors'];
      });
      if (_errors[_errorKey] != null && _focuserr == null) {
        _focuserr = _titleFocusNode;
        focusError();
      }
      if (_errors['email'] != null && _focuserr == null) {
        _focuserr = _emailFocusNode;
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
            key: _createSettingFormKey,
            child: Column(children: [
              Container(
                child: Column(
                  children: [
                    Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(bottom: 5.0),
                        child: RichText(
                          text: TextSpan(
                            text: (settingsBloc.currentSettingsTab !=
                                    "Contacts")
                                ? "${settingsBloc.currentSettingsTab.substring(0, settingsBloc.currentSettingsTab.length - 1)}"
                                : "First Name",
                            style: GoogleFonts.robotoSlab(
                                textStyle: TextStyle(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
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
                        focusNode: _titleFocusNode,
                        initialValue: settingsBloc.currentEditSetting[
                            (settingsBloc.currentSettingsTab == 'Contacts')
                                ? 'name'
                                : (settingsBloc.currentSettingsTab ==
                                        'Blocked Domains')
                                    ? "domain"
                                    : 'email'],
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(12.0),
                            enabledBorder: boxBorder(),
                            focusedErrorBorder: boxBorder(),
                            focusedBorder: boxBorder(),
                            errorBorder: boxBorder(),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: (settingsBloc.currentSettingsTab !=
                                    "Blocked Domains")
                                ? "Enter ${settingsBloc.currentSettingsTab.substring(0, settingsBloc.currentSettingsTab.length - 1)}"
                                : 'Enter Domain here [test.io]',
                            errorStyle: GoogleFonts.robotoSlab(),
                            hintStyle: GoogleFonts.robotoSlab(
                                textStyle: TextStyle(fontSize: 14.0))),
                        keyboardType: (settingsBloc.currentSettingsTab ==
                                "Blocked Domains")
                            ? TextInputType.url
                            : (settingsBloc.currentSettingsTab ==
                                    "Blocked Emails")
                                ? TextInputType.emailAddress
                                : TextInputType.text,
                        validator: (value) {
                          if (value.isEmpty) {
                            if (_focuserr == null) {
                              _focuserr = _titleFocusNode;
                            }
                            return 'This field is required.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          if (settingsBloc.currentSettingsTab == "Contacts") {
                            settingsBloc.currentEditSetting['name'] = value;
                            _errorKey = 'name';
                          }
                          if (settingsBloc.currentSettingsTab ==
                              "Blocked Domains") {
                            settingsBloc.currentEditSetting['domain'] = value;
                            _errorKey = 'domain';
                          }
                          if (settingsBloc.currentSettingsTab ==
                              "Blocked Emails") {
                            settingsBloc.currentEditSetting['email'] = value;
                            _errorKey = 'email';
                          }
                        },
                      ),
                    ),
                    _errors != null && _errors[_errorKey] != null
                        ? Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _errors[_errorKey][0],
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
              (settingsBloc.currentSettingsTab == "Contacts")
                  ? Column(
                      children: [
                        Container(
                          child: Column(
                            children: [
                              Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(bottom: 5.0),
                                  child: RichText(
                                    text: TextSpan(
                                      text: "Last Name",
                                      style: GoogleFonts.robotoSlab(
                                          textStyle: TextStyle(
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor,
                                              fontWeight: FontWeight.w500,
                                              fontSize: screenWidth / 25)),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: '* ',
                                            style: GoogleFonts.robotoSlab(
                                                textStyle: TextStyle(
                                                    color: Colors.red))),
                                        TextSpan(
                                            text: ': ',
                                            style: GoogleFonts.robotoSlab())
                                      ],
                                    ),
                                  )),
                              Container(
                                margin: EdgeInsets.only(bottom: 10.0),
                                child: TextFormField(
                                    initialValue: settingsBloc
                                        .currentEditSetting['last_name'],
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(12.0),
                                        enabledBorder: boxBorder(),
                                        focusedErrorBorder: boxBorder(),
                                        focusedBorder: boxBorder(),
                                        errorBorder: boxBorder(),
                                        fillColor: Colors.white,
                                        filled: true,
                                        hintText: "Enter Last Name",
                                        errorStyle: GoogleFonts.robotoSlab(),
                                        hintStyle: GoogleFonts.robotoSlab(
                                            textStyle:
                                                TextStyle(fontSize: 14.0))),
                                    keyboardType: TextInputType.text,
                                    onSaved: (value) {
                                      settingsBloc
                                              .currentEditSetting['last_name'] =
                                          value;
                                    }),
                              ),
                              _errors != null && _errors["last_name"] != null
                                  ? Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        _errors["last_name"][0],
                                        style: GoogleFonts.robotoSlab(
                                            textStyle: TextStyle(
                                                color: Colors.red[700],
                                                fontSize: 12.0)),
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
                                      text: "Email",
                                      style: GoogleFonts.robotoSlab(
                                          textStyle: TextStyle(
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor,
                                              fontWeight: FontWeight.w500,
                                              fontSize: screenWidth / 25)),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: '* ',
                                            style: GoogleFonts.robotoSlab(
                                                textStyle: TextStyle(
                                                    color: Colors.red))),
                                        TextSpan(
                                            text: ': ',
                                            style: GoogleFonts.robotoSlab())
                                      ],
                                    ),
                                  )),
                              Container(
                                margin: EdgeInsets.only(bottom: 10.0),
                                child: TextFormField(
                                    focusNode: _emailFocusNode,
                                    initialValue: settingsBloc
                                        .currentEditSetting['email'],
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(12.0),
                                        enabledBorder: boxBorder(),
                                        focusedErrorBorder: boxBorder(),
                                        focusedBorder: boxBorder(),
                                        errorBorder: boxBorder(),
                                        fillColor: Colors.white,
                                        filled: true,
                                        hintText: "Enter Email",
                                        errorStyle: GoogleFonts.robotoSlab(),
                                        hintStyle: GoogleFonts.robotoSlab(
                                            textStyle:
                                                TextStyle(fontSize: 14.0))),
                                    keyboardType: TextInputType.text,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        if (_focuserr == null) {
                                          _focuserr = _emailFocusNode;
                                        }
                                        return 'This field is required.';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      settingsBloc.currentEditSetting['email'] =
                                          value;
                                    }),
                              ),
                              _errors != null && _errors["email"] != null
                                  ? Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        _errors["email"][0],
                                        style: GoogleFonts.robotoSlab(
                                            textStyle: TextStyle(
                                                color: Colors.red[700],
                                                fontSize: 12.0)),
                                      ),
                                    )
                                  : Container(),
                              Divider(color: Colors.grey)
                            ],
                          ),
                        ),
                      ],
                    )
                  : Container(),
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
                        width: screenWidth * 0.55,
                        decoration: BoxDecoration(
                          color: submitButtonColor,
                          borderRadius: BorderRadius.all(Radius.circular(3.0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              settingsBloc.currentEditSettingId == null
                                  ? 'Create ${settingsBloc.currentSettingsTab.substring(0, settingsBloc.currentSettingsTab.length - 1)}'
                                  : 'Edit ${settingsBloc.currentSettingsTab.substring(0, settingsBloc.currentSettingsTab.length - 1)}',
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
            'Create ${settingsBloc.currentSettingsTab.substring(0, settingsBloc.currentSettingsTab.length - 1)}',
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
