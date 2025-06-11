import Foundation

// MARK: - EventHandler

/// An `EventHandler` is responsible for capturing `Event` emissions from a `Tracker`
public protocol EventHandler: Sendable {
    /// The metadata provider for this event handler.
    var metadataProvider: any MetadataProvider { get }

    /// The track function allows the handler to capture incoming events.
    ///
    /// - Note: It is not necessary to add this handler's metadata provider's metadata  to
    ///   any received events as the tracker has already done so.
    @Sendable func track(_ event: Event)
}

extension EventHandler {
    var metadataProvider: any MetadataProvider {
        EagerMetadataProvider([:])
    }
}
