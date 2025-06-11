@_exported import Dependencies
import Foundation

// MARK: - Logger

public typealias Logger = Emitter<any LogHandler>

extension Logger where Handler == any LogHandler {
    /// Log a message at the provided severity level.
    ///
    /// - parameters:
    ///    - level: The level of severity of the log.
    ///    - message: The message associated with the log.
    ///    - metadata: The metadata associated with the event.
    ///    - file: The file this log originates from.
    ///    - function: The function this log originates from.
    ///    - line: The line this log originates from.
    public func log(
        _ level: Log.Level,
        _ message: String,
        metadata: Metadata? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        emit(
            Log(
                label: label,
                level: level,
                message: message,
                metadata: metadata ?? [:],
                file: file,
                function: function,
                line: line
            )
        )
    }
}

// MARK: - DependencyValues + SoloLogger

extension DependencyValues {
    /// A logger useful for logging messages.
    public var logger: Logger {
        get { observability.logger }
        set { observability.logger = newValue }
    }
}
