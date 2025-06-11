import Foundation

/// An emitter that emits emissions of a given type.
public struct Emitter<Handler: Sendable>: Sendable {

    // MARK: Properties

    /// The label identifying this emitter.
    public var label: String

    /// Metadata associated directly with this emitter.
    ///
    /// - Important: This metadata only encompasses the stored metadata directly attached to this tracker.
    ///   Any metadata to be added by metadata providers at the time an event  is emitted will be missing.
    public var metadata: Metadata

    /// The metadata provider this emitter will use when an emission is about to be emitted.
    ///
    /// A metadata provider allows the emitter to inject additional metadata when an emission is
    /// about to be emitted. The metadata provider could add constants to the metadata, use task-local
    /// values to add contextual metadata, or pull metadata from other sources just before the emissions
    /// is emitted.
    public var metadataProvider: any MetadataProvider

    /// The handlers that capture emissions from this emitter.
    public var handlers: [Handler]

    // MARK: Initializers

    init(
        label: String,
        metadata: Metadata = Metadata(),
        @MetadataProviderBuilder metadataProvider: () -> any MetadataProvider = { EagerMetadataProvider([:]) },
        @LogHandlerBuilder handlers: () -> [Handler] = { [] }
    ) where Handler == any LogHandler {
        self.label = label
        self.metadata = metadata
        self.metadataProvider = metadataProvider()
        self.handlers = handlers()
    }

    init(
        label: String,
        metadata: Metadata = Metadata(),
        @MetadataProviderBuilder metadataProvider: () -> any MetadataProvider = { EagerMetadataProvider([:]) },
        @EventHandlerBuilder handlers: () -> [Handler] = { [] }
    ) where Handler == any EventHandler {
        self.label = label
        self.metadata = metadata
        self.metadataProvider = metadataProvider()
        self.handlers = handlers()
    }

    // MARK: Subscripts

    /// Add, update and remove metadata associated with this emitter.
    ///
    /// - Important: This metadata only encompasses the stored metadata directly attached to this emitter.
    ///   Any metadata to be added by metadata provider at the time an event is emitted will not be included..
    public subscript(metadataKey metadataKey: String) -> MetadataValue? {
        get { metadata[metadataKey] }
        set { metadata[metadataKey] = newValue }
    }

    // MARK: Helpers

    /// Merges all the provided metadata.
    ///
    /// Conflicts are resolved by favoring values from parameters later in the parameter list.
    static func merging(
        emitterMetadata: Metadata,
        emitterMetadataProviderMetadata: Metadata,
        handlerMetadataProviderMetadata: Metadata,
        emissionMetadata: Metadata
    ) -> Metadata {
        emitterMetadata
            .merging(emitterMetadataProviderMetadata) { _, provider in provider }
            .merging(handlerMetadataProviderMetadata) { _, provider in provider }
            .merging(emissionMetadata) { _, emission in emission }
    }
}

// MARK: - Emitter + LogHandler

extension Emitter where Handler == any LogHandler {
    func emit(_ log: Log) {
        for handler in handlers {
            guard handler.level <= log.level else { continue }
            var copy = log
            copy.metadata = Self.merging(
                emitterMetadata: metadata,
                emitterMetadataProviderMetadata: metadataProvider.metadata,
                handlerMetadataProviderMetadata: handler.metadataProvider.metadata,
                emissionMetadata: log.metadata
            )

            handler.log(copy)
        }
    }
}

// MARK: - Emitter + EventHandler

extension Emitter where Handler == any EventHandler {
    func emit(_ event: Event) {
        for handler in handlers {
            var copy = event
            copy.metadata = Self.merging(
                emitterMetadata: metadata,
                emitterMetadataProviderMetadata: metadataProvider.metadata,
                handlerMetadataProviderMetadata: handler.metadataProvider.metadata,
                emissionMetadata: event.metadata
            )

            handler.track(copy)
        }
    }
}
