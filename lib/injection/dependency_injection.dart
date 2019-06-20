
import 'package:spacelaunchnow_flutter/repository/sln_repository_impl.dart';
import 'package:spacelaunchnow_flutter/repository/sln_repository.dart';

/// Simple DI
class Injector {

  static final Injector _singleton = new Injector._internal();

  factory Injector() {
    return _singleton;
  }

  Injector._internal();

  SLNRepository get slnRepository {
        return new SLNRepositoryImpl();
  }
}
