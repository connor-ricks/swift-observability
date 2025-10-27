@_exported import Dependencies
import Foundation

/// Updates observables for the duration of a synchronous operation.
///
/// - Parameters:
///   - updateObservables: A closure for updating the current observables.
///   - operation: An operation to perform wherein the observables has been overridden.
///
/// - Returns: The result returned from `operation`.
@discardableResult
public func withObservability<R>(
    _ updateObservables: (inout Observables) throws -> Void,
    operation: () throws -> R
) rethrows -> R {
    try withDependencies({
        try updateObservables(&$0.observables)
    }, operation: operation)
}

/// Updates observables for the duration of an asynchronous operation.
///
/// - Parameters:
///   - updateObservables: A closure for updating the current observables.
///   - operation: An operation to perform wherein the observables has been overridden.
///
/// - Returns: The result returned from `operation`.
@discardableResult
public func withObservability<R>(
    isolation: isolated (any Actor)? = #isolation,
    _ updateObservables: (inout Observables) throws -> Void,
    operation: () async throws -> R
) async rethrows -> R {
    try await withDependencies({
        try updateObservables(&$0.observables)
    }, operation: operation)
}
