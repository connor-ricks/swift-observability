import Foundation

/// Updates the logger for the duration of a synchronous operation.
///
/// ```swift
/// withLogger { logger in
///     logger.label = "com.example"
///     logger[metadataKey: "foo"] = "bar"
/// } operation: {
///     @Dependency(\.logger) var logger // Newly modified logger.
/// }
///
/// @Dependency(\.logger) var logger // Original logger.
/// ```
///
/// - Parameters:
///    - updateLogger: A closure for updating the current logger.
///    - operation: An operation to perform wherein the logger has been overridden.
/// - Returns: The result returned from `operation`.
@discardableResult
public func withLogger<R>(
    _ updateLogger: (inout Logger) throws -> Void,
    operation: () throws -> R
) rethrows -> R {
    try withObservability({
        try updateLogger(&$0.logger)
    }, operation: operation)
}

/// Updates the logger for the duration of an asynchronous operation.
///
/// ```swift
/// await withLogger { logger in
///     logger.label = "com.example"
///     logger[metadataKey: "foo"] = "bar"
/// } operation: {
///     @Dependency(\.logger) var logger // Newly modified logger.
/// }
///
/// @Dependency(\.logger) var logger // Original logger.
/// ```
///
/// - Parameters:
///    - updateLogger: A closure for updating the current logger.
///    - operation: An operation to perform wherein the logger has been overridden.
/// - Returns: The result returned from `operation`.
@discardableResult
public func withLogger<R>(
    isolation: isolated (any Actor)? = #isolation,
    _ updateLogger: (inout Logger) throws -> Void,
    operation: () async throws -> R
) async rethrows -> R {
    try await withObservability({
        try updateLogger(&$0.logger)
    }, operation: operation)
}
