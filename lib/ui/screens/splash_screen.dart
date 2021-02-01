import 'dart:async';

import 'package:bottle_crm/bloc/account_bloc.dart';
import 'package:bottle_crm/bloc/auth_bloc.dart';
import 'package:bottle_crm/bloc/contact_bloc.dart';
import 'package:bottle_crm/bloc/dashboard_bloc.dart';
import 'package:bottle_crm/bloc/lead_bloc.dart';
import 'package:bottle_crm/bloc/opportunity_bloc.dart';
import 'package:bottle_crm/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flushbar/flushbar.dart';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen();
  @override
  State createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(Duration(seconds: 3), () => checkInternet());
    super.initState();

    _downloadPackageInit();
  }

  _downloadPackageInit() async {
    WidgetsFlutterBinding.ensureInitialized();
    await FlutterDownloader.initialize(
        debug: false // optional: set false to disable printing logs to console
        );
  }

  checkInternet() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      if (preferences.getString('authToken') != null &&
          preferences.getString('authToken') != "") {
        await authBloc.getProfileDetails();
        await dashboardBloc.fetchDashboardDetails();
        await contactBloc.fetchContacts();
        await accountBloc.fetchAccounts();
        await leadBloc.fetchLeads();
        // await teamBloc.fetchTeams();
        await opportunityBloc.fetchOpportunities();
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/sub_domain');
      }
    } else {
      showNoInternet(context, 'No internet connection!');
    }
  }

  void showNoInternet(BuildContext context, String errorContent) {
    Flushbar(
      backgroundColor: Colors.red,
      messageText: Text(errorContent,
          style: TextStyle(fontWeight: FontWeight.w400, color: Colors.white)),
      isDismissible: false,
      mainButton: TextButton(
        child: Text(
          'TRY AGAIN',
          style: TextStyle(
              color: Theme.of(context).accentColor,
              fontWeight: FontWeight.w500),
        ),
        onPressed: () {
          Navigator.of(context).pop(true);
          checkInternet();
        },
      ),
      duration: Duration(minutes: 1),
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(bottom: 30.0),
              child: SvgPicture.asset(
                'assets/images/logo.svg',
                width: screenWidth * 0.5,
              )),
          CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(
                  Theme.of(context).secondaryHeaderColor)),
        ],
      ),
    );
  }
}
