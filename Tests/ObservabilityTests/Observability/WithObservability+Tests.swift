import Foundation
@testable import Observability
import Testing

@Suite("WithObservability Tests") struct WithObservabilityTests {
    @Test func test_withObservability_overridesLogger() {
        withDependencies {
            $0.logger = Logger(label: "1", metadata: ["a": "A"])
            $0.tracker = Tracker(label: "3", metadata: ["c": "C"])
        } operation: {
            withObservability { observables in
                observables.logger.label = "2"
                observables.logger.metadata = ["b": "B"]
                observables.tracker.label = "4"
                observables.tracker.metadata = ["d": "D"]
            } operation: {
                @Dependency(\.observables) var observables
                #expect(observables.logger.label == "2")
                #expect(observables.logger.metadata == ["b": "B"])
                #expect(observables.tracker.label == "4")
                #expect(observables.tracker.metadata == ["d": "D"])
            }

            @Dependency(\.observables) var observables
            #expect(observables.logger.label == "1")
            #expect(observables.logger.metadata == ["a": "A"])
            #expect(observables.tracker.label == "3")
            #expect(observables.tracker.metadata == ["c": "C"])
        }
    }

    @Test func test_asyncWithLogger_overridesLogger() async {
        await withDependencies {
            $0.logger = Logger(label: "1", metadata: ["a": "A"])
            $0.tracker = Tracker(label: "3", metadata: ["c": "C"])
        } operation: {
            await withObservability { observables in
                observables.logger.label = "2"
                observables.logger.metadata = ["b": "B"]
                observables.tracker.label = "4"
                observables.tracker.metadata = ["d": "D"]
            } operation: {
                await Task {
                    @Dependency(\.observables) var observables
                    #expect(observables.logger.label == "2")
                    #expect(observables.logger.metadata == ["b": "B"])
                    #expect(observables.tracker.label == "4")
                    #expect(observables.tracker.metadata == ["d": "D"])
                }.value
            }

            @Dependency(\.observables) var observables
            #expect(observables.logger.label == "1")
            #expect(observables.logger.metadata == ["a": "A"])
            #expect(observables.tracker.label == "3")
            #expect(observables.tracker.metadata == ["c": "C"])
        }
    }
}
