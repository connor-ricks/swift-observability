import Foundation

/// A `LogHandler` is responsible for capturing `Log` emissions from a `Logger`
public protocol LogHandler: Sendable {
    /// The log level that this handler wants to observe.
    ///
    /// - Note: It is not necessary to check the log level of the received log
    ///   as the logger has already done so.
    var level: Log.Level { get set }

    /// The metadata provider for this log handler.
    var metadataProvider: any MetadataProvider { get }

    /// The log function allows the handler to capture incoming logs.
    ///
    /// - Note: It is not necessary to add this handler's metadata provider's metadata  to
    ///   any received logs as the tracker has already done so.
    @Sendable func log(_ log: Log)
}

extension LogHandler {
    var metadataProvider: any MetadataProvider {
        EagerMetadataProvider([:])
    }
}
