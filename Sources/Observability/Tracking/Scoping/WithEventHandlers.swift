import Foundation

// MARK: - WithEventHandlers

/// Updates the current tracking handlers for the duration of a synchronous operation.
///
/// ```swift
/// withEventHandlers(shouldReplaceExistingHandlers: false) {
///     CustomEventHandlerA()
///     CustomEventHandlerB()
///     if (isProduction) {
///         ProductionEventHandler()
///     }
/// } operation: {
///     @Dependency(\.tracker) var tracker
///     // If shouldReplaceExistingHandlers:
///     //     - Events are sent through the provided handlers.
///     // Else:
///     //     - Events are sent through the provided and existing handlers.
///     tracker.track("Button Pressed")
/// }
///
/// @Dependency(\.tracker) var tracker
/// // Events are sent through the existing handlers.
/// tracker.track("Button Pressed")
/// ```
///
/// - Parameters:
///    - shouldReplaceExistingHandlers: Whether or not the provided handlers should
///      replace the existing handlers or be added onto the existing handlers.
///    - handlers: The event handlers to be added to the tracker.
///    - operation: An operation to perform wherein the tracker has been overridden.
/// - Returns: The result returned from `operation`.
@discardableResult
public func withEventHandlers<R>(
    shouldReplaceExistingHandlers: Bool = false,
    @EventHandlerBuilder _ handlers: () -> [any EventHandler],
    operation: () throws -> R
) rethrows -> R {
    try withTracker({
        if shouldReplaceExistingHandlers {
            $0.set(handlers: handlers)
        } else {
            $0.add(handlers: handlers)
        }
    }, operation: operation)
}

/// Updates the current tracking handlers for the duration of an asynchronous operation.
///
/// ```swift
/// await withEventHandlers(shouldReplaceExistingHandlers: false) {
///     CustomEventHandlerA()
///     CustomEventHandlerB()
///     if (isProduction) {
///         ProductionEventHandler()
///     }
/// } operation: {
///     @Dependency(\.tracker) var tracker
///     // If shouldReplaceExistingHandlers:
///     //     - Events are sent through the provided handlers.
///     // Else:
///     //     - Events are sent through the provided and existing handlers.
///     tracker.track("Button Pressed")
/// }
///
/// @Dependency(\.tracker) var tracker
/// // Events are sent through the existing handlers.
/// tracker.track("Button Pressed")
/// ```
///
/// - Parameters:
///    - isolation: The isolation associated with the operation.
///    - shouldReplaceExistingHandlers: Whether or not the provided handlers should
///      replace the existing handlers or be added onto the existing handlers.
///    - handlers: The event handlers to be added to the tracker.
///    - operation: An operation to perform wherein the tracker has been overridden.
/// - Returns: The result returned from `operation`.
@discardableResult
public func withEventHandlers<R>(
    isolation: isolated (any Actor)? = #isolation,
    shouldReplaceExistingHandlers: Bool = false,
    @EventHandlerBuilder _ handlers: () -> [any EventHandler],
    operation: () async throws -> R
) async rethrows -> R {
    try await withTracker({
        if shouldReplaceExistingHandlers {
            $0.set(handlers: handlers)
        } else {
            $0.add(handlers: handlers)
        }
    }, operation: operation)
}

// MARK: - Helpers

extension Tracker {
    /// Updates the tracker by adding the given handlers to the existing handlers.
    ///
    /// - Parameters:
    ///   - handlers: The handlers to add to the tracker.
    /// - Returns: A new tracker with the provided handler added.
    fileprivate mutating func add(@EventHandlerBuilder handlers: () -> [any EventHandler]) {
        self.handlers.append(contentsOf: handlers())
    }

    /// Updates the tracker by replacing the tracker's handler with the given handlers.
    ///
    /// - Parameters:
    ///   - handlers: The handlers replacing the tracker's handler.
    /// - Returns: A new tracker with the provided handlers.
    fileprivate mutating func set(@EventHandlerBuilder handlers: () -> [any EventHandler]) {
        self.handlers = handlers()
    }
}
