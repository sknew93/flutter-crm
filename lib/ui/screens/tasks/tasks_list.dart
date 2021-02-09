import 'package:bottle_crm/bloc/task_bloc.dart';
import 'package:bottle_crm/model/task.dart';
import 'package:bottle_crm/ui/widgets/bottom_navigation_bar.dart';
import 'package:bottle_crm/ui/widgets/profile_pic_widget.dart';
import 'package:bottle_crm/ui/widgets/squareFloatingActionBtn.dart';
import 'package:bottle_crm/utils/utils.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/utils.dart';

class TasksList extends StatefulWidget {
  TasksList();
  @override
  State createState() => _TasksListState();
}

class _TasksListState extends State<TasksList> {
  bool _isFilter = false;
  final GlobalKey<FormState> _filtersFormKey = GlobalKey<FormState>();
  Map _filtersFormData = {"title": "", "status": "", "priority": ""};
  bool _isLoading = false;

  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      _tasks = taskBloc.tasks;
    });
  }

  _saveForm() async {
    if (_isFilter) {
      _filtersFormKey.currentState.save();
    }
    setState(() {
      _isLoading = true;
    });
    await taskBloc.fetchTasks(filtersData: _isFilter ? _filtersFormData : null);
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
                      text: _tasks.length.toString(),
                      style: GoogleFonts.robotoSlab(
                          textStyle: TextStyle(
                              color: submitButtonColor,
                              fontSize: screenWidth / 20))),
                  TextSpan(text: (_tasks.length < 2) ? ' Task.' : ' Tasks.')
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
                      _tasks.length > 0 ? bottomNavBarTextColor : Colors.grey,
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
                      initialValue: _filtersFormData["title"],
                      onSaved: (newValue) {
                        _filtersFormData["title"] = newValue;
                      },
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(12.0),
                          enabledBorder: boxBorder(),
                          focusedErrorBorder: boxBorder(),
                          focusedBorder: boxBorder(),
                          errorBorder: boxBorder(),
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'Enter Task Title',
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
                      child: DropdownButtonFormField(
                        decoration: InputDecoration(
                            border: boxBorder(),
                            contentPadding: EdgeInsets.all(12.0)),
                        style: GoogleFonts.robotoSlab(
                            textStyle: TextStyle(color: Colors.black)),
                        hint: Text('Select Status'),
                        value: _filtersFormData['status'] != ""
                            ? _filtersFormData['status']
                            : null,
                        onChanged: (value) {
                          FocusScope.of(context).unfocus();
                          _filtersFormData['status'] = value;
                        },
                        items: taskBloc.status.map((status) {
                          return DropdownMenuItem(
                            child: new Text(status[1]),
                            value: status[0],
                          );
                        }).toList(),
                      )),
                  Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      height: 48.0,
                      child: DropdownButtonFormField(
                        decoration: InputDecoration(
                            border: boxBorder(),
                            contentPadding: EdgeInsets.all(12.0)),
                        style: GoogleFonts.robotoSlab(
                            textStyle: TextStyle(color: Colors.black)),
                        hint: Text('Select Priority'),
                        value: _filtersFormData['priority'] != ""
                            ? _filtersFormData['priority']
                            : null,
                        onChanged: (value) {
                          FocusScope.of(context).unfocus();
                          _filtersFormData['priority'] = value;
                        },
                        items: taskBloc.priorities.map((priority) {
                          return DropdownMenuItem(
                            child: new Text(priority[1]),
                            value: priority[0],
                          );
                        }).toList(),
                      )),
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
                                "title": "",
                                "status": "",
                                "priority": ""
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

  Widget _buildTaskList() {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: ListView.builder(
          itemCount: _tasks.length,
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                taskBloc.currentTask = _tasks[index];
                taskBloc.currentTaskIndex = index;
                Navigator.pushNamed(context, '/task_details');
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
                            NetworkImage(_tasks[index].createdBy.profileUrl),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: screenWidth * 0.72,
                          margin: EdgeInsets.only(bottom: 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: screenWidth * 0.3,
                                child: Text(
                                  "${_tasks[index].title}",
                                  style: GoogleFonts.robotoSlab(
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                      fontSize: screenWidth / 24,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  _tasks[index].createdOn,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.robotoSlab(
                                      color: bottomNavBarTextColor,
                                      fontSize: screenWidth / 27),
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  _tasks[index].status,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.robotoSlab(
                                      color: Colors.blue,
                                      fontSize: screenWidth / 27),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          width: screenWidth * 0.72,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: Text(
                                    "Due : " +
                                        (_tasks[index].dueDate != null &&
                                                _tasks[index].dueDate != ""
                                            ? _tasks[index].dueDate
                                            : "N/A"),
                                    style: GoogleFonts.robotoSlab(
                                        color: bottomNavBarTextColor,
                                        fontSize: screenWidth / 27)),
                              ),
                              Container(
                                child: Text(
                                    "Priority : " +
                                        (_tasks[index].priority != null &&
                                                _tasks[index].priority != ""
                                            ? _tasks[index].priority
                                            : "N/A"),
                                    style: GoogleFonts.robotoSlab(
                                        color: bottomNavBarTextColor,
                                        fontSize: screenWidth / 27)),
                              )
                            ],
                          ),
                        ),
                        Container(
                          width: screenWidth * 0.72,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: screenWidth * 0.53,
                                margin: EdgeInsets.only(top: 5.0),
                                child: ProfilePicViewWidget(_tasks[index]
                                    .assignedTo
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
                                        await taskBloc.updateCurrentEditTask(
                                            _tasks[index]);
                                        Navigator.pushNamed(
                                            context, '/create_task');
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
                                        showDeleteTaskAlertDialog(
                                            context, _tasks[index], index);
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

  void showDeleteTaskAlertDialog(BuildContext context, Task task, index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
              task.title,
              style: GoogleFonts.robotoSlab(
                  color: Theme.of(context).secondaryHeaderColor),
            ),
            content: Text(
              "Are you sure you want to delete this Task?",
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
                    deleteTask(index, task);
                  },
                  child: Text(
                    "Delete",
                    style: GoogleFonts.robotoSlab(),
                  )),
            ],
          );
        });
  }

  deleteTask(index, task) async {
    setState(() {
      _isLoading = true;
    });
    Map _result = await taskBloc.deleteTask(task);
    setState(() {
      _isLoading = false;
    });
    if (_result['error'] == false) {
      showToast(_result['message']);
    } else if (_result['error'] == true) {
      showToast(_result['message']);
    } else {
      showErrorMessage(context, 'Something went wrong', index, task);
    }
  }

  void showErrorMessage(
      BuildContext context, String errorContent, int index, Task task) {
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
          deleteTask(index, task);
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
        title: Text("Tasks", style: GoogleFonts.robotoSlab()),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                _buildTabBar(_tasks.length),
                _buildFilterWidget(),
                _tasks.length > 0
                    ? Expanded(child: _buildTaskList())
                    : Container(
                        margin: EdgeInsets.only(top: 30.0),
                        child: Text(
                          "No Tasks Found",
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
          SquareFloatingActionButton('/create_task', "Add Task", "Tasks"),
      bottomNavigationBar: BottomNavigationBarWidget(),
    );
  }
}
