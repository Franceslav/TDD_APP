import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:tdd_tutorial/core/errors/exceptions.dart';
import 'package:tdd_tutorial/core/utils/constants.dart';
import 'package:tdd_tutorial/src/authentication/data/datasources/authentication_remote_data_source.dart';
import 'package:tdd_tutorial/src/authentication/data/models/user_model.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  late MockClient client;
  late AuthenticationRemoteDataSource remoteDataSource;

  setUp(() {
    client = MockClient();
    remoteDataSource = AuthRemoteDataSrcImpl(client);
    registerFallbackValue(Uri());
  });

  group('createUser', () {
    test(
      'should complete successfully when the status code is 200 or 201',
      () async {
        final expectedUrl = Uri.parse('$kBaseUrl$kCreateUserEndpoint');
        when(() => client.post(
              expectedUrl,
              body: any(named: 'body'),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response('User created successfully', 201),
        );

        final methodCall = remoteDataSource.createUser;

        await methodCall(
          createdAt: 'createdAt',
          name: 'name',
          avatar: 'avatar',
        );

        verify(
          () => client.post(
            expectedUrl,
            body: any(named: 'body'),
            headers: any(named: 'headers'),
          ),
        ).called(1);
      },
    );

    test(
      'should be [APIException] when the status code is not 200 or 201',
      () async {
        final expectedUrl = Uri.parse('$kBaseUrl$kCreateUserEndpoint');

        when(() => client.post(
              expectedUrl,
              body: any(named: 'body'),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response('Invalid email address', 400),
        );
        final methodCall = remoteDataSource.createUser;

        expect(
          () async => methodCall(
            createdAt: 'createdAt',
            name: 'name',
            avatar: 'avatar',
          ),
          throwsA(
            const APIException(
                message: 'Invalid email address', statusCode: 400),
          ),
        );

        verify(
          () => client.post(
            Uri.https(kBaseUrl, kCreateUserEndpoint),
            body: any(named: 'body'),
            headers: any(named: 'headers'),
          ),
        ).called(1);

        verifyNoMoreInteractions(client);
      },
    );
  });

  group('getUsers', () {
    const tUsers = [UserModel.empty()];
    test(
      'should return [List<User>] when the status code is 200',
      () async {
        when(() => client.get(any())).thenAnswer(
          (_) async => http.Response(jsonEncode([tUsers.first.toMap()]), 200),
        );
        final result = await remoteDataSource.getUsers();

        expect(result, equals(tUsers));

        verify(() => client.get(
              Uri.https(kBaseUrl, kCreateUserEndpoint),
            )).called(1);
        verifyNoMoreInteractions(client);
      },
    );
    test(
      'should throw [APIException] when the status code is not 200',
      () async {
        const tMessage = 'Server down, Server'
            'down, I repeat Server down. Mayday May day, We are'
            'going down,'
            'AOAOAOAOAOAOAOAOAOOAOOAOAOAOAOOAOAOA'
            'AOAOAO';

        when(() => client.get(any())).thenAnswer((_) async => http.Response(
              tMessage,
              500,
            ));
        final methodCall = remoteDataSource.getUsers;

        expect(
          () => methodCall(),
          throwsA(
            const APIException(message: tMessage, statusCode: 500),
          ),
        );
        verify(() => client.get(
              Uri.https(kBaseUrl, kCreateUserEndpoint),
            )).called(1);
        verifyNoMoreInteractions(client);
      },
    );
  });
}
