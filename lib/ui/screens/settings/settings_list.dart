import 'package:bottle_crm/bloc/setting_bloc.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:bottle_crm/ui/widgets/bottom_navigation_bar.dart';
import 'package:bottle_crm/ui/widgets/squareFloatingActionBtn.dart';
import 'package:bottle_crm/utils/utils.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsList extends StatefulWidget {
  SettingsList();
  @override
  State createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
  List _settingsTabData = [];

  int _currentTabIndex = 0;
  bool _isFilter = false;
  final GlobalKey<FormState> _filtersFormKey = GlobalKey<FormState>();
  Map _filtersFormData = {"name": "", "email": "", "created_by": ""};
  bool _isLoading = false;

  @override
  void initState() {
    setState(() {
      _settingsTabData = settingsBloc.currentSettingsTabIndex == 0
          ? settingsBloc.settingsContacts
          : settingsBloc.currentSettingsTabIndex == 1
              ? settingsBloc.blockedDomains
              : settingsBloc.blockedEmails;
      _currentTabIndex = settingsBloc.currentSettingsTabIndex;
    });
    super.initState();
  }

  Widget _buildTabs() {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  if (_currentTabIndex != 0) {
                    setState(() {
                      _currentTabIndex = 0;
                      _settingsTabData = settingsBloc.settingsContacts;
                    });
                    settingsBloc.currentSettingsTab = "Contacts";
                    settingsBloc.currentSettingsTabIndex = 0;
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: _currentTabIndex == 0
                          ? Theme.of(context).secondaryHeaderColor
                          : Colors.white,
                      border: Border.all(
                          color: _currentTabIndex == 0
                              ? Theme.of(context).secondaryHeaderColor
                              : bottomNavBarTextColor)),
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth / 50, vertical: 5.0),
                  child: Text(
                    "Contacts",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.robotoSlab(
                        fontSize: screenWidth / 26,
                        color: _currentTabIndex == 0
                            ? Colors.white
                            : bottomNavBarTextColor),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (_currentTabIndex != 1) {
                    setState(() {
                      _currentTabIndex = 1;
                      _settingsTabData = settingsBloc.blockedDomains;
                    });
                    settingsBloc.currentSettingsTab = "Blocked Domains";
                    settingsBloc.currentSettingsTabIndex = 1;
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: _currentTabIndex == 1
                          ? Theme.of(context).secondaryHeaderColor
                          : Colors.white,
                      border: Border.all(
                          color: _currentTabIndex == 1
                              ? Theme.of(context).secondaryHeaderColor
                              : bottomNavBarTextColor)),
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth / 50, vertical: 5.0),
                  child: Text(
                    "Blocked Domains",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.robotoSlab(
                        fontSize: screenWidth / 26,
                        color: _currentTabIndex == 1
                            ? Colors.white
                            : bottomNavBarTextColor),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (_currentTabIndex != 2) {
                    setState(() {
                      _currentTabIndex = 2;
                      _settingsTabData = settingsBloc.blockedEmails;
                    });
                    settingsBloc.currentSettingsTab = "Blocked Emails";
                    settingsBloc.currentSettingsTabIndex = 2;
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: _currentTabIndex == 2
                          ? Theme.of(context).secondaryHeaderColor
                          : Colors.white,
                      border: Border.all(
                          color: _currentTabIndex == 2
                              ? Theme.of(context).secondaryHeaderColor
                              : bottomNavBarTextColor)),
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth / 50, vertical: 5.0),
                  child: Text(
                    "Blocked Emails",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.robotoSlab(
                        fontSize: screenWidth / 26,
                        color: _currentTabIndex == 2
                            ? Colors.white
                            : bottomNavBarTextColor),
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    child: RichText(
                  text: TextSpan(
                      text: 'You have ',
                      style: GoogleFonts.robotoSlab(
                          textStyle: TextStyle(
                              color: Colors.grey[600],
                              fontSize: screenWidth / 20)),
                      children: <TextSpan>[
                        TextSpan(
                            text: _settingsTabData.length.toString(),
                            style: GoogleFonts.robotoSlab(
                                textStyle: TextStyle(
                                    color: submitButtonColor,
                                    fontSize: screenWidth / 20))),
                        TextSpan(text: ' ${settingsBloc.currentSettingsTab}')
                      ]),
                )),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        _isFilter = !_isFilter;
                      });
                    },
                    child: Container(
                        padding: EdgeInsets.all(5.0),
                        color: _settingsTabData.length > 0
                            ? bottomNavBarTextColor
                            : Colors.grey,
                        child: SvgPicture.asset(
                          !_isFilter
                              ? 'assets/images/filter.svg'
                              : 'assets/images/icon_close.svg',
                          width: screenWidth / 20,
                        )))
              ],
            ),
          )
        ],
      ),
    );
  }

  _saveForm() async {
    if (_isFilter) {
      _filtersFormKey.currentState.save();
    }
    setState(() {
      _isLoading = true;
    });
    if (settingsBloc.currentSettingsTab == "Contacts") {
      await settingsBloc.fetchSettingsContacts(
          filtersData: _isFilter ? _filtersFormData : null);
    }
    if (settingsBloc.currentSettingsTab == "Blocked Domains") {
      await settingsBloc.fetchBlockedDomains(
          filtersData: _isFilter ? _filtersFormData : null);
    }
    if (settingsBloc.currentSettingsTab == "Blocked Emails") {
      await settingsBloc.fetchBlockedEmails(
          filtersData: _isFilter ? _filtersFormData : null);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildFilterWidget() {
    return _isFilter
        ? Container(
            padding: EdgeInsets.all(10.0),
            margin: EdgeInsets.only(top: 10.0),
            color: Colors.white,
            child: Form(
              key: _filtersFormKey,
              child: Column(
                children: [
                  (settingsBloc.currentSettingsTab == "Blocked Domains")
                      ? Container(
                          margin: EdgeInsets.only(bottom: 10.0),
                          child: TextFormField(
                            initialValue: _filtersFormData['domain'],
                            onSaved: (newValue) {
                              _filtersFormData['domain'] = newValue;
                            },
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(12.0),
                                enabledBorder: boxBorder(),
                                focusedErrorBorder: boxBorder(),
                                focusedBorder: boxBorder(),
                                errorBorder: boxBorder(),
                                fillColor: Colors.white,
                                filled: true,
                                hintText: 'Enter Domain',
                                errorStyle: GoogleFonts.robotoSlab(),
                                hintStyle: GoogleFonts.robotoSlab(
                                    textStyle: TextStyle(fontSize: 14.0))),
                            keyboardType: TextInputType.text,
                          ),
                        )
                      : (settingsBloc.currentSettingsTab == "Contacts")
                          ? Container(
                              margin: EdgeInsets.only(bottom: 10.0),
                              child: TextFormField(
                                initialValue: _filtersFormData['name'],
                                onSaved: (newValue) {
                                  _filtersFormData['name'] = newValue;
                                },
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(12.0),
                                    enabledBorder: boxBorder(),
                                    focusedErrorBorder: boxBorder(),
                                    focusedBorder: boxBorder(),
                                    errorBorder: boxBorder(),
                                    fillColor: Colors.white,
                                    filled: true,
                                    hintText: 'Enter name',
                                    errorStyle: GoogleFonts.robotoSlab(),
                                    hintStyle: GoogleFonts.robotoSlab(
                                        textStyle: TextStyle(fontSize: 14.0))),
                                keyboardType: TextInputType.text,
                              ),
                            )
                          : Container(),
                  (settingsBloc.currentSettingsTab == "Contacts" ||
                          settingsBloc.currentSettingsTab == "Blocked Emails")
                      ? Container(
                          margin: EdgeInsets.only(bottom: 10.0),
                          child: TextFormField(
                            initialValue: _filtersFormData['email'],
                            onSaved: (newValue) {
                              _filtersFormData['email'] = newValue;
                            },
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(12.0),
                                enabledBorder: boxBorder(),
                                focusedErrorBorder: boxBorder(),
                                focusedBorder: boxBorder(),
                                errorBorder: boxBorder(),
                                fillColor: Colors.white,
                                filled: true,
                                hintText: 'Enter Email Address',
                                errorStyle: GoogleFonts.robotoSlab(),
                                hintStyle: GoogleFonts.robotoSlab(
                                    textStyle: TextStyle(fontSize: 14.0))),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        )
                      : Container(),
                  (settingsBloc.currentSettingsTab == "Contacts")
                      ? Container(
                          margin: EdgeInsets.only(bottom: 10.0),
                          height: 48.0,
                          child: DropdownSearch<String>(
                            mode: Mode.BOTTOM_SHEET,
                            items: settingsBloc.userObjForDropDown,
                            onChanged: print,
                            selectedItem: _filtersFormData['created_by'] == ""
                                ? null
                                : _filtersFormData['created_by'],
                            hint: "Select Creator",
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
                              hintText: "Search a Creator here.",
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
                                  'Created By',
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
                              _filtersFormData['created_by'] = newValue;
                            },
                          ))
                      : Container(),
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
                            height: screenHeight * 0.05,
                            width: screenWidth * 0.3,
                            decoration: BoxDecoration(
                              color: submitButtonColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'Filter',
                                  style: GoogleFonts.robotoSlab(
                                      textStyle: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: screenWidth / 24)),
                                ),
                                SvgPicture.asset(
                                    'assets/images/arrow_forward.svg')
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isFilter = false;
                            });
                            FocusScope.of(context).unfocus();
                            setState(() {
                              _filtersFormData = {
                                "username": "",
                                "email": "",
                                "created_by": "",
                              };
                            });
                            _saveForm();
                          },
                          child: Container(
                            child: Text(
                              "Reset",
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
          )
        : Container();
  }

  Widget _buildUserList() {
    return Container(
      child: ListView.builder(
          itemCount: _settingsTabData.length,
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 5.0),
              color: Colors.white,
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: screenWidth * 0.6,
                          child: Text(
                            (settingsBloc.currentSettingsTab == 'Contacts')
                                ? (_settingsTabData[index].name +
                                    " " +
                                    _settingsTabData[index].lastName)
                                : (settingsBloc.currentSettingsTab ==
                                        'Blocked Domains')
                                    ? (_settingsTabData[index].domain)
                                    : (settingsBloc.currentSettingsTab ==
                                            'Blocked Emails')
                                        ? (_settingsTabData[index].email)
                                        : "",
                            style: GoogleFonts.robotoSlab(
                                color: Theme.of(context).secondaryHeaderColor,
                                fontSize: screenWidth / 25,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          width: screenWidth * 0.25,
                          child: Text(
                            _settingsTabData[index].createdOn,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.robotoSlab(
                                color: bottomNavBarTextColor,
                                fontSize: screenWidth / 27),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: Text(
                                        "Created By :",
                                        style: GoogleFonts.robotoSlab(
                                          color: bottomNavBarTextColor,
                                          fontSize: screenWidth / 26,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 5.0),
                                      child: CircleAvatar(
                                        radius: screenWidth / 20,
                                        backgroundImage: NetworkImage(
                                            _settingsTabData[index]
                                                .createdBy
                                                .profileUrl),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await settingsBloc.updateCurrentEditSetting(
                                    _settingsTabData[index]);
                                Navigator.pushNamed(context, '/create_setting');
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: 5.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1.0, color: Colors.grey[300]),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3.0)),
                                ),
                                padding: EdgeInsets.all(4.0),
                                child: SvgPicture.asset(
                                  'assets/images/Icon_edit_color.svg',
                                  width: screenWidth / 23,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                showDeleteUserAlertDialog(
                                    context, _settingsTabData[index], index);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1.0, color: Colors.grey[300]),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3.0)),
                                ),
                                padding: EdgeInsets.all(4.0),
                                child: SvgPicture.asset(
                                  'assets/images/icon_delete_color.svg',
                                  width: screenWidth / 23,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }

  void showDeleteUserAlertDialog(BuildContext context, data, index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
              (settingsBloc.currentSettingsTab == "Contacts")
                  ? (data.name)
                  : (settingsBloc.currentSettingsTab == "Blocked Domains")
                      ? (data.domain)
                      : data.email,
              style: GoogleFonts.robotoSlab(
                  color: Theme.of(context).secondaryHeaderColor),
            ),
            content: Text(
              "Are you sure you want to delete this from ${settingsBloc.currentSettingsTab}?",
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
                    deleteUser(index, data);
                  },
                  child: Text(
                    "Delete",
                    style: GoogleFonts.robotoSlab(),
                  )),
            ],
          );
        });
  }

  deleteUser(index, data) async {
    Map _result;
    setState(() {
      _isLoading = true;
    });

    if (settingsBloc.currentSettingsTab == "Contacts") {
      _result = await settingsBloc.deleteSettingsContacts(data);
    } else if (settingsBloc.currentSettingsTab == "Blocked Domains") {
      _result = await settingsBloc.deleteBlockedDomains(data);
    } else {
      _result = await settingsBloc.deleteBlockedEmails(data);
    }

    setState(() {
      _isLoading = false;
    });
    if (_result['status'] == "success") {
      showToast((_result['message'] != null)
          ? _result['message']
          : " Successfully Deleted.");
    } else if (_result['error'] == true) {
      // showToast(_result['message']);
      showToast((_currentTabIndex == 0
              ? "Contact"
              : _currentTabIndex == 1
                  ? "Blocked Domain"
                  : "Blocked Email") +
          " Successfully Deleted.");
    } else {
      showErrorMessage(context, 'Something went wrong', data, index);
    }
  }

  void showErrorMessage(
      BuildContext context, String errorContent, data, int index) {
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
          deleteUser(index, data);
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            "Settings",
            style: GoogleFonts.robotoSlab(),
          )),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                _buildTabs(),
                _buildFilterWidget(),
                _settingsTabData.length > 0
                    ? Expanded(child: _buildUserList())
                    : Container(
                        margin: EdgeInsets.only(top: 30.0),
                        child: Center(
                          child: Text(
                            "No ${settingsBloc.currentSettingsTab} Found",
                            style: GoogleFonts.robotoSlab(),
                          ),
                        ),
                      )
              ],
            ),
          ),
          new Align(
            child: loadingIndicator,
            alignment: FractionalOffset.center,
          )
        ],
      ),
      floatingActionButton: SquareFloatingActionButton(
          '/create_setting',
          "Add ${settingsBloc.currentSettingsTab.substring(0, settingsBloc.currentSettingsTab.length - 1)}",
          "Users"),
      bottomNavigationBar: BottomNavigationBarWidget(),
    );
  }
}
