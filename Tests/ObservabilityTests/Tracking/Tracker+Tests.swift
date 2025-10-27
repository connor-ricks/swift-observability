import Foundation
@testable import Observability
import Testing

@Suite("Tracker Tests") struct TrackerTests {
    @Test func test_metadataOperations() {
        var tracker1 = Tracker(label: "tracker", metadata: ["foo": "1"])

        /// Test tracker's initial metadata
        #expect(tracker1.metadata == ["foo": "1"])

        /// Test updating tracker's metadata
        tracker1.metadata = ["bar": "2"]
        #expect(tracker1.metadata == ["bar": "2"])

        /// Test updating metadata via subscript
        tracker1[metadataKey: "baz"] = "3"
        #expect(tracker1.metadata == ["bar": "2", "baz": "3"])

        /// Test getting metadata via subscript
        #expect(tracker1[metadataKey: "bar"] == "2")

        /// Test making a copy of tracker copies storage.
        var tracker2 = tracker1
        tracker2[metadataKey: "qux"] = "4"
        #expect(tracker2.metadata == ["bar": "2", "baz": "3", "qux": "4"])
        #expect(tracker1.metadata == ["bar": "2", "baz": "3"])
    }

    @Test func test_track_buildsEventWithProvidedPrameters() {
        let history = History<Event>()
        let tracker = Tracker(label: "test", handlers: {
            TestEventHandler(history: history)
        })

        tracker.track("Track", metadata: ["foo": "bar"])

        #expect(history.events.count == 1)
        #expect(history.events[0].name == "Track")
        #expect(history.events[0].metadata["foo"] == "bar")
    }

    @Test func test_track_buildsMetadataWithCorrectOrdering() {
        let history1 = History<Event>()
        let history2 = History<Event>()
        let tracker = Tracker(
            label: "tracker",
            metadata: [
                "tracker-metadata": "A",
                "foo": "A",
            ]
        ) {
            [
                "tracker-metadata-provider": "A",
                "foo": "B",
                "bar": "A",
            ]
        } handlers: {
            TestEventHandler(history: history1) {
                [
                    "handler-1": "A",
                    "bar": "B",
                    "baz": "A",
                ]
            }
            TestEventHandler(history: history2) {
                [
                    "handler-2": "A",
                    "bar": "B",
                    "baz": "A",
                ]
            }
        }

        tracker.track("Track", metadata: [
            "track": "A",
            "baz": "B",
        ])

        #expect(history1.events.count == 1)
        #expect(history1.events[0].metadata == [
            "tracker-metadata": "A",
            "tracker-metadata-provider": "A",
            "handler-1": "A",
            "track": "A",
            "foo": "B", // Overwritten by tracker metadata provider
            "bar": "B", // Overwritten by handler metadata provider
            "baz": "B", // Overwritten by track metadata
        ])

        #expect(history2.events.count == 1)
    }
}
