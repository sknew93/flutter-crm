import 'package:bottle_crm/ui/screens/accounts/account_create.dart';
import 'package:bottle_crm/ui/screens/accounts/account_details.dart';
import 'package:bottle_crm/ui/screens/accounts/accounts_list.dart';
import 'package:bottle_crm/ui/screens/authentication/change_password.dart';
import 'package:bottle_crm/ui/screens/authentication/forgot_password.dart';
import 'package:bottle_crm/ui/screens/authentication/login.dart';
import 'package:bottle_crm/ui/screens/authentication/profile_details.dart';
import 'package:bottle_crm/ui/screens/authentication/register.dart';
import 'package:bottle_crm/ui/screens/cases/cases_index.dart';
import 'package:bottle_crm/ui/screens/contacts/contact_create.dart';
import 'package:bottle_crm/ui/screens/contacts/contact_details.dart';
import 'package:bottle_crm/ui/screens/contacts/contacts_list.dart';
import 'package:bottle_crm/ui/screens/dashboard/dashboard.dart';
import 'package:bottle_crm/ui/screens/documents/document_create.dart';
import 'package:bottle_crm/ui/screens/documents/document_details.dart';
import 'package:bottle_crm/ui/screens/documents/documents_list.dart';
import 'package:bottle_crm/ui/screens/events/events_list.dart';
import 'package:bottle_crm/ui/screens/invoices/invoices_index.dart';
import 'package:bottle_crm/ui/screens/leads/lead_create.dart';
import 'package:bottle_crm/ui/screens/leads/lead_details.dart';
import 'package:bottle_crm/ui/screens/leads/leads_list.dart';
import 'package:bottle_crm/ui/screens/marketing/campaigns/campaigns_index.dart';
import 'package:bottle_crm/ui/screens/marketing/contacts/contacts_index.dart';
import 'package:bottle_crm/ui/screens/marketing/dashboard/dashboard_index.dart';
import 'package:bottle_crm/ui/screens/marketing/email_templates/email_index.dart';
import 'package:bottle_crm/ui/screens/more_options_screen.dart';
import 'package:bottle_crm/ui/screens/opportunities/opportunity_create.dart';
import 'package:bottle_crm/ui/screens/opportunities/opportunity_details.dart';
import 'package:bottle_crm/ui/screens/splash_screen.dart';
import 'package:bottle_crm/ui/screens/tasks/tasks_index.dart';
import 'package:bottle_crm/ui/screens/teams/team_create.dart';
import 'package:bottle_crm/ui/screens/teams/teams_list.dart';
import 'package:bottle_crm/ui/screens/users/user_create.dart';
import 'package:bottle_crm/ui/screens/users/user_details.dart';
import 'package:bottle_crm/ui/screens/users/users_list.dart';
import 'package:flutter/material.dart';

import 'ui/screens/authentication/sub_domain.dart';
import 'ui/screens/opportunities/opportunities_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'bottlecrm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: Color.fromRGBO(236, 238, 244, 1),
          buttonColor: Color.fromRGBO(223, 83, 42, 1),
          primarySwatch: Colors.blue,
          // primaryColor: Color.fromRGBO(29, 132, 150, 1),
          primaryColor: Colors.white,
          secondaryHeaderColor: Color.fromRGBO(5, 24, 62, 1),
          dividerColor: Color.fromRGBO(232, 243, 245, 1)),
      home: SplashScreen(),
      routes: {
        '/sub_domain': (BuildContext context) => SubDomain(),
        '/user_register': (BuildContext context) => UserRegister(),
        '/user_login': (BuildContext context) => UserLogin(),
        '/forgot_password': (BuildContext context) => ForgotPassword(),
        '/dashboard': (BuildContext context) => Dashboard(),
        '/account_list': (BuildContext context) => AccountsList(),
        '/account_details': (BuildContext context) => AccountDetails(),
        '/create_account': (BuildContext context) => CreateAccount(),
        '/cases': (BuildContext context) => CasesScreen(),
        '/contacts': (BuildContext context) => ContactsList(),
        '/create_contact': (BuildContext context) => CreateContact(),
        '/contact_details': (BuildContext context) => ContactDetails(),
        '/documents': (BuildContext context) => DocumentsList(),
        '/create_document': (BuildContext context) => CreateDocument(),
        '/document_details': (BuildContext context) => DocumentDetails(),
        '/events': (BuildContext context) => EventsList(),
        '/invoices': (BuildContext context) => InvoicesScreen(),
        '/leads_list': (BuildContext context) => LeadsList(),
        '/lead_details': (BuildContext context) => LeadDetails(),
        '/create_lead': (BuildContext context) => CreateLead(),
        '/opportunities': (BuildContext context) => OpportunitiesList(),
        '/opportunity_details': (BuildContext context) => OpportunityDetails(),
        '/create_opportunity': (BuildContext context) => CreateOpportunity(),
        '/tasks': (BuildContext context) => TasksScreen(),
        '/teams': (BuildContext context) => TeamsList(),
        '/create_team': (BuildContext context) => CreateTeam(),
        '/change_password': (BuildContext context) => ChangePassword(),
        '/marketing_dashboard': (BuildContext context) => MarketingDashboard(),
        '/marketing_contacts': (BuildContext context) =>
            MarketingContactsScreen(),
        '/email_templates': (BuildContext context) => EmailTemplatesScreen(),
        '/marketing_campaigns': (BuildContext context) =>
            MarketingCampaignsScreen(),
        '/profile_details': (BuildContext context) => ProfileDetails(),
        '/users_list': (BuildContext context) => UsersList(),
        '/create_user': (BuildContext context) => CreateUser(),
        '/user_details': (BuildContext context) => UserDetails(),
        '/more_options': (BuildContext context) => MoreOptions()
      },
    );
  }
}
