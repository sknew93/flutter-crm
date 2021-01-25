import 'dart:convert';

import 'package:bottle_crm/model/account.dart';
import 'package:bottle_crm/model/opportunities.dart';
import 'package:bottle_crm/services/crm_services.dart';
import 'package:intl/intl.dart';

class OpportunityBloc {
  List<Opportunity> _opportunities = [];
  int _currentOpportunityIndex;
  Opportunity _currentOpportunity;
  String _currentEditOpportunityId;

  Map _currentEditOpportunity = {
    'name': "",
    'account': "",
    'stage': "",
    'currency': "",
    'amount': "",
    'lead_source': "",
    'probability': 0,
    'contacts': [],
    'due_date': "",
    'description': "",
    'assigned_to': [],
    'tags': <String>[],
    'teams': [],
  };

  List _tags = [];
  List<String> _accountsObjforDropDown = [];
  List _stageObjforDropDown = [];
  List _leadSourceObjforDropDown = [];
  List<String> _currencyObjforDropDown = [];
  List _currencyList = [];
  List _accountsList = [];

  Future fetchOpportunities({filtersData}) async {
    Map _copyFiltersData =
        filtersData != null ? new Map.from(filtersData) : null;
    if (filtersData != null) {
      _copyFiltersData['tags'] = _copyFiltersData['tags'].length > 0
          ? jsonEncode(_copyFiltersData['tags'])
          : "";
    }

    await CrmService()
        .getOpportunities(queryParams: _copyFiltersData)
        .then((response) {
      var res = jsonDecode(response.body);

      _opportunities.clear();

      res['opportunities'].forEach((_opportunity) {
        Opportunity oppor = Opportunity.fromJson(_opportunity);
        _opportunities.add(oppor);
      });

      _tags = res['tags'];

      res['accounts_list'].forEach((_account) {
        Account acc = Account.fromJson(_account);
        _accountsObjforDropDown.add(acc.name);
        _accountsList.add([acc.id, acc.name]);
      });

      // res['stage'].map((stage) {
      //   _stageObjforDropDown.add(stage);
      // });
      _stageObjforDropDown = res['stage'];

      // res['lead_source'].map((leadSource) {
      //   _leadSourceObjforDropDown.add(leadSource);
      // });

      _leadSourceObjforDropDown = res['lead_source'];

      res['currency'].forEach((curr) {
        _currencyObjforDropDown.add(curr[1]);
      });

      _currencyList = res['currency'];
      // _currencyObjforDropDown = res['currency'];

      // print(res);
    }).catchError((onError) {
      print("fetchOpportunities Error >> $onError");
    });
  }

  Future deleteOpportunity(Opportunity opportunity) async {
    Map result;
    await CrmService()
        .deletefromModule('opportunities', opportunity.id)
        .then((response) async {
      var res = (json.decode(response.body));
      await fetchOpportunities();
      result = res;
    }).catchError((onError) {
      print("deleteOpportunity Error >> $onError");
      result = {"status": "error", "message": "Something went wrong."};
    });
    return result;
  }

  Future createOpportunity([file]) async {
    Map result;
    Map _copyOfCurrentEditOpportunity = new Map.from(_currentEditOpportunity);
    _accountsList.forEach((element) {
      if (element[1] == _copyOfCurrentEditOpportunity['account']) {
        _copyOfCurrentEditOpportunity['account'] = element[0].toString();
      }
    });
    _currencyList.forEach((element) {
      if (element[1] == _copyOfCurrentEditOpportunity['currency']) {
        _copyOfCurrentEditOpportunity['currency'] = element[0];
      }
    });
    _copyOfCurrentEditOpportunity['probability'] =
        _copyOfCurrentEditOpportunity['probability'].toString();

    _copyOfCurrentEditOpportunity['teams'] =
        (_copyOfCurrentEditOpportunity['teams'].map((e) => e.toString()))
            .toList()
            .toString();
    _copyOfCurrentEditOpportunity['assigned_to'] =
        (_copyOfCurrentEditOpportunity['assigned_to'].map((e) => e.toString()))
            .toList()
            .toString();
    _copyOfCurrentEditOpportunity['contacts'] =
        (_copyOfCurrentEditOpportunity['contacts'].map((e) => e.toString()))
            .toList()
            .toString();

    _copyOfCurrentEditOpportunity['closed_on'] = DateFormat("yyyy-MM-dd")
        .format(DateFormat("dd-MM-yyyy")
            .parse(_copyOfCurrentEditOpportunity['closed_on']));
    _copyOfCurrentEditOpportunity['tags'] =
        jsonEncode(_copyOfCurrentEditOpportunity['tags']);
    print(_copyOfCurrentEditOpportunity);
    await CrmService()
        .createOpportunity(_copyOfCurrentEditOpportunity, file)
        .then((response) async {
      var res = json.decode(response);
      if (res["error"] == false) {
        await fetchOpportunities();
      }
      result = res;
    }).catchError((onError) {
      print("editOpportunity Error >> $onError");
      result = {"status": "error", "message": "Something went wrong"};
    });
    return result;
  }

  cancelCurrentEditOpportunity() {
    opportunityBloc.currentEditOpportunityId = null;
    _currentEditOpportunity = {
      'name': "",
      'account': "",
      'stage': "",
      'currency': "",
      'amount': "",
      'lead_source': "",
      'probability': 0,
      'contacts': [],
      'due_date': "",
      'closed_on': "",
      'description': "",
      'assigned_to': [],
      'tags': <String>[],
      'teams': [],
      "opportunity_attachment": []
    };
  }

  updateCurrentEditOpportunity(Opportunity editOpportunity) {
    List _contacts = [];
    List _teams = [];
    List _assignedUsers = [];
    List<String> _tags = [];

    _currentEditOpportunityId = editOpportunity.id.toString();
    editOpportunity.contacts.forEach((contact) {
      _contacts.add(contact.id);
    });
    editOpportunity.assignedTo.forEach((assignedAccount) {
      _assignedUsers.add(assignedAccount.id);
    });
    editOpportunity.teams.forEach((team) {
      _teams.add(team.id);
    });
    editOpportunity.tags.forEach((tag) {
      _tags.add(tag['name']);
    });

    _currentEditOpportunity = {
      'name': editOpportunity.name,
      'account': editOpportunity.account.name,
      'stage': editOpportunity.stage,
      'currency': editOpportunity.currency,
      'amount': editOpportunity.amount,
      'lead_source': editOpportunity.leadSource,
      'probability': editOpportunity.probability,
      'contacts': _contacts,
      'closed_on': editOpportunity.closedOn,
      'description': editOpportunity.description,
      'assigned_to': _assignedUsers,
      'tags': _tags,
      'teams': _teams,
      'opportunity_attachment': (editOpportunity.opportunityAttachment.isEmpty)
          ? []
          : editOpportunity.opportunityAttachment[0]['file_path']
    };
  }

  Future editOpportunity([file]) async {
    Map result;

    Map _copyOfCurrentEditOpportunity = new Map.from(_currentEditOpportunity);
    _accountsList.forEach((element) {
      if (element[1] == _copyOfCurrentEditOpportunity['account']) {
        _copyOfCurrentEditOpportunity['account'] = element[0].toString();
      }
    });
    _currencyList.forEach((element) {
      if (element[1] == _copyOfCurrentEditOpportunity['currency']) {
        _copyOfCurrentEditOpportunity['currency'] = element[0];
      }
    });
    _copyOfCurrentEditOpportunity['probability'] =
        _copyOfCurrentEditOpportunity['probability'].toString();

    _copyOfCurrentEditOpportunity['teams'] =
        (_copyOfCurrentEditOpportunity['teams'].map((e) => e.toString()))
            .toList()
            .toString();
    _copyOfCurrentEditOpportunity['assigned_to'] =
        (_copyOfCurrentEditOpportunity['assigned_to'].map((e) => e.toString()))
            .toList()
            .toString();
    _copyOfCurrentEditOpportunity['contacts'] =
        (_copyOfCurrentEditOpportunity['contacts'].map((e) => e.toString()))
            .toList()
            .toString();

    _copyOfCurrentEditOpportunity['closed_on'] = DateFormat("yyyy-MM-dd")
        .format(DateFormat("dd-MM-yyyy")
            .parse(_copyOfCurrentEditOpportunity['closed_on']));
    _copyOfCurrentEditOpportunity['tags'] =
        jsonEncode(_copyOfCurrentEditOpportunity['tags']);

    await CrmService()
        .editOpportunity(
            _copyOfCurrentEditOpportunity, _currentEditOpportunityId, file)
        .then((response) async {
      var res = json.decode(response);
      if (res["error"] == false) {
        await fetchOpportunities();
      }
      result = res;
    }).catchError((onError) {
      print("editOpportunity Error >> $onError");
      result = {"status": "error", "message": "Something went wrong"};
    });
    return result;
  }

  List<Opportunity> get opportunities {
    return _opportunities;
  }

  int get currentOpportunityIndex {
    return _currentOpportunityIndex;
  }

  set currentOpportunityIndex(index) {
    _currentOpportunityIndex = index;
  }

  Opportunity get currentOpportunity {
    return _currentOpportunity;
  }

  set currentOpportunity(currOpp) {
    _currentOpportunity = currOpp;
  }

  String get currentEditOpportunityId {
    return _currentEditOpportunityId;
  }

  set currentEditOpportunityId(id) {
    _currentEditOpportunityId = id;
  }

  Map get currentEditOpportunity {
    return _currentEditOpportunity;
  }

  set currentEditOpportunity(currEditOpp) {
    _currentEditOpportunity = currEditOpp;
  }

  List get tags {
    return _tags;
  }

  List<String> get accountsObjforDropDown {
    return _accountsObjforDropDown;
  }

  List get stageObjforDropDown {
    return _stageObjforDropDown;
  }

  List get leadSourceObjforDropDown {
    return _leadSourceObjforDropDown;
  }

  List get currencyObjforDropDown {
    return _currencyObjforDropDown;
  }
}

final opportunityBloc = OpportunityBloc();
