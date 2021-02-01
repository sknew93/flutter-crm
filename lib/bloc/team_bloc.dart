import 'dart:convert';

import 'package:bottle_crm/model/profile.dart';
import 'package:bottle_crm/model/team.dart';
import 'package:bottle_crm/services/crm_services.dart';

class TeamBloc {
  List<Team> _teams = [];
  List<Profile> _users = [];

  Future fetchTeams() async {
    await CrmService().getTeams().then((response) {
      var res = json.decode(response.body);
      print("Teams Fetched");
      print(res.runtimeType);
      print(res);

      res['teams'].forEach((_team) {
        Team team = Team.fromJson(_team);
        _teams.add(team);
      });
      res['users'].forEach((_user) {
        Profile user = Profile.fromJson(_user);
        _users.add(user);
      });
    });
  }

  List<Team> get teams {
    return _teams;
  }
}

final teamBloc = TeamBloc();
