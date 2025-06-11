import Foundation

/// Updates the tracker for the duration of a synchronous operation.
///
/// ```swift
/// withTracker { tracker in
///     tracker.label = "com.example"
///     tracker[metadataKey: "foo"] = "bar"
/// } operation: {
///     @Dependency(\.tracker) var tracker // Newly modified tracker.
/// }
///
/// @Dependency(\.tracker) var tracker // Original tracker.
/// ```
///
/// - Parameters:
///    - updateTracker: A closure for updating the current tracker.
///    - operation: An operation to perform wherein the tracker has been overridden.
/// - Returns: The result returned from `operation`.
@discardableResult
public func withTracker<R>(
    _ updateTracker: (inout Tracker) throws -> Void,
    operation: () throws -> R
) rethrows -> R {
    try withObservability({
        try updateTracker(&$0.tracker)
    }, operation: operation)
}

/// Updates the tracker for the duration of an asynchronous operation.
///
/// ```swift
/// await withTracker { tracker in
///     tracker.label = "com.example"
///     tracker[metadataKey: "foo"] = "bar"
/// } operation: {
///     @Dependency(\.tracker) var tracker // Newly modified tracker.
/// }
///
/// @Dependency(\.tracker) var tracker // Original tracker.
/// ```
///
/// - Parameters:
///    - updateTracker: A closure for updating the current tracker.
///    - operation: An operation to perform wherein the tracker has been overridden.
/// - Returns: The result returned from `operation`.
@discardableResult
public func withTracker<R>(
    isolation: isolated (any Actor)? = #isolation,
    _ updateTracker: (inout Tracker) throws -> Void,
    operation: () async throws -> R
) async rethrows -> R {
    try await withObservability({
        try updateTracker(&$0.tracker)
    }, operation: operation)
}
