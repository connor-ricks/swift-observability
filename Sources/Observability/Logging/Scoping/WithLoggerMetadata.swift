import Foundation

/// Updates the logger's metadata for the duration of a synchronous operation.
///
/// ```swift
/// withLoggerMetadata(metadata: ["key": "value"]) {
///     @Dependency(\.logger) var logger // Metadata updated.
/// }
///
/// @Dependency(\.logger) var logger // Original metadata.
/// ```
///
/// - Important: The default implementation of `combine` resolves key conflicts by taking
///   the new value provided in `metadata`.
///
/// - Parameters:
///    - metadata: The metadata to add to the logger.
///    - combine: A closure that takes the current and new values for any duplicate keys.
///      The closure returns the desired value for the final dictionary. The default value resolves conflicts
///      by taking the new value.
///    - operation: An operation to perform wherein the logger has been overridden.
/// - Returns: The result returned from `operation`.
@discardableResult
public func withLoggerMetadata<R>(
    _ metadata: Metadata,
    uniquingKeysWith combine: (MetadataValue, MetadataValue) -> MetadataValue = { _, new in new },
    operation: () throws -> R
) rethrows -> R {
    try withLogger({ logger in
        logger.metadata.merge(metadata, uniquingKeysWith: combine)
    }, operation: operation)
}

/// Updates the logger's metadata for the duration of an asynchronous operation.
///
/// ```swift
/// withLoggerMetadata(metadata: ["key": "value"]) {
///     @Dependency(\.logger) var logger // Metadata updated.
/// }
///
/// @Dependency(\.logger) var logger // Original metadata.
/// ```
///
/// - Important: The default implementation of `combine` resolves key conflicts by taking
///   the new value provided in `metadata`.
///
/// - Parameters:
///    - metadata: The metadata to add to the logger.
///    - combine: A closure that takes the current and new values for any duplicate keys.
///      The closure returns the desired value for the final dictionary. The default value resolves conflicts
///      by taking the new value.
///    - operation: An operation to perform wherein the logger has been overridden.
/// - Returns: The result returned from `operation`.
@discardableResult
public func withLoggerMetadata<R>(
    isolation: isolated (any Actor)? = #isolation,
    _ metadata: Metadata,
    uniquingKeysWith combine: (MetadataValue, MetadataValue) -> MetadataValue = { _, new in new },
    operation: () async throws -> R
) async rethrows -> R {
    try await withLogger({ logger in
        logger.metadata.merge(metadata, uniquingKeysWith: combine)
    }, operation: operation)
}
