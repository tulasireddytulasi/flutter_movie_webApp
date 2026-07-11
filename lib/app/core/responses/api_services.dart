import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';

Future<Response> getMethod({required String url, String baseUrl = ""}) async {
  try {
    if(baseUrl.isEmpty) baseUrl = ApiConstants.baseUrl;
    Response response = await http.get(
      Uri.parse(baseUrl + url),
      headers: await _authorizationHeader(),
    );
    return response;
  } catch (error, stacktrace) {
    rethrow;
  }
}

Future<Map<String, String>> _authorizationHeader() async {
  return {
    "content-type": "application/json",
    "accept": "application/json",
  };
}
