import Foundation

// MARK: - ConsoleLogHandler

public typealias ConsoleLogHandler = ConsoleEmissionHandler<Log, Log.Level>

extension ConsoleLogHandler: LogHandler {
    /// The level severity of logs that this handler should listen for.
    public var level: Log.Level {
        get { context }
        set { context = newValue }
    }

    /// Outputs a formatted representation of the provided event to the console.
    public func log(_ log: Log) {
        emit(log, prefix: "[\(log.level.rawValue.uppercased())]")
    }

    /// Creates a logging handler that outputs formatted logs to the console.
    ///
    /// - Parameters:
    ///   - level: The level severity of logs that this handler should listen for.
    ///   - dateFormatter: The formatter to use when formatting timestamps. If not provided
    ///     timestamps will be omitted.
    ///   - shouldOutputMetadata: Whether or not the output should include log metadata.
    ///   - metadataProvider: A provider that injects additional metadata into each log.
    public init<Provider: MetadataProvider>(
        level: Log.Level,
        dateFormatter: DateFormatter? = nil,
        shouldOutputMetadata: Bool = true,
        @MetadataProviderBuilder metadataProvider: () -> Provider = { EagerMetadataProvider([:]) }
    ) {
        self.init(
            context: level,
            dateFormatter: dateFormatter,
            shouldOutputMetadata: shouldOutputMetadata,
            metadataProvider: metadataProvider()
        )
    }
}
