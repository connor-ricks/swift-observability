public import Foundation

public typealias ConsoleEventHandler = ConsoleEmissionHandler<Event, Void>

extension ConsoleEventHandler: EventHandler {
    /// Outputs a formatted representation of the provided event to the console.
    public func track(_ event: Event) {
        emit(event, prefix: "[EVENT]")
    }

    /// Creates an event handler that outputs formatted events to the console.
    ///
    /// - Parameters:
    ///   - dateFormatter: The formatter to use when formatting timestamps. If not provided
    ///     timestamps will be omitted.
    ///   - shouldOutputMetadata: Whether or not the output should include log metadata.
    ///   - metadataProvider: A provider that injects additional metadata into each log.
    public init(
        dateFormatter: DateFormatter? = nil,
        shouldOutputMetadata: Bool = true,
        @MetadataProviderBuilder metadataProvider: () -> some MetadataProvider = { EagerMetadataProvider([:]) }
    ) {
        self.init(
            context: (),
            dateFormatter: dateFormatter,
            shouldOutputMetadata: shouldOutputMetadata,
            metadataProvider: metadataProvider()
        )
    }
}
