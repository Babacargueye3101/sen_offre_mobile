import 'dart:convert';
import 'dart:io';
import '../config/api_config.dart';
import '../models/company.dart';
import '../services/user_service.dart';

class CompanyService {
  static Future<CompaniesResponse> getCompanies({
    int page = 1,
    int perPage = 20,
    String? authToken,
    String? query,
  }) async {
    try {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;

      final qp = <String, String>{
        'page': page.toString(),
        'perPage': perPage.toString(),
      };
      if (query != null && query.isNotEmpty) {
        qp['q'] = query;
      }

      final uri = Uri.parse(
        '${ApiConfig.getBaseUrl()}${ApiConfig.companiesEndpoint}',
      ).replace(queryParameters: qp);

      final httpRequest = await client.getUrl(uri);
      httpRequest.headers.set('Content-Type', 'application/json');
      httpRequest.headers.set('Accept', 'application/json');

      final token = authToken ?? UserService.authToken;
      final tokenType = UserService.tokenType ?? 'Bearer';
      if (token != null) {
        httpRequest.headers.set('Authorization', '$tokenType $token');
      }

      final response = await httpRequest.close();
      final responseBody = await response.transform(utf8.decoder).join();

      client.close();

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(responseBody);
        return CompaniesResponse.fromJson(jsonData);
      } else {
        throw Exception('Erreur lors de la récupération des entreprises: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion. Veuillez vérifier votre connexion internet.');
    }
  }
}
