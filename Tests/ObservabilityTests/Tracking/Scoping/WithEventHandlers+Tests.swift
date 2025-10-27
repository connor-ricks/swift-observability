import Foundation
@testable import Observability
import Testing

@Suite("WithEventHandlers Tests") struct WithEventHandlersTests {
    @Test func test_withEventHandlers_mergesHandlers() {
        let id1 = UUID()
        let id2 = UUID()

        withDependencies {
            $0.tracker = Tracker(
                label: "label",
                handlers: {
                    TestEventHandler(id: id1)
                }
            )
        } operation: {
            withEventHandlers {
                TestEventHandler(id: id2)
            } operation: {
                /// Event handlers have additional handlers.
                @Dependency(\.tracker) var tracker1
                #expect(tracker1.handlers.compactMap {
                    ($0 as? TestEventHandler)?.id
                } == [id1, id2])
            }

            /// Event handlers should reset back to default.
            @Dependency(\.tracker) var tracker2
            #expect(tracker2.handlers.compactMap {
                ($0 as? TestEventHandler)?.id
            } == [id1])
        }
    }

    @Test func test_withEventHandlers_shouldReplaceHandlers_setsHandlers() {
        let id1 = UUID()
        let id2 = UUID()

        withDependencies {
            $0.tracker = Tracker(
                label: "label",
                handlers: {
                    TestEventHandler(id: id1)
                }
            )
        } operation: {
            withEventHandlers(shouldReplaceExistingHandlers: true) {
                TestEventHandler(id: id2)
            } operation: {
                /// Event handlers have additional handlers.
                @Dependency(\.tracker) var tracker1
                #expect(tracker1.handlers.compactMap {
                    ($0 as? TestEventHandler)?.id
                } == [id2])
            }

            /// Event handlers should reset back to default.
            @Dependency(\.tracker) var tracker2
            #expect(tracker2.handlers.compactMap {
                ($0 as? TestEventHandler)?.id
            } == [id1])
        }
    }

    @Test func test_asyncwithEventHandlers_mergesHandlers() async {
        let id1 = UUID()
        let id2 = UUID()

        await withDependencies {
            $0.tracker = Tracker(
                label: "label",
                handlers: {
                    TestEventHandler(id: id1)
                }
            )
        } operation: {
            await withEventHandlers {
                TestEventHandler(id: id2)
            } operation: {
                await Task {
                    /// Event handlers have additional handlers.
                    @Dependency(\.tracker) var tracker1
                    #expect(tracker1.handlers.compactMap {
                        ($0 as? TestEventHandler)?.id
                    } == [id1, id2])
                }.value
            }

            /// Event handlers should reset back to default.
            @Dependency(\.tracker) var tracker2
            #expect(tracker2.handlers.compactMap {
                ($0 as? TestEventHandler)?.id
            } == [id1])
        }
    }

    @Test func test_asyncwithEventHandlers_shouldReplaceHandlers_setsHandlers() async {
        let id1 = UUID()
        let id2 = UUID()

        await withDependencies {
            $0.tracker = Tracker(
                label: "label",
                handlers: {
                    TestEventHandler(id: id1)
                }
            )
        } operation: {
            await withEventHandlers(shouldReplaceExistingHandlers: true) {
                TestEventHandler(id: id2)
            } operation: {
                await Task {
                    /// Event handlers have additional handlers.
                    @Dependency(\.tracker) var tracker1
                    #expect(tracker1.handlers.compactMap {
                        ($0 as? TestEventHandler)?.id
                    } == [id2])
                }.value
            }

            /// Event handlers should reset back to default.
            @Dependency(\.tracker) var tracker2
            #expect(tracker2.handlers.compactMap {
                ($0 as? TestEventHandler)?.id
            } == [id1])
        }
    }
}
