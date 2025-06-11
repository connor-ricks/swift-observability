import Foundation
@testable import SoloObservability
import Testing

@Suite("WithObservability Tests") struct WithObservabilityTests {
    @Test func test_withObservability_overridesLogger() {
        withDependencies {
            $0.logger = Logger(label: "1", metadata: ["a": "A"])
            $0.tracker = Tracker(label: "3", metadata: ["c": "C"])
        } operation: {
            withObservability { observability in
                observability.logger.label = "2"
                observability.logger.metadata = ["b": "B"]
                observability.tracker.label = "4"
                observability.tracker.metadata = ["d": "D"]
            } operation: {
                @Dependency(\.observability) var observability
                #expect(observability.logger.label == "2")
                #expect(observability.logger.metadata == ["b": "B"])
                #expect(observability.tracker.label == "4")
                #expect(observability.tracker.metadata == ["d": "D"])
            }

            @Dependency(\.observability) var observability
            #expect(observability.logger.label == "1")
            #expect(observability.logger.metadata == ["a": "A"])
            #expect(observability.tracker.label == "3")
            #expect(observability.tracker.metadata == ["c": "C"])
        }
    }

    @Test func test_asyncWithLogger_overridesLogger() async {
        await withDependencies {
            $0.logger = Logger(label: "1", metadata: ["a": "A"])
            $0.tracker = Tracker(label: "3", metadata: ["c": "C"])
        } operation: {
            await withObservability { observability in
                observability.logger.label = "2"
                observability.logger.metadata = ["b": "B"]
                observability.tracker.label = "4"
                observability.tracker.metadata = ["d": "D"]
            } operation: {
                await Task {
                    @Dependency(\.observability) var observability
                    #expect(observability.logger.label == "2")
                    #expect(observability.logger.metadata == ["b": "B"])
                    #expect(observability.tracker.label == "4")
                    #expect(observability.tracker.metadata == ["d": "D"])
                }.value
            }

            @Dependency(\.observability) var observability
            #expect(observability.logger.label == "1")
            #expect(observability.logger.metadata == ["a": "A"])
            #expect(observability.tracker.label == "3")
            #expect(observability.tracker.metadata == ["c": "C"])
        }
    }
}
