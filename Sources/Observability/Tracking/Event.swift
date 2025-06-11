import Foundation

/// An event emitted by a `Tracker`
public struct Event: Sendable, Equatable {
    /// The label of the tracker that emitted the event.
    public var label: String
    /// The name of the event.
    public var name: String
    /// The metadata associated with this event.
    public var metadata: Metadata
    /// The file the event was emitted from.
    public var file: String
    /// The function the event was emitted from.
    public var function: String
    /// The line the event was emitted from.
    public var line: UInt

    // MARK: Initailizers

    /// An event emitted from a `Tracker`.
    ///
    /// - Parameters:
    ///   - label: The label of the tracker that emitted the event.
    ///   - name: The name of the event.
    ///   - metadata: The metadata associated with this event.
    ///   - file: The file the event was emitted from.
    ///   - function: The function the event was emitted from.
    ///   - line: The line the event was emitted from.
    @inlinable
    public init(
        label: String,
        name: String,
        metadata: Metadata,
        file: String,
        function: String,
        line: UInt
    ) {
        self.label = label
        self.name = name
        self.metadata = metadata
        self.file = file
        self.function = function
        self.line = line
    }
}
