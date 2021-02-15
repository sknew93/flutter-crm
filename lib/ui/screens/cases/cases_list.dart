import 'package:bottle_crm/bloc/case_bloc.dart';
import 'package:bottle_crm/bloc/opportunity_bloc.dart';
import 'package:bottle_crm/model/case.dart';
import 'package:bottle_crm/ui/widgets/bottom_navigation_bar.dart';
import 'package:bottle_crm/ui/widgets/squareFloatingActionBtn.dart';
import 'package:bottle_crm/utils/utils.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CasesList extends StatefulWidget {
  CasesList();
  @override
  State createState() => _CasesListState();
}

class _CasesListState extends State<CasesList> {
  bool _isFilter = false;
  final GlobalKey<FormState> _filtersFormKey = GlobalKey<FormState>();
  Map _filtersFormData = {
    "name": "",
    "account": "",
    "status": "",
    "priority": "",
  };
  bool _isLoading = false;

  List _cases = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      _cases = caseBloc.cases;
    });
  }

  _saveForm() async {
    if (_isFilter) {
      _filtersFormKey.currentState.save();
    }
    setState(() {
      _isLoading = true;
    });
    await caseBloc.fetchCases(filtersData: _isFilter ? _filtersFormData : null);
    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildTabBar(int length) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              child: RichText(
            text: TextSpan(
                text: 'You have ',
                style: GoogleFonts.robotoSlab(
                    textStyle: TextStyle(
                        color: Colors.grey[600], fontSize: screenWidth / 20)),
                children: <TextSpan>[
                  TextSpan(
                      text: caseBloc.casesCount.toString(),
                      style: GoogleFonts.robotoSlab(
                          textStyle: TextStyle(
                              color: submitButtonColor,
                              fontSize: screenWidth / 20))),
                  TextSpan(
                      text: (caseBloc.casesCount < 2) ? ' Case.' : ' Cases.')
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
                  color: caseBloc.casesCount > 0
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
    );
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
                  Container(
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
                          hintText: 'Enter Case Name',
                          errorStyle: GoogleFonts.robotoSlab(),
                          hintStyle: GoogleFonts.robotoSlab(
                              textStyle: TextStyle(fontSize: 14.0))),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      height: 48.0,
                      child: DropdownSearch<String>(
                        mode: Mode.BOTTOM_SHEET,
                        items: opportunityBloc.accountsObjforDropDown,
                        onChanged: print,
                        selectedItem: _filtersFormData['account'] == ""
                            ? null
                            : _filtersFormData['account'],
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
                          _filtersFormData['account'] = newValue;
                        },
                      )),
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                          border: boxBorder(),
                          contentPadding: EdgeInsets.all(12.0)),
                      style: GoogleFonts.robotoSlab(
                          textStyle: TextStyle(color: Colors.black)),
                      hint: Text('Select Status'),
                      value: (_filtersFormData['status'] != "")
                          ? _filtersFormData['status']
                          : null,
                      onChanged: (value) {
                        _filtersFormData['status'] = value;
                      },
                      items: caseBloc.statusObjForDropDown.map((location) {
                        return DropdownMenuItem(
                          child: new Text(location[1]),
                          value: location[0],
                        );
                      }).toList(),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                          border: boxBorder(),
                          contentPadding: EdgeInsets.all(12.0)),
                      style: GoogleFonts.robotoSlab(
                          textStyle: TextStyle(color: Colors.black)),
                      hint: Text('Select Priority'),
                      value: (_filtersFormData['priority'] != "")
                          ? _filtersFormData['priority']
                          : null,
                      onChanged: (value) {
                        _filtersFormData['lead_source'] = value;
                      },
                      items: caseBloc.priorityObjForDropDown.map((location) {
                        return DropdownMenuItem(
                          child: new Text(location[1]),
                          value: location[0],
                        );
                      }).toList(),
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
                                "name": "",
                                "account": "",
                                "status": "",
                                "priority": "",
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

  Widget _buildCasesList() {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: ListView.builder(
          itemCount: caseBloc.casesCount,
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                caseBloc.currentCase = _cases[index];
                caseBloc.currentEditCaseId = index.toString();
                Navigator.pushNamed(context, '/case_details');
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 5.0),
                color: Colors.white,
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: screenWidth * 0.6,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text(
                                    _cases[index]
                                        .name
                                        .toString()
                                        .toLowerCase()
                                        .capitalizeFirstofEach(),
                                    maxLines: 2,
                                    style: GoogleFonts.robotoSlab(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        fontSize: screenWidth / 24,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Container(
                                  // width: screenWidth * 0.3,
                                  child: Text(
                                    _cases[index].createdOn,
                                    maxLines: 2,
                                    style: GoogleFonts.robotoSlab(
                                        color: bottomNavBarTextColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: screenWidth / 30),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            // width: screenWidth * 0.3,
                            child: Text(
                              _cases[index].status != ""
                                  ? _cases[index].status
                                  : "N/A",
                              maxLines: 2,
                              style: GoogleFonts.robotoSlab(
                                  color: (_cases[index].status == 'Closed' ||
                                          _cases[index].status == "Rejected" ||
                                          _cases[index].status == "Duplicate")
                                      ? Colors.red
                                      : (_cases[index].status == 'Assigned')
                                          ? Colors.green
                                          : Colors.orangeAccent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: screenWidth / 26),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: screenWidth * 0.6,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text("Account : ",
                                          style: GoogleFonts.robotoSlab(
                                              textStyle: GoogleFonts.robotoSlab(
                                                  color: Colors.grey,
                                                  fontSize: screenWidth / 28))),
                                    ),
                                    Expanded(
                                      child: Text(
                                          _cases[index].account.name != null &&
                                                  _cases[index].account.name !=
                                                      ""
                                              ? _cases[index].account.name
                                              : "N/A",
                                          style: GoogleFonts.robotoSlab(
                                              textStyle: GoogleFonts.robotoSlab(
                                                  color:
                                                      bottomNavBarSelectedTextColor,
                                                  fontSize: screenWidth / 28))),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: screenWidth * 0.44,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text("Priority : ",
                                          style: GoogleFonts.robotoSlab(
                                              textStyle: GoogleFonts.robotoSlab(
                                                  color: Colors.grey,
                                                  fontSize: screenWidth / 28))),
                                    ),
                                    Expanded(
                                      child: Text(
                                          _cases[index].priority != null &&
                                                  _cases[index].priority != ""
                                              ? _cases[index].priority
                                              : "N/A",
                                          style: GoogleFonts.robotoSlab(
                                              textStyle: GoogleFonts.robotoSlab(
                                                  color:
                                                      bottomNavBarSelectedTextColor,
                                                  fontSize: screenWidth / 28))),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          await caseBloc.updateCurrentEditCase(
                                              _cases[index]);
                                          Navigator.pushNamed(
                                              context, '/create_case');
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(right: 10.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1.0,
                                                color: Colors.grey[300]),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(3.0)),
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
                                          showDeleteCaseAlertDialog(
                                              context, _cases[index], index);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1.0,
                                                color: Colors.grey[300]),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(3.0)),
                                          ),
                                          padding: EdgeInsets.all(4.0),
                                          child: SvgPicture.asset(
                                            'assets/images/icon_delete_color.svg',
                                            width: screenWidth / 23,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  void showDeleteCaseAlertDialog(BuildContext context, Case data, index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
              data.name,
              style: GoogleFonts.robotoSlab(
                  color: Theme.of(context).secondaryHeaderColor),
            ),
            content: Text(
              "Are you sure you want to delete this case?",
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
                    deleteCase(index, data);
                  },
                  child: Text(
                    "Delete",
                    style: GoogleFonts.robotoSlab(),
                  )),
            ],
          );
        });
  }

  deleteCase(index, data) async {
    setState(() {
      _isLoading = true;
    });
    Map _result = await caseBloc.deleteCase(data);
    setState(() {
      _isLoading = false;
    });
    if (_result['error'] == false) {
      showToast(_result['message']);
    } else if (_result['error'] == true) {
      showToast(_result['message']);
    } else {
      showErrorMessage(context, 'Something went wrong', index, data);
    }
  }

  void showErrorMessage(
      BuildContext context, String errorContent, int index, Case data) {
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
          deleteCase(index, data);
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
        title: Text("Cases", style: GoogleFonts.robotoSlab()),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                _buildTabBar(caseBloc.casesCount),
                _buildFilterWidget(),
                caseBloc.casesCount > 0
                    ? Expanded(child: _buildCasesList())
                    : Container(
                        margin: EdgeInsets.only(top: 30.0),
                        child: Text(
                          "No Cases Found",
                          style: GoogleFonts.robotoSlab(),
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
      floatingActionButton:
          SquareFloatingActionButton('/create_case', "Add Case", "Cases"),
      bottomNavigationBar: BottomNavigationBarWidget(),
    );
  }
}
