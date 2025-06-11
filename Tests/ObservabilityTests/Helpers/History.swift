import SoloObservability

// MARK: - History

/// A historical container for tracked logs.
class History<Element: Sendable>: @unchecked Sendable {

    // MARK: Properties

    /// A store of all the historical logs.
    let store = LockIsolated([Element]())

    // MARK: Accessors

    /// Add a log to the history.
    func add(_ element: Element) {
        store.withValue { $0.append(element) }
    }

    /// All the historical logs.
    private var elements: [Element] {
        store.value
    }
}

// MARK: - History + Logs

extension History where Element == Log {
    /// All the historical logs.
    var logs: [Log] { self.elements }

    /// All the historical logs for a given log level.
    func logs(level: Log.Level) -> [Log] {
        store.value.filter { $0.level == level }
    }
}

// MARK: - History + Events

extension History where Element == Event {
    /// All the historical events.
    var events: [Event] { self.elements }
}
