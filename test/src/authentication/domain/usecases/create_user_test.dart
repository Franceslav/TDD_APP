import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdd_tutorial/src/authentication/domain/repositories/authentication_repository.dart';
import 'package:tdd_tutorial/src/authentication/domain/usecases/create_user.dart';

class MockAuthRepo extends Mock implements AuthenticationRepository {}

void main() {
  late CreateUser usecase;
  late AuthenticationRepository repository;

  setUp(() {
    repository = MockAuthRepo();
    usecase = CreateUser(repository);
    registerFallbackValue(Football());
  });

  const params = CreateUserParams.empty();
  test(
    'should call the [AuthRepo.createUser]',
    () async {
      when(
        () => repository.createUser(
          createdAt: any(named: 'createdAt'),
          name: any(named: 'name'),
          avatar: any(named: 'avatar'),
        ),
      ).thenAnswer((_) async => const Right(null));
      //final params = const CreateUserParams(
      // createdAt: 'createdAt', name: 'name', avatar: 'avatar');

      final result = await usecase(params);

      expect(result, equals(const Right<dynamic, void>(null)));
      verify(
        () => repository.createUser(
            createdAt: params.createdAt,
            name: params.name,
            avatar: params.avatar),
      ).called(1);

      verifyNoMoreInteractions(repository);
      // Left<void, dynamic>
    },
  );
}

class Football {}
