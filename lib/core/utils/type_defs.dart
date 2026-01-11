import 'package:fpdart/fpdart.dart';
import 'package:task_management_flutter/core/error/failures.dart';

typedef TaskResult<T> = TaskEither<Failure, T>;
typedef TaskVoid = TaskEither<Failure, void>;
typedef TaskUnit = TaskEither<Failure, Unit>;
typedef StreamEither<T> = Stream<Either<Failure, T>>;