@_exported import Dependencies
import Foundation

/// Updates observability for the duration of a synchronous operation.
///
/// - Parameters:
///   - updateObservability: A closure for updating the current observability.
///   - operation: An operation to perform wherein the observability has been overridden.
///
/// - Returns: The result returned from `operation`.
@discardableResult
public func withObservability<R>(
    _ updateObservability: (inout Observability) throws -> Void,
    operation: () throws -> R
) rethrows -> R {
    try withDependencies({
        try updateObservability(&$0.observability)
    }, operation: operation)
}

/// Updates observability for the duration of an asynchronous operation.
///
/// - Parameters:
///   - updateObservability: A closure for updating the current observability.
///   - operation: An operation to perform wherein the observability has been overridden.
///
/// - Returns: The result returned from `operation`.
@discardableResult
public func withObservability<R>(
    isolation: isolated (any Actor)? = #isolation,
    _ updateObservability: (inout Observability) throws -> Void,
    operation: () async throws -> R
) async rethrows -> R {
    try await withDependencies({
        try updateObservability(&$0.observability)
    }, operation: operation)
}
