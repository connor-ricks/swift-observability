import Foundation

// MARK: - WithLogLevel

/// Updates the logging level for all of the logger's handlers for the duration of a synchronous operation.
///
/// - Warning: This means that if a log handler was previously only logging critical errors, and the log
///   level is lowered, that handler will log all errors at that level for the duration of the operation.
///
/// ```swift
/// withLogLevel(.critical) {
///     @Dependency(\.logger) var logger
///     logger.log(.debug, "Hello new world!") // Silenced
/// }
///
/// @Dependency(\.logger) var logger
/// logger.log(.debug, "Hello old world!") // Logged
/// ```
///
/// - Parameters:
///    - level: The new log level for all of the logger's handlers.
///    - operation: An operation to perform wherein the logger has been overridden.
/// - Returns: The result returned from `operation`.
@discardableResult
public func withLogLevel<R>(
    _ level: Log.Level,
    operation: () throws -> R
) rethrows -> R {
    try withLogger({
        $0.handlers = $0.handlers.map { handler in
            var copy = handler
            copy.level = level
            return copy
        }
    }, operation: operation)
}

/// Updates the logging level for all of the logger's handlers for the duration of an asynchronous operation.
///
/// ```swift
/// await withLogLevel(.critical) {
///     @Dependency(\.logger) var logger
///     logger.log(.debug, "Hello new world!") // Silenced
/// }
///
/// @Dependency(\.logger) var logger
/// logger.log(.debug, "Hello old world!") // Logged
/// ```
///
/// - Parameters:
///    - isolation: The isolation associated with the operation.
///    - level: The new log level for all of the logger's handlers.
///    - operation: An operation to perform wherein the logger has been overridden.
/// - Returns: The result returned from `operation`.
@discardableResult
public func withLogLevel<R>(
    isolation: isolated (any Actor)? = #isolation,
    _ level: Log.Level,
    operation: () async throws -> R
) async rethrows -> R {
    try await withLogger({
        $0.handlers = $0.handlers.map { handler in
            var copy = handler
            copy.level = level
            return copy
        }
    }, operation: operation)
}
