@_exported import Dependencies
import Foundation

// MARK: - Tracker

public typealias Tracker = Emitter<any EventHandler>

extension Tracker {
    /// Track an event.
    ///
    /// - parameters:
    ///    - name: The name of the event.
    ///    - metadata: The metadata associated with the event.
    ///    - file: The file this event originates from.
    ///    - function: The function this event originates from.
    ///    - line: The line this event originates from.
    public func track(
        _ name: String,
        metadata: Metadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        emit(
            Event(
                label: label,
                name: name,
                metadata: metadata ?? [:],
                file: file,
                function: function,
                line: line
            )
        )
    }
}

// MARK: - DependencyValues + Tracker

extension DependencyValues {
    /// A tracker useful for tracking events.
    public var tracker: Tracker {
        get { observables.tracker }
        set { observables.tracker = newValue }
    }
}
