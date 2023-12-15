import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:moviewebapp/app/core/responses/api_constants.dart';

Future<Response> getMethod(String url) async {
  try {
    Response response = await http.get(
      Uri.parse(ApiConstants.baseUrl + url),
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
