import 'dart:convert';
import 'package:bottle_crm/bloc/lead_bloc.dart';
import 'package:bottle_crm/model/contact.dart';
import 'package:bottle_crm/model/team.dart';
import 'package:bottle_crm/services/crm_services.dart';

import 'dashboard_bloc.dart';

class ContactBloc {
  List<Contact> _contacts = [];
  List _contactsObjForDropdown = [];
  List<Team> _teams = [];
  List _teamsObjForDropdown = [];
  String _currentEditContactId;

  Contact _currentContact;
  int _currentContactIndex;

  List countriesList = leadBloc.countriesList;

  Map _currentEditContact = {
    'first_name': "",
    'last_name': "",
    'email': "",
    'phone': "",
    'address': {
      "address_line": "",
      "street": "",
      "city": "",
      "state": "",
      "postcode": "",
      "country": ""
    },
    'description': "",
    'assigned_to': [],
    'teams': [],
  };

  Future fetchContacts({filtersData}) async {
    Map _copyFiltersData =
        filtersData != null ? new Map.from(filtersData) : null;
    if (filtersData != null) {
      _copyFiltersData['assigned_to'] =
          _copyFiltersData['assigned_to'].length > 0
              ? jsonEncode(_copyFiltersData['assigned_to'])
              : "";
    }
    await CrmService()
        .getContacts(queryParams: _copyFiltersData)
        .then((response) {
      var res = (json.decode(response.body));
      _contacts.clear();
      _contactsObjForDropdown.clear();
      _teams.clear();
      res['contact_obj_list'].forEach((_contact) {
        Contact contact = Contact.fromJson(_contact);
        _contacts.add(contact);
      });

      _contacts.forEach((_contact) {
        Map contact = {};
        contact['id'] = _contact.id;
        contact['name'] = _contact.firstName + ' ' + _contact.lastName;
        _contactsObjForDropdown.add(contact);
      });

      res['teams'].forEach((_team) {
        Team team = Team.fromJson(_team);
        _teams.add(team);
      });

      _teams.forEach((_team) {
        Map team = {};
        team['id'] = _team.id;
        team['name'] = _team.name;
        _teamsObjForDropdown.add(team);
      });
    }).catchError((onError) {
      print("fetchContacts Error>> $onError");
    });
  }

  createContact() async {
    Map result;

    leadBloc.countriesList.forEach((country) {
      if (country[1] == _currentEditContact['address']['country']) {
        _currentEditContact['address']['country'] = country[0];
      }
    });

    Map _copyOfCurrentEditContact = {
      'first_name': _currentEditContact['first_name'],
      'last_name': _currentEditContact['last_name'],
      'phone': _currentEditContact['phone'],
      'email': _currentEditContact['email'],
      'teams': _currentEditContact['teams'],
      'assigned_to': _currentEditContact['assigned_to'],
      'address_line': (_currentEditContact['address'])['address_line'],
      'street': _currentEditContact['address']['street'],
      'city': _currentEditContact['address']['city'],
      'state': _currentEditContact['address']['state'],
      'postcode': _currentEditContact['address']['postcode'],
      'country': _currentEditContact['address']['country'],
      'description': _currentEditContact['description'],
      // 'contact_attachment' : '',
    };

    _copyOfCurrentEditContact['teams'] = (_copyOfCurrentEditContact['teams']
        .map((team) => team.toString())).toList().toString();
    _copyOfCurrentEditContact['assigned_to'] =
        (_copyOfCurrentEditContact['assigned_to']
            .map((team) => team.toString())).toList().toString();

    await CrmService()
        .createContact(_copyOfCurrentEditContact)
        .then((response) async {
      var res = json.decode(response.body);

      if (res['error'] == false) {
        await fetchContacts();
        dashboardBloc.fetchDashboardDetails();
      }
      result = res;
    }).catchError((onError) {
      print('createContact Error >> $onError');
      result = {"status": "error", "message": "Something went wrong"};
    });
    return result;
  }

  editContact() async {
    Map _result;
    Map copyOfCurrentEditContact = {
      'first_name': _currentEditContact['first_name'],
      'last_name': _currentEditContact['last_name'],
      'phone': _currentEditContact['phone'],
      'email': _currentEditContact['email'],
      'teams': _currentEditContact['teams'],
      'assigned_to': _currentEditContact['assigned_to'],
      'address_line': (_currentEditContact['address'])['address_line'],
      'street': _currentEditContact['address']['street'],
      'city': _currentEditContact['address']['city'],
      'state': _currentEditContact['address']['state'],
      'postcode': _currentEditContact['address']['postcode'],
      'country': _currentEditContact['address']['country'],
      'description': _currentEditContact['description'],
      // 'contact_attachment' : '',
    };
    countriesList.forEach((country) {
      if (country[1] == copyOfCurrentEditContact['country']) {
        copyOfCurrentEditContact['country'] = country[0];
      }
    });

    copyOfCurrentEditContact['teams'] =
        jsonEncode(copyOfCurrentEditContact['teams']);
    copyOfCurrentEditContact['assigned_to'] =
        jsonEncode(copyOfCurrentEditContact['assigned_to']);
    await CrmService()
        .editContact(copyOfCurrentEditContact, currentEditContactId)
        .then((response) async {
      var res = json.decode(response.body);

      if (res['error'] == false) {
        await fetchContacts();
        dashboardBloc.fetchDashboardDetails();
      }
      _result = res;
    }).catchError((onError) {
      print('editContact Error >> $onError');
      _result = {"status": "error", "message": "Something went wrong."};
    });
    return _result;
  }

  Future deleteContact(Contact contact) async {
    Map result;
    await CrmService().deleteContact(contact.id).then((response) async {
      var res = (json.decode(response.body));
      await fetchContacts();
      dashboardBloc.fetchDashboardDetails();
      result = res;
    }).catchError((onError) {
      print("deleteContact Error >> $onError");
      result = {"status": "error", "message": "Something went wrong."};
    });
    return result;
  }

  cancelCurrentEditContact() {
    _currentEditContactId = null;
    _currentEditContact = {
      'first_name': "",
      'last_name': "",
      'email': "",
      'phone': "",
      'address': {
        "address_line": "",
        "street": "",
        "city": "",
        "state": "",
        "postcode": "",
        "country": ""
      },
      'description': "",
      'assigned_to': [],
      'teams': [],
    };
  }

  updateCurrentEditContact(Contact editContact) {
    _currentEditContactId = editContact.id.toString();
    List teams = [];
    List assignedUsers = [];

    editContact.teams.forEach((team) {
      teams.add(team.id);
    });

    editContact.assignedTo.forEach((user) {
      assignedUsers.add(user.id);
    });

    _currentEditContact['id'] = editContact.id;
    _currentEditContact['first_name'] = editContact.firstName;
    _currentEditContact['last_name'] = editContact.lastName;
    _currentEditContact['email'] = editContact.email;
    _currentEditContact['phone'] = editContact.phone;
    _currentEditContact['description'] = editContact.description;
    _currentEditContact['created_by'] = editContact.createdBy;
    _currentEditContact['created_on'] = editContact.createdOn;
    _currentEditContact['is_active'] = editContact.isActive;
    _currentEditContact['company'] = editContact.company;
    _currentEditContact['address'] = editContact.address;
    countriesList.forEach((country) {
      if (country[0] == editContact.address['country']) {
        _currentEditContact['address']['country'] = country[1];
      }
    });
    _currentEditContact['teams'] = teams;
    _currentEditContact['assigned_to'] = assignedUsers;
  }

  Map get currentEditContact {
    return _currentEditContact;
  }

  set currentEditContact(currentEditContact) {
    _currentEditContact = currentEditContact;
  }

  List<Contact> get contacts {
    return _contacts;
  }

  Contact get currentContact {
    return _currentContact;
  }

  set currentContact(contact) {
    _currentContact = contact;
  }

  int get currentContactIndex {
    return _currentContactIndex;
  }

  set currentContactIndex(currentContactIndex) {
    _currentContactIndex = currentContactIndex;
  }

  List<Team> get teams {
    return _teams;
  }

  List get contactsObjForDropdown {
    return _contactsObjForDropdown;
  }

  String get currentEditContactId {
    return _currentEditContactId;
  }

  List get teamsObjForDropdown {
    return _teamsObjForDropdown;
  }
}

final contactBloc = ContactBloc();
