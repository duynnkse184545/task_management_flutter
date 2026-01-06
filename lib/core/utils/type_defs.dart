import 'package:dartz/dartz.dart';
import 'package:task_management_flutter/core/error/failures.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = Future<Either<Failure, void>>;
typedef StreamEither<T> = Stream<Either<Failure, T>>;