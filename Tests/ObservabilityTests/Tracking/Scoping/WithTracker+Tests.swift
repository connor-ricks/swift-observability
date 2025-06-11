import Foundation
@testable import SoloObservability
import Testing

@Suite("WithTracker Tests") struct WithTrackerTests {
    @Test func test_withTracker_overridesTracker() {
        withDependencies {
            $0.tracker = Tracker(label: "1", metadata: ["a": "A"])
        } operation: {
            withTracker { tracker in
                tracker.label = "2"
                tracker.metadata = ["b": "B"]
            } operation: {
                @Dependency(\.tracker) var tracker
                #expect(tracker.label == "2")
                #expect(tracker.metadata == ["b": "B"])
            }
        }
    }

    @Test func test_asyncWithTracker_overridesTracker() async {
        await withDependencies {
            $0.tracker = Tracker(label: "1", metadata: ["a": "A"])
        } operation: {
            await withTracker { tracker in
                tracker.label = "2"
                tracker.metadata = ["b": "B"]
            } operation: {
                await Task {
                    @Dependency(\.tracker) var tracker
                    #expect(tracker.label == "2")
                    #expect(tracker.metadata == ["b": "B"])
                }.value
            }
        }
    }
}
