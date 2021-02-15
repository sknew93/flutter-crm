import 'package:bottle_crm/bloc/account_bloc.dart';
import 'package:bottle_crm/bloc/contact_bloc.dart';
import 'package:bottle_crm/bloc/task_bloc.dart';
import 'package:bottle_crm/ui/widgets/bottom_navigation_bar.dart';
import 'package:bottle_crm/utils/utils.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';

class CreateTask extends StatefulWidget {
  CreateTask();
  @override
  State createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  final GlobalKey<FormState> _createTaskFormKey = GlobalKey<FormState>();
  FilePickerResult result;
  PlatformFile file;
  bool _isLoading = false;
  Map _errors;
  DateTime _selectedDate;
  FocusNode _focuserr;
  FocusNode _titleFocusNode = new FocusNode();
  FocusNode _statusFocusNode = new FocusNode();
  FocusNode _priorityFocusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (_focuserr != null) {
      _focuserr.dispose();
    }
    _titleFocusNode.dispose();
    _statusFocusNode.dispose();
    _priorityFocusNode.dispose();
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

    if (!_createTaskFormKey.currentState.validate()) {
      return;
    }
    _createTaskFormKey.currentState.save();
    Map _result;

    setState(() {
      _isLoading = true;
    });

    if (taskBloc.currentEditTaskId == null) {
      _result = await taskBloc.createTask();
    } else {
      _result = await taskBloc.editTask();
    }

    setState(() {
      _isLoading = false;
    });

    if (_result['error'] == false) {
      setState(() {
        _errors = null;
      });
      showToast(_result['message']);
      Navigator.pushReplacementNamed(context, '/tasks');
    } else if (_result['error'] == true) {
      setState(() {
        _errors = _result['errors'];
      });
      if (_errors['title'] != null && _focuserr == null) {
        _focuserr = _titleFocusNode;
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
      showErrorMessage(context, "Something went wrong.");
    }
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
        taskBloc.currentEditTask['due_date'] = DateFormat("dd-MM-yyyy")
            .format(DateFormat("yyyy-MM-dd").parse(_selectedDate.toString()));
      });
    } else {
      _selectedDate = null;
    }
  }

  Widget _buildForm() {
    return Container(
        child: Form(
            key: _createTaskFormKey,
            child: Column(children: [
              Container(
                child: Column(
                  children: [
                    Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(bottom: 5.0),
                        child: RichText(
                          text: TextSpan(
                            text: 'Title',
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
                        focusNode: _titleFocusNode,
                        maxLines: 1,
                        initialValue: taskBloc.currentEditTask['title'],
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(12.0),
                            enabledBorder: boxBorder(),
                            focusedErrorBorder: boxBorder(),
                            focusedBorder: boxBorder(),
                            errorBorder: boxBorder(),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "Enter Title",
                            errorStyle: GoogleFonts.robotoSlab(),
                            hintStyle: GoogleFonts.robotoSlab(
                                textStyle: TextStyle(fontSize: 14.0))),
                        keyboardType: TextInputType.text,
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
                          taskBloc.currentEditTask['title'] = value;
                        },
                      ),
                    ),
                    _errors != null && _errors['title'] != null
                        ? Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _errors['title'][0],
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
                            text: 'Status ',
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
                        child: DropdownButtonFormField(
                          focusNode: _statusFocusNode,
                          decoration: InputDecoration(
                              border: boxBorder(),
                              contentPadding: EdgeInsets.all(12.0)),
                          style: GoogleFonts.robotoSlab(
                              textStyle: TextStyle(color: Colors.black)),
                          hint: Text('Select Status'),
                          value: taskBloc.currentEditTask['status'] != ""
                              ? taskBloc.currentEditTask['status']
                              : null,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              if (_focuserr == null) {
                                _focuserr = _statusFocusNode;
                              }
                              return 'This field is required.';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            FocusScope.of(context).unfocus();
                            taskBloc.currentEditTask['status'] = value;
                          },
                          items: taskBloc.status.map((status) {
                            return DropdownMenuItem(
                              child: new Text(status[1]),
                              value: status[0],
                            );
                          }).toList(),
                        )),
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
                            text: 'Priority',
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
                        child: DropdownButtonFormField(
                          focusNode: _priorityFocusNode,
                          decoration: InputDecoration(
                              border: boxBorder(),
                              contentPadding: EdgeInsets.all(12.0)),
                          style: GoogleFonts.robotoSlab(
                              textStyle: TextStyle(color: Colors.black)),
                          hint: Text('Select Priority'),
                          value: taskBloc.currentEditTask['priority'] != ""
                              ? taskBloc.currentEditTask['priority']
                              : null,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              if (_focuserr == null) {
                                _focuserr = _priorityFocusNode;
                              }
                              return 'This field is required.';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            FocusScope.of(context).unfocus();
                            taskBloc.currentEditTask['priority'] = value;
                          },
                          items: taskBloc.priorities.map((priority) {
                            return DropdownMenuItem(
                              child: new Text(priority[1]),
                              value: priority[0],
                            );
                          }).toList(),
                        )),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
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
                                : (taskBloc.currentEditTaskId != null)
                                    ? Text(taskBloc.currentEditTask['due_date'],
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(bottom: 5.0),
                      child: Text(
                        'Account :',
                        style: GoogleFonts.robotoSlab(
                            textStyle: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor,
                                fontWeight: FontWeight.w500,
                                fontSize: screenWidth / 25)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 5.0),
                      child: DropdownSearch<String>(
                        mode: Mode.BOTTOM_SHEET,
                        items: taskBloc.accounts
                            .map((account) => account.name)
                            .toList(),
                        onChanged: print,
                        selectedItem: taskBloc.currentEditTask['account'],
                        hint: 'Select Account',
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
                            hintText: "Search an Account",
                            hintStyle: GoogleFonts.robotoSlab(
                                textStyle: TextStyle(fontSize: 14.0)),
                            errorStyle: GoogleFonts.robotoSlab()),
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
                              'Accounts',
                              style: GoogleFonts.robotoSlab(
                                  textStyle: TextStyle(
                                      fontSize: screenWidth / 20,
                                      color: Colors.white)),
                            ),
                          ),
                        ),
                        popupItemBuilder: (context, item, isSelected) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 10.0),
                            child: Text(
                              item,
                              style: GoogleFonts.robotoSlab(
                                  textStyle:
                                      TextStyle(fontSize: screenWidth / 22)),
                            ),
                          );
                        },
                        popupShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        onSaved: (newValue) {
                          if (newValue == null) {
                            taskBloc.currentEditTask['account'] = "";
                          } else {
                            taskBloc.currentEditTask['account'] = newValue;
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
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: screenWidth / 25))),
                        )),
                    Container(
                      margin: EdgeInsets.only(bottom: 5.0),
                      child: MultiSelectFormField(
                        border: boxBorder(),
                        fillColor: Colors.white,
                        autovalidate: false,
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
                        initialValue: taskBloc.currentEditTask['contacts'],
                        onSaved: (value) {
                          if (value == null) {
                            taskBloc.currentEditTask['contacts'] = [];
                          } else {
                            taskBloc.currentEditTask['contacts'] = value;
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
                        initialValue: taskBloc.currentEditTask['teams'],
                        onSaved: (value) {
                          if (value == null) {
                            taskBloc.currentEditTask['teams'] = [];
                          } else {
                            taskBloc.currentEditTask['teams'] = value;
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
                          "Assigned Users",
                          style: GoogleFonts.robotoSlab(),
                        ),
                        initialValue: taskBloc.currentEditTask['assigned_to'],
                        onSaved: (value) {
                          if (value == null) {
                            taskBloc.currentEditTask['assigned_to'] = [];
                          } else {
                            taskBloc.currentEditTask['assigned_to'] = value;
                          }
                        },
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
                              taskBloc.currentEditTaskId != null
                                  ? 'Update Task'
                                  : 'Create Task',
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
          "Create Task",
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
