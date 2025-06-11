import Foundation

/// Updates the tracker's metadata for the duration of a synchronous operation.
///
/// ```swift
/// withTrackerMetadata(metadata: ["key": "value"]) {
///     @Dependency(\.tracker) var tracker // Metadata updated.
/// }
///
/// @Dependency(\.tracker) var tracker // Original metadata.
/// ```
///
/// - Important: The default implementation of `combine` resolves key conflicts by taking
///   the new value provided in `metadata`.
///
/// - Parameters:
///    - metadata: The metadata to add to the tracker.
///    - combine: A closure that takes the current and new values for any duplicate keys.
///      The closure returns the desired value for the final dictionary. The default value resolves conflicts
///      by taking the new value.
///    - operation: An operation to perform wherein the tracker has been overridden.
/// - Returns: The result returned from `operation`.
@discardableResult
public func withTrackerMetadata<R>(
    _ metadata: Metadata,
    uniquingKeysWith combine: (MetadataValue, MetadataValue) -> MetadataValue = { _, new in new },
    operation: () throws -> R
) rethrows -> R {
    try withTracker({ tracker in
        tracker.metadata.merge(metadata, uniquingKeysWith: combine)
    }, operation: operation)
}

/// Updates the tracker's metadata for the duration of an asynchronous operation.
///
/// ```swift
/// withTrackerMetadata(metadata: ["key": "value"]) {
///     @Dependency(\.tracker) var tracker // Metadata updated.
/// }
///
/// @Dependency(\.tracker) var tracker // Original metadata.
/// ```
///
/// - Important: The default implementation of `combine` resolves key conflicts by taking
///   the new value provided in `metadata`.
///
/// - Parameters:
///    - metadata: The metadata to add to the tracker.
///    - combine: A closure that takes the current and new values for any duplicate keys.
///      The closure returns the desired value for the final dictionary. The default value resolves conflicts
///      by taking the new value.
///    - operation: An operation to perform wherein the tracker has been overridden.
/// - Returns: The result returned from `operation`.
@discardableResult
public func withTrackerMetadata<R>(
    isolation: isolated (any Actor)? = #isolation,
    _ metadata: Metadata,
    uniquingKeysWith combine: (MetadataValue, MetadataValue) -> MetadataValue = { _, new in new },
    operation: () async throws -> R
) async rethrows -> R {
    try await withTracker({ tracker in
        tracker.metadata.merge(metadata, uniquingKeysWith: combine)
    }, operation: operation)
}
