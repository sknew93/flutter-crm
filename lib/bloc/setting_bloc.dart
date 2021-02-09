import 'dart:convert';

import 'package:bottle_crm/model/contact.dart';
import 'package:bottle_crm/model/domain.dart';
import 'package:bottle_crm/model/email.dart';
import 'package:bottle_crm/model/profile.dart';
import 'package:bottle_crm/services/crm_services.dart';
import 'package:bottle_crm/ui/screens/authentication/sub_domain.dart';

class SettingsBloc {
  Map _currentEditSetting = {
    'name': "",
    'last_name': "",
    'email': "",
    'domain': ""
  };
  String _currentEditSettingId;

//////////////// CONTACTS /////////////////////////
  List<List> _users = [];
  List<String> _usersObjForDropDown = [];
  List<Contact> _settingsContacts = [];
  String _currentSettingsTab = "Contacts";

  Future fetchSettingsContacts({filtersData}) async {
    Map _copyFiltersData =
        filtersData != null ? new Map.from(filtersData) : null;
    if (_copyFiltersData != null) {
      _users.forEach((e) {
        if (_copyFiltersData['created_by'] != null) {
          if (e[1] == _copyFiltersData['created_by']) {
            _copyFiltersData['created_by'] = e[0].toString();
          }
        }
      });
    }
    _settingsContacts.clear();
    _usersObjForDropDown.clear();
    _users.clear();
    await CrmService()
        .getSettingsContacts(queryParams: _copyFiltersData)
        .then((response) {
      var res = json.decode(response.body);

      res['contacts'].forEach((_contact) {
        Contact contact = Contact.fromJson(_contact);
        _settingsContacts.add(contact);
      });
      res['users'].forEach((_user) {
        Profile user = Profile.fromJson(_user);
        _users.add([user.id, user.userName]);
        _usersObjForDropDown.add(user.userName);
      });
    });
  }

  Future deleteSettingsContacts(Contact contact) async {
    Map result;
    await CrmService()
        .deleteSettingsContacts(contact.id)
        .then((response) async {
      var res = (json.decode(response.body));
      await fetchSettingsContacts();
      result = res;
    }).catchError((onError) {
      print("deleteSettingsContacts Error >> $onError");
      result = {"status": "error", "message": "Something went wrong."};
    });
    return result;
  }

  List<Contact> get settingsContacts {
    return _settingsContacts;
  }

  List<List> get users {
    return _users;
  }

  List<String> get userObjForDropDown {
    return _usersObjForDropDown;
  }

  String get currentSettingsTab {
    return _currentSettingsTab;
  }

  set currentSettingsTab(tab) {
    _currentSettingsTab = tab;
  }

  //////////////// BLOCKED DOMAINS /////////////////////////

  List<Domain> _blockedDomains = [];

  Future fetchBlockedDomains({filtersData}) async {
    Map _copyFiltersData =
        filtersData != null ? new Map.from(filtersData) : null;
    _blockedDomains.clear();

    await CrmService()
        .getBlockedDomains(queryParams: _copyFiltersData)
        .then((response) {
      var res = json.decode(response.body);

      res['blocked_domains'].forEach((_domain) {
        Domain domain = Domain.fromJson(_domain);
        _blockedDomains.add(domain);
      });
    });
  }

  Future deleteBlockedDomains(Domain domain) async {
    Map result;
    await CrmService().deleteBlockedDomains(domain.id).then((response) async {
      var res = (json.decode(response.body));
      await fetchBlockedDomains();
      result = res;
    }).catchError((onError) {
      print("deleteBlockedDomains Error >> $onError");
      result = {"status": "error", "message": "Something went wrong."};
    });
    return result;
  }

  List<Domain> get blockedDomains {
    return _blockedDomains;
  }

  //////////////// BLOCKED EMAILS /////////////////////////

  List<Email> _blockedEmails = [];

  Future fetchBlockedEmails({filtersData}) async {
    Map _copyFiltersData =
        filtersData != null ? new Map.from(filtersData) : null;
    _blockedEmails.clear();

    await CrmService()
        .getBlockedEmails(queryParams: _copyFiltersData)
        .then((response) {
      var res = json.decode(response.body);

      res['blocked_emails'].forEach((_email) {
        Email email = Email.fromJson(_email);
        _blockedEmails.add(email);
      });
    });
  }

  Future deleteBlockedEmails(Email email) async {
    Map result;
    await CrmService().deleteBlockedEmails(email.id).then((response) async {
      var res = (json.decode(response.body));
      await fetchBlockedEmails();
      result = res;
    }).catchError((onError) {
      print("deleteBlockedEmails Error >> $onError");
      result = {"status": "error", "message": "Something went wrong."};
    });
    return result;
  }

  List<Email> get blockedEmails {
    return _blockedEmails;
  }

  Future createSetting() async {
    Map _result;
    Map _copyOfCurrentEditSetting = Map.from(_currentEditSetting);
    await CrmService()
        .createSetting(_copyOfCurrentEditSetting)
        .then((response) async {
      var res = json.decode(response.body);
      if (res['error'] == false) {
        await fetchBlockedDomains();
        await fetchBlockedEmails();
        await fetchSettingsContacts();
      }
      _result = res;
    }).catchError((onError) {
      print("createUser Error >> $onError");
      _result = {"status": "error", "message": "Something went wrong."};
    });
    return _result;
  }

  updateCurrentEditSetting(setting) {
    _currentEditSettingId = setting.id.toString();

    if (_currentSettingsTab == "Contacts") {
      _currentEditSetting['name'] = setting.name;
      _currentEditSetting['last_name'] = setting.lastName;
      _currentEditSetting['email'] = setting.email;
    } else if (_currentSettingsTab == "Blocked Domains") {
      _currentEditSetting['domain'] = setting.domain;
    } else {
      _currentEditSetting['email'] = setting.email;
    }
  }

  Future editSetting() async {
    Map _result;
    Map _copyOfCurrentEditSetting = Map.from(_currentEditSetting);
    await CrmService()
        .editSetting(_copyOfCurrentEditSetting, currentEditSettingId)
        .then((response) async {
      var res = json.decode(response.body);
      if (res['error'] == false) {
        await fetchBlockedDomains();
        await fetchBlockedEmails();
        await fetchSettingsContacts();
      }
      _result = res;
    }).catchError((onError) {
      print("createSetting Error >> $onError");
      _result = {"status": "error", "message": "Something went wrong."};
    });
    return _result;
  }

  Map get currentEditSetting {
    return _currentEditSetting;
  }

  String get currentEditSettingId {
    return _currentEditSettingId;
  }
}

final settingsBloc = SettingsBloc();
