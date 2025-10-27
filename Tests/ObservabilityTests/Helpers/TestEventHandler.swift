import Foundation
@testable import Observability

typealias TestEventHandler = TestEmissionHandler<Event, Void>

extension TestEventHandler: EventHandler {
    func track(_ event: Event) {
        emit(event)
    }

    init(
        id: UUID = UUID(),
        history: History<Emission> = History(),
        @MetadataProviderBuilder metadataProvider: () -> some MetadataProvider = { EagerMetadataProvider([:]) }
    ) {
        self.id = id
        self.history = history
        self.context = ()
        self.metadataProvider = metadataProvider()
    }
}
