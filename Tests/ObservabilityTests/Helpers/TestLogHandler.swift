import Foundation
@testable import SoloObservability

typealias TestLogHandler = TestEmissionHandler<Log, Log.Level>

extension TestLogHandler: LogHandler {
    var level: SoloObservability.Log.Level {
        get { context }
        set { context = newValue }
    }

    func log(_ log: Log) {
        emit(log)
    }

    init(
        id: UUID = UUID(),
        level: Log.Level = .trace,
        history: History<Emission> = History(),
        @MetadataProviderBuilder metadataProvider: () -> some MetadataProvider = { EagerMetadataProvider([:]) }
    ) {
        self.id = id
        self.history = history
        self.context = level
        self.metadataProvider = metadataProvider()
    }
}
