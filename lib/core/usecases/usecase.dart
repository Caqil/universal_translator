import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

/// Base class for all use cases in the application
///
/// This follows the Clean Architecture principle where use cases represent
/// the application's business logic and are independent of external concerns.
///
/// Type parameters:
/// - [Type]: The return type of the use case
/// - [Params]: The input parameters for the use case
abstract class UseCase<Type, Params> {
  /// Execute the use case with the given parameters
  ///
  /// Returns a [Future] that completes with either:
  /// - [Right] containing the successful result of type [Type]
  /// - [Left] containing a [Failure] if an error occurred
  Future<Either<Failure, Type>> call(Params params);
}

/// Base class for use cases that don't require parameters
///
/// This is a specialized version of [UseCase] for operations that don't
/// need input parameters.
abstract class NoParamsUseCase<Type> {
  /// Execute the use case without parameters
  ///
  /// Returns a [Future] that completes with either:
  /// - [Right] containing the successful result of type [Type]
  /// - [Left] containing a [Failure] if an error occurred
  Future<Either<Failure, Type>> call();
}

/// Base class for synchronous use cases
///
/// For operations that can be completed synchronously without async operations.
abstract class SyncUseCase<Type, Params> {
  /// Execute the use case synchronously with the given parameters
  ///
  /// Returns either:
  /// - [Right] containing the successful result of type [Type]
  /// - [Left] containing a [Failure] if an error occurred
  Either<Failure, Type> call(Params params);
}

/// Base class for synchronous use cases that don't require parameters
abstract class NoParamsSyncUseCase<Type> {
  /// Execute the use case synchronously without parameters
  ///
  /// Returns either:
  /// - [Right] containing the successful result of type [Type]
  /// - [Left] containing a [Failure] if an error occurred
  Either<Failure, Type> call();
}

/// Base class for stream-based use cases
///
/// For operations that return a stream of results, such as real-time updates
/// or continuous data monitoring.
abstract class StreamUseCase<Type, Params> {
  /// Execute the use case with the given parameters
  ///
  /// Returns a [Stream] that emits either:
  /// - [Right] containing successful results of type [Type]
  /// - [Left] containing [Failure] instances when errors occur
  Stream<Either<Failure, Type>> call(Params params);
}

/// Base class for stream-based use cases that don't require parameters
abstract class NoParamsStreamUseCase<Type> {
  /// Execute the use case without parameters
  ///
  /// Returns a [Stream] that emits either:
  /// - [Right] containing successful results of type [Type]
  /// - [Left] containing [Failure] instances when errors occur
  Stream<Either<Failure, Type>> call();
}

/// Marker class for use cases that don't require parameters
///
/// This class should be used as the [Params] type for use cases that
/// don't need input parameters but still want to use the base [UseCase] class.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}

/// Base class for paginated use cases
///
/// For operations that return paginated results, providing built-in
/// pagination support.
abstract class PaginatedUseCase<Type, Params extends PaginationParams> {
  /// Execute the use case with pagination parameters
  ///
  /// Returns a [Future] that completes with either:
  /// - [Right] containing a [PaginatedResult] with the data and pagination info
  /// - [Left] containing a [Failure] if an error occurred
  Future<Either<Failure, PaginatedResult<Type>>> call(Params params);
}

/// Base parameters for paginated use cases
abstract class PaginationParams extends Equatable {
  /// The page number to retrieve (starting from 1)
  final int page;

  /// The number of items per page
  final int limit;

  /// Optional search query
  final String? query;

  /// Optional sort field
  final String? sortBy;

  /// Sort direction (true for ascending, false for descending)
  final bool ascending;

  const PaginationParams({
    required this.page,
    required this.limit,
    this.query,
    this.sortBy,
    this.ascending = true,
  });

  @override
  List<Object?> get props => [page, limit, query, sortBy, ascending];
}

/// Result wrapper for paginated data
class PaginatedResult<T> extends Equatable {
  /// The list of items for the current page
  final List<T> items;

  /// The current page number
  final int currentPage;

  /// The total number of pages available
  final int totalPages;

  /// The total number of items across all pages
  final int totalItems;

  /// The number of items per page
  final int itemsPerPage;

  /// Whether there are more pages available
  final bool hasNextPage;

  /// Whether there are previous pages available
  final bool hasPreviousPage;

  const PaginatedResult({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  /// Create a paginated result from raw data
  factory PaginatedResult.fromData({
    required List<T> items,
    required int currentPage,
    required int totalItems,
    required int itemsPerPage,
  }) {
    final totalPages = (totalItems / itemsPerPage).ceil();
    return PaginatedResult(
      items: items,
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: totalItems,
      itemsPerPage: itemsPerPage,
      hasNextPage: currentPage < totalPages,
      hasPreviousPage: currentPage > 1,
    );
  }

  /// Create an empty paginated result
  factory PaginatedResult.empty() {
    return const PaginatedResult(
      items: [],
      currentPage: 1,
      totalPages: 0,
      totalItems: 0,
      itemsPerPage: 0,
      hasNextPage: false,
      hasPreviousPage: false,
    );
  }

  @override
  List<Object?> get props => [
        items,
        currentPage,
        totalPages,
        totalItems,
        itemsPerPage,
        hasNextPage,
        hasPreviousPage,
      ];
}

/// Utility class for common use case operations
class UseCaseUtils {
  // Private constructor to prevent instantiation
  UseCaseUtils._();

  /// Create a successful result
  static Either<Failure, T> success<T>(T data) {
    return Right(data);
  }

  /// Create a failure result
  static Either<Failure, T> failure<T>(Failure failure) {
    return Left(failure);
  }

  /// Handle exceptions in use cases and convert them to failures
  static Either<Failure, T> handleException<T>(Exception exception) {
    return Left(FailureConverter.fromException(exception));
  }

  /// Execute a function and handle any exceptions
  static Future<Either<Failure, T>> safeCall<T>(
    Future<T> Function() function,
  ) async {
    try {
      final result = await function();
      return Right(result);
    } on Exception catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  /// Execute a synchronous function and handle any exceptions
  static Either<Failure, T> safeSyncCall<T>(T Function() function) {
    try {
      final result = function();
      return Right(result);
    } on Exception catch (e) {
      return Left(FailureConverter.fromException(e));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  /// Transform a stream to handle errors
  static Stream<Either<Failure, T>> safeStream<T>(Stream<T> stream) {
    return stream
        .map<Either<Failure, T>>((data) => Right(data))
        .handleError((error) {
      if (error is Exception) {
        return Left(FailureConverter.fromException(error));
      }
      return Left(ServerFailure(
        message: error.toString(),
        code: 'UNKNOWN_ERROR',
      ));
    });
  }
}

/// Mixin for use cases that need caching capabilities
mixin CacheableUseCase<Type, Params> on UseCase<Type, Params> {
  /// Cache duration for the use case results
  Duration get cacheDuration => const Duration(minutes: 5);

  /// Cache key generator for the given parameters
  String getCacheKey(Params params);

  /// Check if cached data is still valid
  bool isCacheValid(DateTime cachedAt) {
    return DateTime.now().difference(cachedAt) < cacheDuration;
  }
}

/// Mixin for use cases that need retry capabilities
mixin RetryableUseCase<Type, Params> on UseCase<Type, Params> {
  /// Maximum number of retry attempts
  int get maxRetries => 3;

  /// Delay between retry attempts
  Duration get retryDelay => const Duration(seconds: 1);

  /// Determine if the failure should trigger a retry
  bool shouldRetry(Failure failure) {
    return failure is NetworkFailure || failure is ServerFailure;
  }

  /// Execute the use case with retry logic
  Future<Either<Failure, Type>> executeWithRetry(Params params) async {
    int attempts = 0;
    Either<Failure, Type> result;

    do {
      result = await call(params);
      attempts++;

      if (result.isLeft() &&
          shouldRetry(result.fold((l) => l, (r) => throw Exception()))) {
        if (attempts < maxRetries) {
          await Future.delayed(retryDelay * attempts); // Exponential backoff
        }
      } else {
        break;
      }
    } while (attempts < maxRetries);

    return result;
  }
}

/// Mixin for use cases that need validation
mixin ValidatableUseCase<Type, Params> on UseCase<Type, Params> {
  /// Validate the input parameters
  Either<Failure, void> validate(Params params);

  /// Execute the use case with validation
  Future<Either<Failure, Type>> executeWithValidation(Params params) async {
    final validationResult = validate(params);
    if (validationResult.isLeft()) {
      return Left(validationResult.fold((l) => l, (r) => throw Exception()));
    }

    return call(params);
  }
}
