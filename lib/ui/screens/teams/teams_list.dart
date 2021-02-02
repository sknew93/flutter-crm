import 'package:bottle_crm/bloc/lead_bloc.dart';
import 'package:bottle_crm/bloc/team_bloc.dart';
import 'package:bottle_crm/model/team.dart';
import 'package:bottle_crm/ui/widgets/bottom_navigation_bar.dart';
import 'package:bottle_crm/ui/widgets/profile_pic_widget.dart';
import 'package:bottle_crm/ui/widgets/squareFloatingActionBtn.dart';
import 'package:bottle_crm/utils/utils.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';

class TeamsList extends StatefulWidget {
  TeamsList();
  @override
  State createState() => _TeamsListState();
}

class _TeamsListState extends State<TeamsList> {
  bool _isFilter = false;
  final GlobalKey<FormState> _filtersFormKey = GlobalKey<FormState>();
  Map _filtersFormData = {
    "team_name": "",
    "created_by": "",
    "assigned_users": []
  };
  bool _isLoading = false;

  List<Team> _teams = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      _teams = teamBloc.teams;
    });
  }

  _saveForm() async {
    if (_isFilter) {
      _filtersFormKey.currentState.save();
    }
    setState(() {
      _isLoading = true;
    });
    await teamBloc.fetchTeams(filtersData: _isFilter ? _filtersFormData : null);
    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildMultiSelectDropdown(data) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      child: MultiSelectFormField(
        border: boxBorder(),
        fillColor: Colors.white,
        autovalidate: false,
        dataSource: data,
        textField: 'name',
        valueField: 'id',
        okButtonLabel: 'OK',
        chipLabelStyle:
            GoogleFonts.robotoSlab(textStyle: TextStyle(color: Colors.black)),
        dialogTextStyle: GoogleFonts.robotoSlab(),
        cancelButtonLabel: 'CANCEL',
        hintWidget: Text(
          "Please choose one or more",
          style:
              GoogleFonts.robotoSlab(textStyle: TextStyle(color: Colors.grey)),
        ),
        title: Text(
          "Assigned Profiles",
          style: GoogleFonts.robotoSlab(
              textStyle: TextStyle(color: Colors.grey[700]),
              fontSize: screenWidth / 26),
        ),
        initialValue: _filtersFormData["assigned_users"],
        onSaved: (value) {
          if (value == null) return;
          setState(() {
            _filtersFormData["assigned_users"] = value;
          });
        },
      ),
    );
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
                      text: _teams.length.toString(),
                      style: GoogleFonts.robotoSlab(
                          textStyle: TextStyle(
                              color: submitButtonColor,
                              fontSize: screenWidth / 20))),
                  TextSpan(text: (_teams.length < 2) ? ' Team.' : ' Teams.')
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
                  color:
                      _teams.length > 0 ? bottomNavBarTextColor : Colors.grey,
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
                      initialValue: _filtersFormData["team_name"],
                      onSaved: (newValue) {
                        _filtersFormData["team_name"] = newValue;
                      },
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(12.0),
                          enabledBorder: boxBorder(),
                          focusedErrorBorder: boxBorder(),
                          focusedBorder: boxBorder(),
                          errorBorder: boxBorder(),
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'Enter Team Name',
                          errorStyle: GoogleFonts.robotoSlab(),
                          hintStyle: GoogleFonts.robotoSlab(
                              textStyle:
                                  TextStyle(fontSize: screenWidth / 26))),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      height: 48.0,
                      child: DropdownSearch<String>(
                        mode: Mode.BOTTOM_SHEET,
                        items: teamBloc.userObjForDropDown,
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
                      )),
                  _buildMultiSelectDropdown(leadBloc.usersObjForDropdown),
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
                                "created_by": "",
                                "assigned_users": []
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

  Widget _buildTeamList() {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: ListView.builder(
          itemCount: _teams.length,
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                teamBloc.currentTeam = _teams[index];
                teamBloc.currentTeamIndex = index;
                Navigator.pushNamed(context, '/team_details');
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 5.0),
                color: Colors.white,
                padding: EdgeInsets.all(10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 10.0),
                      child: CircleAvatar(
                        radius: screenWidth / 15,
                        backgroundImage:
                            NetworkImage(_teams[index].createdBy.profileUrl),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: screenWidth * 0.47,
                                child: Text(
                                  "${_teams[index].name}",
                                  style: GoogleFonts.robotoSlab(
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                      fontSize: screenWidth / 24,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerRight,
                                width: screenWidth * 0.25,
                                child: Text(
                                  _teams[index].createdOnText == ""
                                      ? _teams[index].createdOn
                                      : _teams[index].createdOnText,
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
                          child: Row(
                            children: [
                              Container(
                                width: screenWidth * 0.53,
                                margin: EdgeInsets.only(top: 5.0),
                                child: ProfilePicViewWidget(_teams[index]
                                    .users
                                    .map((assignedUser) =>
                                        assignedUser.profileUrl)
                                    .toList()),
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        await teamBloc.updateCurrentEditTeam(
                                            _teams[index]);
                                        Navigator.pushNamed(
                                            context, '/create_team');
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(right: 8.0),
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
                                        showDeleteTeamAlertDialog(
                                            context, _teams[index], index);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(right: 8.0),
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
                  ],
                ),
              ),
            );
          }),
    );
  }

  void showDeleteTeamAlertDialog(BuildContext context, Team team, index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
              team.name,
              style: GoogleFonts.robotoSlab(
                  color: Theme.of(context).secondaryHeaderColor),
            ),
            content: Text(
              "Are you sure you want to delete this Team?",
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
                    deleteTeam(index, team);
                  },
                  child: Text(
                    "Delete",
                    style: GoogleFonts.robotoSlab(),
                  )),
            ],
          );
        });
  }

  deleteTeam(index, team) async {
    setState(() {
      _isLoading = true;
    });
    Map _result = await teamBloc.deleteTeam(team);
    setState(() {
      _isLoading = false;
    });
    if (_result['error'] == false) {
      showToast(_result['message']);
    } else if (_result['error'] == true) {
      showToast(_result['message']);
    } else {
      showErrorMessage(context, 'Something went wrong', index, team);
    }
  }

  void showErrorMessage(
      BuildContext context, String errorContent, int index, Team team) {
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
          deleteTeam(index, team);
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
        title: Text("Teams", style: GoogleFonts.robotoSlab()),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                _buildTabBar(_teams.length),
                _buildFilterWidget(),
                _teams.length > 0
                    ? Expanded(child: _buildTeamList())
                    : Container(
                        margin: EdgeInsets.only(top: 30.0),
                        child: Text(
                          "No Teams Found",
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
          SquareFloatingActionButton('/create_team', "Add Team", "Teams"),
      bottomNavigationBar: BottomNavigationBarWidget(),
    );
  }
}
