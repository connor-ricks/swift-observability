@_exported import Dependencies
import Foundation

// MARK: - Observability

public struct Observability: Sendable {
    /// A logger useful for logging messages.
    public var logger: Logger
    /// A tracker useful for tracking events.
    public var tracker: Tracker
}

// MARK: - ObservabilityKey

private enum ObservabilityKey: DependencyKey {

    private static let loggerLabel: String = "com.solo.observability.logger"
    private static let trackerLabel: String = "com.solo.observability.tracker"

    static var liveValue: Observability {
        #if DEBUG
        Observability(
            logger: Logger(label: loggerLabel, handlers: {
                ConsoleLogHandler(level: .debug)
            }),
            tracker: Tracker(label: trackerLabel, handlers: {
                ConsoleEventHandler()
            })
        )
        #else
        Observability(
            logger: Logger(label: loggerLabel),
            tracker: Tracker(label: trackerLabel)
        )
        #endif
    }

    static var testValue: Observability {
        Observability(
            logger: Logger(label: loggerLabel + ".tests"),
            tracker: Tracker(label: trackerLabel + ".tests")
        )
    }
}

// MARK: - DependencyValues + Observability

extension DependencyValues {
    /// A collection of observability tools.
    public var observability: Observability {
        get { self[ObservabilityKey.self] }
        set { self[ObservabilityKey.self] = newValue }
    }
}
