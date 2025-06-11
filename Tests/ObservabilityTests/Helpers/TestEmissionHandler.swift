import Foundation
@testable import SoloObservability

/// An emission handler that outputs formatted logs to the console.
struct TestEmissionHandler<Emission: Sendable, Context: Sendable>: Sendable {

    // MARK: Properties

    /// The context for the emission handler.
    var context: Context

    /// The unique identifier for this handler.
    var id: UUID

    /// The historical context of the received logs.
    var history: History<Emission>

    /// The metadata that this handler should inject into logs.
    var metadataProvider: any MetadataProvider

    // MARK: Emission

    func emit(_ emission: Emission) {
        history.add(emission)
    }
}
