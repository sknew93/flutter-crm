import 'package:bottle_crm/model/document.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import 'network_services.dart';

class CrmService {
  NetworkService networkService = NetworkService();
  final baseUrl = 'https://bottlecrm.com/api/';
  Map _headers = {"Authorization": "", "company": ""};

  updateHeaders() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    _headers['Authorization'] = preferences.getString("authToken");
    _headers['company'] = preferences.getString("subdomain");
  }

  getFormatedHeaders(headers) {
    return new Map<String, String>.from(headers);
  }

  Future<Response> userRegister(data) async {
    return await networkService.post(baseUrl + 'auth/register/', body: data);
  }

  Future<Response> userLogin(headers, body) async {
    return await networkService.post(baseUrl + 'auth/login/',
        body: body, headers: getFormatedHeaders(headers));
  }

  Future<Response> validateSubdomain(data) async {
    return await networkService.post(baseUrl + 'auth/validate-subdomain/',
        body: data);
  }

  Future<Response> forgotPassword(data) async {
    return await networkService.post(baseUrl + 'auth/forgot-password/',
        body: data);
  }

  Future<Response> getUserProfile() async {
    await updateHeaders();
    return await networkService.get(baseUrl + 'profile/',
        headers: getFormatedHeaders(_headers));
  }

  Future<Response> changePassword(data) async {
    await updateHeaders();
    return await networkService.post(baseUrl + 'profile/change-password/',
        headers: getFormatedHeaders(_headers), body: data);
  }

  Future<Response> getDashboardDetails() async {
    await updateHeaders();
    return await networkService.get(baseUrl + 'dashboard/',
        headers: getFormatedHeaders(_headers));
  }
  ///////////////////// ACCONUTS-SERVICES ////////////////////////////

  Future<Response> getAccounts({queryParams}) async {
    await updateHeaders();
    String url;
    if (queryParams != null) {
      queryParams.removeWhere((key, value) => value == "");
      String queryString =
          Uri(queryParameters: getFormatedHeaders(queryParams)).query;
      url = baseUrl + 'accounts/' + '?' + queryString;
    } else {
      url = baseUrl + 'accounts/';
    }
    return await networkService.get(url, headers: getFormatedHeaders(_headers));
  }

  Future<Response> deleteAccount(id) async {
    await updateHeaders();
    return await networkService.delete(baseUrl + 'accounts/$id/',
        headers: getFormatedHeaders(_headers));
  }

  Future<Response> createAccount(contact) async {
    await updateHeaders();
    return await networkService.post(baseUrl + 'accounts/',
        headers: getFormatedHeaders(_headers), body: contact);
  }

  Future<Response> editAccount(data, id) async {
    await updateHeaders();
    return await networkService.put(baseUrl + 'accounts/$id/',
        headers: getFormatedHeaders(_headers), body: data);
  }

  Future<Response> getToEditAccount(id) async {
    await updateHeaders();
    return await networkService.get(baseUrl + 'accounts/$id/',
        headers: getFormatedHeaders(_headers));
  }

  ///////////////////// CONTACTS-SERVICES ///////////////////////////////

  Future<Response> getContacts({queryParams}) async {
    await updateHeaders();
    String url;
    if (queryParams != null) {
      queryParams.removeWhere((key, value) => value == "");
      String queryString =
          Uri(queryParameters: getFormatedHeaders(queryParams)).query;
      url = baseUrl + 'contacts/' + '?' + queryString;
    } else {
      url = baseUrl + 'contacts/';
    }
    return await networkService.get(url, headers: getFormatedHeaders(_headers));
  }

  Future<Response> createContact(data) async {
    await updateHeaders();
    return await networkService.post(baseUrl + 'contacts/',
        headers: getFormatedHeaders(_headers), body: data);
  }

  Future<Response> editContact(data, id) async {
    await updateHeaders();
    return await networkService.put(baseUrl + 'contacts/$id/',
        headers: getFormatedHeaders(_headers), body: data);
  }

  Future<Response> deleteContact(id) async {
    await updateHeaders();
    return await networkService.delete(baseUrl + 'contacts/$id/',
        headers: getFormatedHeaders(_headers));
  }

  ///////////////////// LEADS-SERVICES ///////////////////////////////

  Future<Response> getLeads({queryParams}) async {
    await updateHeaders();
    String url;
    if (queryParams != null) {
      queryParams.removeWhere((key, value) => value == "");
      String queryString = Uri(
        queryParameters: getFormatedHeaders(queryParams),
      ).query;
      url = baseUrl + 'leads/' + '?' + queryString;
    } else {
      url = baseUrl + 'leads/';
    }
    return await networkService.get(url, headers: getFormatedHeaders(_headers));
  }

  Future<Response> getLeadToUpdate(leadId) async {
    await updateHeaders();
    return await networkService.get(baseUrl + 'leads/$leadId/',
        headers: getFormatedHeaders(_headers));
  }

  Future<Response> createLead(data) async {
    await updateHeaders();
    return await networkService.post(baseUrl + 'leads/',
        headers: getFormatedHeaders(_headers), body: data);
  }

  Future<Response> editLead(data, id) async {
    await updateHeaders();
    return await networkService.put(baseUrl + 'leads/$id/',
        headers: getFormatedHeaders(_headers), body: data);
  }

  Future<Response> deleteLead(id) async {
    await updateHeaders();
    return await networkService.delete(baseUrl + 'leads/$id/',
        headers: getFormatedHeaders(_headers));
  }

  ///////////////////// USERS-SERVICES ///////////////////////////////

  Future<Response> getUsers({Map queryParams}) async {
    await updateHeaders();
    String url;
    if (queryParams != null) {
      queryParams.removeWhere((key, value) => value == "");
      String queryString =
          Uri(queryParameters: getFormatedHeaders(queryParams)).query;
      url = baseUrl + 'users/' + '?' + queryString;
    } else {
      url = baseUrl + 'users/';
    }
    return await networkService.get(url, headers: getFormatedHeaders(_headers));
  }

  Future<Response> deleteUser(id) async {
    await updateHeaders();
    return await networkService.delete(baseUrl + 'users/$id/',
        headers: getFormatedHeaders(_headers));
  }

  Future<Response> createUser(user) async {
    await updateHeaders();
    return await networkService.post(baseUrl + 'users/',
        headers: getFormatedHeaders(_headers), body: user);
  }

  Future<Response> editUser(user, id) async {
    await updateHeaders();
    return await networkService.put(baseUrl + 'users/$id/',
        headers: getFormatedHeaders(_headers), body: user);
  }

  ///////////////////// DOCUMENTS-SERVICES ///////////////////////////////

  Future<Response> getDocuments({queryParams}) async {
    await updateHeaders();
    String url;
    if (queryParams != null) {
      queryParams.removeWhere((key, value) => value == "");
      String queryString = Uri(
        queryParameters: getFormatedHeaders(queryParams),
      ).query;
      url = baseUrl + 'documents/' + '?' + queryString;
    } else {
      url = baseUrl + 'documents/';
    }
    return await networkService.get(url, headers: getFormatedHeaders(_headers));
  }

  getFileSizes(files) {
    List _fileSizeList = [];
    files.forEach((Document file) async {
      http.Response r = await http.head(file.documentFile);
      if (r.headers['content-length'] != null) {
        String fileSize = r.headers['content-length'].toString();
        // int id = r.
        _fileSizeList.add([file.id, fileSize]);
      } else {
        _fileSizeList.add([file.id, "0"]);
      }
    });
    print(_fileSizeList);
    return _fileSizeList;
  }

  Future createDocument(document, PlatformFile file) async {
    await updateHeaders();
    var uri = Uri.parse(
      baseUrl + 'documents/',
    );
    var request = http.MultipartRequest(
      'POST',
      uri,
    )
      ..headers.addAll(getFormatedHeaders(_headers))
      ..fields.addAll({
        'title': document['title'],
        'teams': document['teams'],
        'shared_to': document['shared_to']
      })
      ..files
          .add(await http.MultipartFile.fromPath('document_file', file.path));
    final response = await request.send();
    return await response.stream.bytesToString();
  }

  Future editDocument(document, PlatformFile file, id) async {
    await updateHeaders();
    var uri = Uri.parse(
      baseUrl + 'documents/$id/',
    );
    var request = http.MultipartRequest(
      'PUT',
      uri,
    )
      ..headers.addAll(getFormatedHeaders(_headers))
      ..fields.addAll({
        'title': document['title'],
        'teams': document['teams'],
        'shared_to': document['shared_to'],
        'status': document['status']
      })
      ..files
          .add(await http.MultipartFile.fromPath('document_file', file.path));
    return await request.send();
  }

  Future<Response> deleteDocument(id) async {
    await updateHeaders();
    return await networkService.delete(baseUrl + 'documents/$id/',
        headers: getFormatedHeaders(_headers));
  }

  ///////////////////// TEAMS-SERVICES ///////////////////////////////

  Future<Response> getTeams() async {
    await updateHeaders();
    return await networkService.get(baseUrl + 'users/get-teams-and-users/',
        headers: getFormatedHeaders(_headers));
  }

  ///////////////////// OPPORTUNITIES-SERVICES ////////////////////////////

  Future<Response> getOpportunities({queryParams}) async {
    await updateHeaders();
    String url;
    if (queryParams != null) {
      queryParams.removeWhere((key, value) => value == "");
      String queryString =
          Uri(queryParameters: getFormatedHeaders(queryParams)).query;
      url = baseUrl + 'opportunities/' + '?' + queryString;
    } else {
      url = baseUrl + 'opportunities/';
    }
    return await networkService.get(url, headers: getFormatedHeaders(_headers));
  }

  Future<Response> deletefromModule(moduleName, id) async {
    await updateHeaders();
    return await networkService.delete(baseUrl + '$moduleName/$id/',
        headers: getFormatedHeaders(_headers));
  }

  // Future createOpportunity(opportunity, [PlatformFile file]) async {
  //   file = null;
  //   await updateHeaders();
  //   var uri = Uri.parse(
  //     baseUrl + 'opportunities/',
  //   );
  //   var request = http.MultipartRequest(
  //     'POST',
  //     uri,
  //   )
  //     ..headers.addAll(getFormatedHeaders(_headers))
  //     ..fields.addAll({
  //       'name': opportunity['name'],
  //       'account': opportunity['account'],
  //       'amount': opportunity['amount'],
  //       'currency': opportunity['currency'],
  //       'stage': opportunity['stage'],
  //       'lead_source': opportunity['lead_source'],
  //       'probability': opportunity['probability'],
  //       'description': opportunity['description'],
  //       'teams': opportunity['teams'],
  //       'assigned_to': opportunity['assigned_to'],
  //       'contacts': opportunity['contacts'],
  //       'due_date': opportunity['due_date'],
  //       'tags': opportunity['tags'],
  //     });
  //   if (file != null) {
  //     request.files.add(await http.MultipartFile.fromPath(
  //         'opportunity_attachment', file.path));
  //   }
  //   final response = await request.send();
  //   return await response.stream.bytesToString();
  // }

  Future<Response> createOpportunity(data) async {
    data.removeWhere((key, value) => value == "[]");
    data.removeWhere((key, value) => value == "");
    await updateHeaders();
    return await networkService.post(baseUrl + 'opportunities/',
        headers: getFormatedHeaders(_headers), body: data);
  }

  Future<Response> editOpportunity(opportunity, id, [PlatformFile file]) async {
    await updateHeaders();
    return await networkService.put(baseUrl + 'opportunities/$id/',
        headers: getFormatedHeaders(_headers), body: opportunity);
  }

  // Future editOpportunity(opportunity, id, [PlatformFile file]) async {
  //   await updateHeaders();
  //   var uri = Uri.parse(
  //     baseUrl + 'opportunities`/$id/',
  //   );

  //   var request = http.MultipartRequest(
  //     'PUT',
  //     uri,
  //   )
  //     ..headers.addAll(getFormatedHeaders(_headers))
  //     ..fields.addAll({
  //       'name': opportunity['name'],
  //       'account': opportunity['account'],
  //       'amount': opportunity['amount'],
  //       'currency': opportunity['currency'],
  //       'stage': opportunity['stage'],
  //       'lead_source': opportunity['lead_source'],
  //       'probability': opportunity['probability'],
  //       'description': opportunity['description'],
  //       'teams': opportunity['teams'],
  //       'assigned_to': opportunity['assigned_to'],
  //       'contacts': opportunity['contacts'],
  //       'tags': opportunity['tags'],
  //     })
  //     // ..files.add(await http.MultipartFile.fromPath(
  //     //     'opportunity_attachment', file.path))
  //         ;
  //   final response = await request.send();
  //   return await response.stream.bytesToString();

}
