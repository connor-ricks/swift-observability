import Foundation

// MARK: - WithLogHandlers

/// Updates the current logging handlers for the duration of a synchronous operation.
///
/// ```swift
/// withLogHandlers(shouldReplaceExistingHandlers: false) {
///     CustomLoggingHandlerA()
///     CustomLoggingHandlerB()
///     if (isProduction) {
///         ProductionLoggingHandler()
///     }
/// } operation: {
///     @Dependency(\.logger) var logger
///     // If shouldReplaceExistingHandlers:
///     //     - Logs are sent through the provided handlers.
///     // Else:
///     //     - Logs are sent through the provided and existing handlers.
///     logger.log(.debug, "Hello new world!")
/// }
///
/// @Dependency(\.logger) var logger
/// // Logs are sent through the existing handlers.
/// logger.log(.debug, "Hello old world!")
/// ```
///
/// - Parameters:
///    - shouldReplaceExistingHandlers: Whether or not the provided handlers should
///      replace the existing handlers or be added onto the existing handlers.
///    - handlers: The log handlers to be added to the logger.
///    - operation: An operation to perform wherein the logger has been overridden.
/// - Returns: The result returned from `operation`.
@discardableResult
public func withLogHandlers<R>(
    shouldReplaceExistingHandlers: Bool = false,
    @LogHandlerBuilder _ handlers: () -> [any LogHandler],
    operation: () throws -> R
) rethrows -> R {
    try withLogger({
        if shouldReplaceExistingHandlers {
            $0.set(handlers: handlers)
        } else {
            $0.add(handlers: handlers)
        }
    }, operation: operation)
}

/// Updates the current logging handlers for the duration of an asynchronous operation.
///
/// ```swift
/// await withLogHandlers(shouldReplaceExistingHandlers: false) {
///     CustomLoggingHandlerA()
///     CustomLoggingHandlerB()
///     if (isProduction) {
///         ProductionLoggingHandler()
///     }
/// } operation: {
///     @Dependency(\.logger) var logger
///     // If shouldReplaceExistingHandlers:
///     //     - Logs are sent through the provided handlers.
///     // Else:
///     //     - Logs are sent through the provided and existing handlers.
///     logger.log(.debug, "Hello new world!")
/// }
///
/// @Dependency(\.logger) var logger
/// // Logs are sent through the existing handlers.
/// logger.log(.debug, "Hello old world!")
/// ```
///
/// - Parameters:
///    - isolation: The isolation associated with the operation.
///    - shouldReplaceExistingHandlers: Whether or not the provided handlers should
///      replace the existing handlers or be added onto the existing handlers.
///    - handlers: The log handlers to be added to the logger.
///    - operation: An operation to perform wherein the logger has been overridden.
/// - Returns: The result returned from `operation`.
@discardableResult
public func withLogHandlers<R>(
    isolation: isolated (any Actor)? = #isolation,
    shouldReplaceExistingHandlers: Bool = false,
    @LogHandlerBuilder _ handlers: () -> [any LogHandler],
    operation: () async throws -> R
) async rethrows -> R {
    try await withLogger({
        if shouldReplaceExistingHandlers {
            $0.set(handlers: handlers)
        } else {
            $0.add(handlers: handlers)
        }
    }, operation: operation)
}

// MARK: - Helpers

extension Logger {
    /// Updates the logger by adding the given handlers to the existing handlers.
    ///
    /// - Parameters:
    ///   - handlers: The handlers to add to the logger.
    /// - Returns: A new logger with the provided handler added.
    fileprivate mutating func add(@LogHandlerBuilder handlers: () -> [any LogHandler]) {
        self.handlers.append(contentsOf: handlers())
    }

    /// Updates the logger by replacing the logger's handler with the given handlers.
    ///
    /// - Parameters:
    ///   - handlers: The handlers replacing the logger's handler.
    /// - Returns: A new logger with the provided handlers.
    fileprivate mutating func set(@LogHandlerBuilder handlers: () -> [any LogHandler]) {
        self.handlers = handlers()
    }
}
