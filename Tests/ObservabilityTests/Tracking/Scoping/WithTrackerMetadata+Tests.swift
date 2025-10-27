import Foundation
@testable import Observability
import Testing

@Suite("WithTrackerMetadata Tests") struct WithTrackerMetadataTests {
    @Test func test_withTrackerMetadata_overridesTrackerMetadata() {
        withDependencies {
            $0.tracker = Tracker(label: "1", metadata: [
                "foo": "A",
                "bar": "B",
            ])
        } operation: {
            withTrackerMetadata([
                "foo": "overwritten",
                "baz": "C",
            ]) {
                @Dependency(\.tracker) var tracker
                #expect(tracker.metadata == [
                    "foo": "overwritten",
                    "bar": "B",
                    "baz": "C",
                ])
            }

            @Dependency(\.tracker) var tracker
            #expect(tracker.metadata == [
                "foo": "A",
                "bar": "B",
            ])
        }
    }

    @Test func test_withTrackerMetadata_combinePicksOld_overridesTrackerMetadata() {
        withDependencies {
            $0.tracker = Tracker(label: "1", metadata: [
                "foo": "A",
                "bar": "B",
            ])
        } operation: {
            withTrackerMetadata([
                "foo": "overwritten",
                "baz": "C",
            ]) { old, _ in
                old
            } operation: {
                @Dependency(\.tracker) var tracker
                #expect(tracker.metadata == [
                    "foo": "A",
                    "bar": "B",
                    "baz": "C",
                ])
            }

            @Dependency(\.tracker) var tracker
            #expect(tracker.metadata == [
                "foo": "A",
                "bar": "B",
            ])
        }
    }

    @Test func test_asyncWithTrackerMetadata_overridesTrackerMetadata() async {
        await withDependencies {
            $0.tracker = Tracker(label: "1", metadata: [
                "foo": "A",
                "bar": "B",
            ])
        } operation: {
            await withTrackerMetadata([
                "foo": "overwritten",
                "baz": "C",
            ]) {
                await Task {
                    @Dependency(\.tracker) var tracker
                    #expect(tracker.metadata == [
                        "foo": "overwritten",
                        "bar": "B",
                        "baz": "C",
                    ])
                }.value
            }

            @Dependency(\.tracker) var tracker
            #expect(tracker.metadata == [
                "foo": "A",
                "bar": "B",
            ])
        }
    }

    @Test func test_asyncWithTrackerMetadata_combinePicksOld_overridesTrackerMetadata() async {
        await withDependencies {
            $0.tracker = Tracker(label: "1", metadata: [
                "foo": "A",
                "bar": "B",
            ])
        } operation: {
            await withTrackerMetadata([
                "foo": "overwritten",
                "baz": "C",
            ]) { old, _ in
                old
            } operation: {
                await Task {
                    @Dependency(\.tracker) var tracker
                    #expect(tracker.metadata == [
                        "foo": "A",
                        "bar": "B",
                        "baz": "C",
                    ])
                }.value
            }

            @Dependency(\.tracker) var tracker
            #expect(tracker.metadata == [
                "foo": "A",
                "bar": "B",
            ])
        }
    }
}
