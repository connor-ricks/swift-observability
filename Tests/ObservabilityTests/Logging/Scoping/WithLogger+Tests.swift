import Foundation
@testable import SoloObservability
import Testing

@Suite("WithLogger Tests") struct WithLoggerTests {
    @Test func test_withLogger_overridesLogger() {
        withDependencies {
            $0.logger = Logger(label: "1", metadata: ["a": "A"])
        } operation: {
            withLogger { logger in
                logger.label = "2"
                logger.metadata = ["b": "B"]
            } operation: {
                @Dependency(\.logger) var logger
                #expect(logger.label == "2")
                #expect(logger.metadata == ["b": "B"])
            }
        }
    }

    @Test func test_asyncWithLogger_overridesLogger() async {
        await withDependencies {
            $0.logger = Logger(label: "1", metadata: ["a": "A"])
        } operation: {
            await withLogger { logger in
                logger.label = "2"
                logger.metadata = ["b": "B"]
            } operation: {
                await Task {
                    @Dependency(\.logger) var logger
                    #expect(logger.label == "2")
                    #expect(logger.metadata == ["b": "B"])
                }.value
            }
        }
    }
}
