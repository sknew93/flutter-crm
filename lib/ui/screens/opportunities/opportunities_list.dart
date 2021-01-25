import 'package:bottle_crm/bloc/account_bloc.dart';
import 'package:bottle_crm/bloc/opportunity_bloc.dart';
import 'package:bottle_crm/model/opportunities.dart';
import 'package:bottle_crm/ui/widgets/bottom_navigation_bar.dart';
import 'package:bottle_crm/ui/widgets/squareFloatingActionBtn.dart';
import 'package:bottle_crm/ui/widgets/tags_widget.dart';
import 'package:bottle_crm/utils/utils.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';

class OpportunitiesList extends StatefulWidget {
  OpportunitiesList();
  @override
  State createState() => _OpportunitiesListState();
}

class _OpportunitiesListState extends State<OpportunitiesList> {
  bool _isFilter = false;
  final GlobalKey<FormState> _filtersFormKey = GlobalKey<FormState>();
  Map _filtersFormData = {
    "name": "",
    "account": "",
    "stage": "",
    "lead_source": "",
    "tags": []
  };
  bool _isLoading = false;

  List<Opportunity> _opportunities = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      _opportunities = opportunityBloc.opportunities;
    });
  }

  _saveForm() async {
    if (_isFilter) {
      _filtersFormKey.currentState.save();
    }
    setState(() {
      _isLoading = true;
    });
    await opportunityBloc.fetchOpportunities(
        filtersData: _isFilter ? _filtersFormData : null);
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
                      text: _opportunities.length.toString(),
                      style: GoogleFonts.robotoSlab(
                          textStyle: TextStyle(
                              color: submitButtonColor,
                              fontSize: screenWidth / 20))),
                  TextSpan(
                      text: (_opportunities.length < 2)
                          ? ' Opportunity.'
                          : ' Opportunities.')
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
                  color: _opportunities.length > 0
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
                          hintText: 'Enter Opportunity Name',
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
                      hint: Text('Select Stage'),
                      value: (_filtersFormData['stage'] != "")
                          ? _filtersFormData['stage']
                          : null,
                      onChanged: (value) {
                        _filtersFormData['stage'] = value;
                      },
                      items:
                          opportunityBloc.stageObjforDropDown.map((location) {
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
                      hint: Text('Select Lead Source'),
                      value: (_filtersFormData['lead_source'] != "")
                          ? _filtersFormData['lead_source']
                          : null,
                      onChanged: (value) {
                        _filtersFormData['lead_source'] = value;
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
                  Container(
                    margin: EdgeInsets.only(bottom: 5.0),
                    child: MultiSelectFormField(
                      border: boxBorder(),
                      fillColor: Colors.white,
                      autovalidate: false,
                      dataSource: opportunityBloc.tags,
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
                        "Tags",
                        style: GoogleFonts.robotoSlab(),
                      ),
                      initialValue: _filtersFormData['tags'],
                      onSaved: (value) {
                        if (value == null) return;
                        _filtersFormData['tags'] = value;
                      },
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
                                "stage": "",
                                "lead_source": "",
                                "tags": []
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

  Widget _buildOpportunityList() {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: ListView.builder(
          itemCount: _opportunities.length,
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                opportunityBloc.currentOpportunity = _opportunities[index];
                opportunityBloc.currentOpportunityIndex = index;
                Navigator.pushNamed(context, '/opportunity_details');
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
                            width: screenWidth * 0.55,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: screenWidth * 0.30,
                                  child: Text(
                                    "${_opportunities[index].name}",
                                    style: GoogleFonts.robotoSlab(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        fontSize: screenWidth / 24,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerRight,
                                  width: screenWidth * 0.20,
                                  child: Text(
                                    _opportunities[index].createdOnText == ""
                                        ? _opportunities[index].createdOn
                                        : _opportunities[index].createdOnText,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.robotoSlab(
                                        color: bottomNavBarTextColor,
                                        fontSize: screenWidth / 27),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                accountBloc.currentAccount =
                                    _opportunities[index].account;
                                Navigator.pushNamed(
                                    context, '/account_details');
                              });
                            },
                            child: Container(
                              alignment: Alignment.centerLeft,
                              width: screenWidth * 0.25,
                              child: Text(
                                _opportunities[index].account.name != null
                                    ? "${_opportunities[index].account.name}"
                                    : "",
                                // overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.robotoSlab(
                                    color: Colors.blue,
                                    fontSize: screenWidth / 27,
                                    textStyle: TextStyle(
                                        decoration: TextDecoration.underline)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            alignment: Alignment.centerRight,
                            // width: screenWidth * 0.45,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text(
                                    "Stage : ",
                                    style: GoogleFonts.robotoSlab(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        fontSize: screenWidth / 30,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    _opportunities[index].createdOnText != null
                                        ? _opportunities[index]
                                            .stage
                                            .toLowerCase()
                                            .capitalizeFirstofEach()
                                        : "N/A",
                                    // overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.robotoSlab(
                                        color: bottomNavBarTextColor,
                                        fontSize: screenWidth / 28),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            // width: screenWidth * 0.45,
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  child: Text(
                                    "Lead Source : ",
                                    style: GoogleFonts.robotoSlab(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        fontSize: screenWidth / 30,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    _opportunities[index].leadSource != ""
                                        ? _opportunities[index]
                                            .leadSource
                                            .toLowerCase()
                                            .capitalizeFirstofEach()
                                        : "N/A",
                                    // overflow: TextOverflow.clip,
                                    style: GoogleFonts.robotoSlab(
                                        color: bottomNavBarTextColor,
                                        fontSize: screenWidth / 28),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _opportunities[index].tags.length != 0
                              ? Container(
                                  margin: EdgeInsets.only(top: 10.0),
                                  width: screenWidth * 0.54,
                                  child:
                                      TagViewWidget(_opportunities[index].tags),
                                )
                              : Container(),
                          Container(
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    await opportunityBloc
                                        .updateCurrentEditOpportunity(
                                            _opportunities[index]);
                                    Navigator.pushNamed(
                                        context, '/create_opportunity');
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 10.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1.0, color: Colors.grey[300]),
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
                                    showDeleteOpportunityAlertDialog(
                                        context, _opportunities[index], index);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1.0, color: Colors.grey[300]),
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
            );
          }),
    );
  }

  void showDeleteOpportunityAlertDialog(
      BuildContext context, Opportunity opportunity, index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
              opportunity.name,
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
                    deleteOpportunity(index, opportunity);
                  },
                  child: Text(
                    "Delete",
                    style: GoogleFonts.robotoSlab(),
                  )),
            ],
          );
        });
  }

  deleteOpportunity(index, opportunity) async {
    // setState(() {
    //   _contacts.removeAt(index);
    // });
    setState(() {
      _isLoading = true;
    });
    Map _result = await opportunityBloc.deleteOpportunity(opportunity);
    setState(() {
      _isLoading = false;
    });
    if (_result['error'] == false) {
      showToast(_result['message']);
      Navigator.of(context).pop();
    } else if (_result['error'] == true) {
      showToast(_result['message']);
    } else {
      showErrorMessage(context, 'Something went wrong', index, opportunity);
    }
  }

  void showErrorMessage(BuildContext context, String errorContent, int index,
      Opportunity opportunity) {
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
          deleteOpportunity(index, opportunity);
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
        title: Text("Opportunities", style: GoogleFonts.robotoSlab()),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                _buildTabBar(_opportunities.length),
                _buildFilterWidget(),
                _opportunities.length > 0
                    ? Expanded(child: _buildOpportunityList())
                    : Container(
                        margin: EdgeInsets.only(top: 30.0),
                        child: Text(
                          "No Opportunity Found",
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
      floatingActionButton: SquareFloatingActionButton(
          '/create_opportunity', "Add Opportunity", "Opportunities"),
      bottomNavigationBar: BottomNavigationBarWidget(),
    );
  }
}
