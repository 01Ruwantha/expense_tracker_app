import 'package:dartz/dartz.dart';
import 'app_failure.dart';

typedef EitherResult<T> = Future<Either<AppFailure, T>>;
