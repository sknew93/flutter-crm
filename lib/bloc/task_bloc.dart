import 'dart:convert';

import 'package:bottle_crm/model/task.dart';
import 'package:bottle_crm/services/crm_services.dart';
import 'package:intl/intl.dart';

import '../model/account.dart';

class TaskBloc {
  List<Task> _tasks = [];
  List _status = [];
  List _priorities = [];
  Map _currentEditTask = {
    'title': "",
    'status': "",
    'priority': "",
    'due_date': "",
    'account': null,
    'contacts': [],
    'teams': [],
    'assigned_to': []
  };
  List<Account> _accounts = [];
  String _currentEditTaskId;
  Task _currentTask;
  int _currentTaskIndex;

  Future fetchTasks({filtersData}) async {
    await CrmService().getTasks(queryParams: filtersData).then((response) {
      var res = json.decode(response.body);

      _tasks.clear();

      if (res['accounts_list'] != null) {
        _accounts.clear();
        res['accounts_list'].forEach((_account) {
          Account account = Account.fromJson(_account);
          _accounts.add(account);
        });
      }
      if (res['tasks'] != null) {
        res['tasks'].forEach((_task) {
          _accounts.forEach((Account _account) {
            if (_task['account'] == _account.id) {
              _task['account'] = _account;
            }
          });
          Task task = Task.fromJson(_task);
          _tasks.add(task);
        });
      }
      if (res['status'] != null) {
        _status.clear();
        _status = res['status'];
      }
      if (res['priority'] != null) {
        _priorities.clear();
        _priorities = res['priority'];
      }
    });
  }

  Future createTask() async {
    Map result;
    Map _copyCurrentEditTask = Map.from(_currentEditTask);

    _copyCurrentEditTask['contacts'] = (_copyCurrentEditTask['contacts']
        .map((contacts) => contacts.toString())).toList().toString();

    _copyCurrentEditTask['teams'] = (_copyCurrentEditTask['teams']
        .map((teams) => teams.toString())).toList().toString();

    _copyCurrentEditTask['assigned_to'] = (_copyCurrentEditTask['assigned_to']
        .map((assignedTo) => assignedTo.toString())).toList().toString();

    if (_copyCurrentEditTask['due_date'] != "")
      _copyCurrentEditTask['due_date'] = DateFormat("yyyy-MM-dd").format(
          DateFormat("dd-MM-yyyy").parse(_copyCurrentEditTask['due_date']));

    accounts.forEach((account) {
      if (account.name == _copyCurrentEditTask['account']) {
        _copyCurrentEditTask['account'] = account.id.toString();
      }
    });

    print(_copyCurrentEditTask);

    await CrmService().createTask(_copyCurrentEditTask).then((response) async {
      var res = json.decode(response.body);
      if (res['error'] == false) {
        await fetchTasks();
      }
      result = res;
    }).catchError((onError) {
      print('createTask Error >> $onError');
      result = {"status": "error", "message": "Something went wrong"};
    });
    return result;
  }

  Future editTask() async {
    Map _result;
    Map _copyOfCurrentEditTask = Map.from(_currentEditTask);

    _copyOfCurrentEditTask['contacts'] = (_copyOfCurrentEditTask['contacts']
        .map((contacts) => contacts.toString())).toList().toString();

    _copyOfCurrentEditTask['teams'] = (_copyOfCurrentEditTask['teams']
        .map((teams) => teams.toString())).toList().toString();

    _copyOfCurrentEditTask['assigned_to'] =
        (_copyOfCurrentEditTask['assigned_to']
            .map((assignedTo) => assignedTo.toString())).toList().toString();

    accounts.forEach((account) {
      if (account.name == _copyOfCurrentEditTask['account']) {
        _copyOfCurrentEditTask['account'] = account.id.toString();
      }
    });

    if (_copyOfCurrentEditTask['due_date'] != "")
      _copyOfCurrentEditTask['due_date'] = DateFormat("yyyy-MM-dd").format(
          DateFormat("dd-MM-yyyy").parse(_copyOfCurrentEditTask['due_date']));

    await CrmService()
        .editTask(_copyOfCurrentEditTask, _currentEditTaskId)
        .then((response) async {
      var res = json.decode(response.body);
      if (res['error'] == false) {
        await fetchTasks();
      }
      _result = res;
    }).catchError((onError) {
      print("editTask Error >> $onError");
      _result = {"status": "error", "message": "Something went wrong."};
    });
    return _result;
  }

  Future deleteTask(Task task) async {
    Map result;
    await CrmService().deleteTask(task.id).then((response) async {
      var res = (json.decode(response.body));
      await fetchTasks();
      result = res;
    }).catchError((onError) {
      print("deleteTask Error >> $onError");
      result = {"status": "error", "message": "Something went wrong."};
    });
    return result;
  }

  cancelCurrentEditTask() {
    _currentEditTaskId = null;
    _currentEditTask = {
      'title': "",
      'status': "",
      'priority': "",
      'due_date': "",
      'account': null,
      'contacts': [],
      'teams': [],
      'assigned_to': []
    };
  }

  updateCurrentEditTask(Task task) {
    _currentEditTaskId = task.id.toString();

    List contacts = [];
    List teams = [];
    List assignedUsers = [];

    task.contacts.forEach((contact) {
      contacts.add(contact.id);
    });

    task.assignedTo.forEach((assignedAccount) {
      assignedUsers.add(assignedAccount.id);
    });

    task.teams.forEach((team) {
      teams.add(team.id);
    });

    _currentEditTask = {
      'title': task.title,
      'status': task.status,
      'priority': task.priority,
      'due_date': task.dueDate,
      'account': null,
      'contacts': contacts,
      'teams': teams,
      'assigned_to': assignedUsers
    };
  }

  List<Task> get tasks {
    return _tasks;
  }

  List get status {
    return _status;
  }

  List get priorities {
    return _priorities;
  }

  Map get currentEditTask {
    return _currentEditTask;
  }

  String get currentEditTaskId {
    return _currentEditTaskId;
  }

  set currentEditTaskId(id) {
    _currentEditTask = id;
  }

  Task get currentTask {
    return _currentTask;
  }

  set currentTask(task) {
    _currentTask = task;
  }

  int get currentTaskIndex {
    return _currentTaskIndex;
  }

  set currentTaskIndex(index) {
    _currentTaskIndex = index;
  }

  List<Account> get accounts {
    return _accounts;
  }
}

final taskBloc = TaskBloc();
