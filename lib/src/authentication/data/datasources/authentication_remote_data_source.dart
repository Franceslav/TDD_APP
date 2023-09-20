import 'dart:convert';
import 'package:tdd_tutorial/core/errors/exceptions.dart';
import 'package:tdd_tutorial/core/utils/constants.dart';
import 'package:tdd_tutorial/core/utils/typedef.dart';
import 'package:tdd_tutorial/src/authentication/data/models/user_model.dart';
import 'package:http/http.dart' as http;

abstract class AuthenticationRemoteDataSource {
  Future<void> createUser({
    required String name,
    required String createdAt,
    required String avatar,
  });

  Future<List<UserModel>> getUsers();
} //3:33:12

const kCreateUserEndpoint = '/test-api/users';
const kGetUsersEndpoint = '/test-api/users';

class AuthRemoteDataSrcImpl implements AuthenticationRemoteDataSource {
  const AuthRemoteDataSrcImpl(this._client);

  final http.Client _client;

  @override
  Future<void> createUser(
      {required String name,
      required String createdAt,
      required String avatar}) async {
    try {
      final response =
          await _client.post(Uri.parse('$kBaseUrl$kCreateUserEndpoint'),
              body: jsonEncode({
                'name': name,
                'createdAt': createdAt, // Исправлен ключ на 'createdAt'
              }),
              headers: {'Content-Type': 'application/json'});
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw APIException(
          message: response.body,
          statusCode: response.statusCode,
        );
      }
    } on APIException {
      rethrow;
    } catch (e) {
      throw APIException(
        message: e.toString(),
        statusCode: 505,
      );
    }
  }

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _client.get(
        Uri.parse('$kBaseUrl$kGetUsersEndpoint'),
      );
      if (response.statusCode != 200) {
        throw APIException(
          message: response.body,
          statusCode: response.statusCode,
        );
      }
      return List<DataMap>.from(jsonDecode(response.body) as List)
          .map((userData) => UserModel.fromMap(userData))
          .toList();
    } on APIException {
      rethrow;
    } catch (e) {
      throw APIException(
        message: e.toString(),
        statusCode: 505,
      );
    }
  }
}
