import Foundation

/// A log emitted by a `Logger`
public struct Log: Sendable, Equatable {
    /// The label of the logger that emitted the log.
    public var label: String
    /// The log severity level.
    public var level: Level
    /// The message to log.
    public var message: String
    /// The metadata associated with this log.
    public var metadata: Metadata
    /// The file the log was emitted from.
    public var file: String
    /// The function the log was emitted from.
    public var function: String
    /// The line the log was emitted from.
    public var line: UInt

    // MARK: Initailizers

    /// Creates a log emitted from a `Logger`.
    ///
    /// - Parameters:
    ///   - label: The label of the logger that emitted the log.
    ///   - level: The log severity level.
    ///   - message: The message to log.
    ///   - metadata: The metadata associated with this log.
    ///   - file: The file the log was emitted from.
    ///   - function: The function the log was emitted from.
    ///   - line: The line the log was emitted from.
    @inlinable
    public init(
        label: String,
        level: Level,
        message: String,
        metadata: Metadata,
        file: String,
        function: String,
        line: UInt
    ) {
        self.label = label
        self.level = level
        self.message = message
        self.metadata = metadata
        self.file = file
        self.function = function
        self.line = line
    }
}
