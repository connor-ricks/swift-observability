import Foundation
@testable import SoloObservability
import Testing

@Suite("WithLogHandlers Tests") struct WithLogHandlersTests {
    @Test func test_withLogHandlers_mergesHandlers() {
        let id1 = UUID()
        let id2 = UUID()

        withDependencies {
            $0.logger = Logger(
                label: "label",
                handlers: {
                    TestLogHandler(id: id1)
                }
            )
        } operation: {
            withLogHandlers {
                TestLogHandler(id: id2)
            } operation: {
                /// Log handlers have additional handlers.
                @Dependency(\.logger) var logger1
                #expect(logger1.handlers.compactMap {
                    ($0 as? TestLogHandler)?.id
                } == [id1, id2])
            }

            /// Log handlers should reset back to default.
            @Dependency(\.logger) var logger2
            #expect(logger2.handlers.compactMap {
                ($0 as? TestLogHandler)?.id
            } == [id1])
        }
    }

    @Test func test_withLogHandlers_shouldReplaceHandlers_setsHandlers() {
        let id1 = UUID()
        let id2 = UUID()

        withDependencies {
            $0.logger = Logger(
                label: "label",
                handlers: {
                    TestLogHandler(id: id1)
                }
            )
        } operation: {
            withLogHandlers(shouldReplaceExistingHandlers: true) {
                TestLogHandler(id: id2)
            } operation: {
                /// Log handlers have additional handlers.
                @Dependency(\.logger) var logger1
                #expect(logger1.handlers.compactMap {
                    ($0 as? TestLogHandler)?.id
                } == [id2])
            }

            /// Log handlers should reset back to default.
            @Dependency(\.logger) var logger2
            #expect(logger2.handlers.compactMap {
                ($0 as? TestLogHandler)?.id
            } == [id1])
        }
    }

    @Test func test_asyncwithLogHandlers_mergesHandlers() async {
        let id1 = UUID()
        let id2 = UUID()

        await withDependencies {
            $0.logger = Logger(
                label: "label",
                handlers: {
                    TestLogHandler(id: id1)
                }
            )
        } operation: {
            await withLogHandlers {
                TestLogHandler(id: id2)
            } operation: {
                await Task {
                    /// Log handlers have additional handlers.
                    @Dependency(\.logger) var logger1
                    #expect(logger1.handlers.compactMap {
                        ($0 as? TestLogHandler)?.id
                    } == [id1, id2])
                }.value
            }

            /// Log handlers should reset back to default.
            @Dependency(\.logger) var logger2
            #expect(logger2.handlers.compactMap {
                ($0 as? TestLogHandler)?.id
            } == [id1])
        }
    }

    @Test func test_asyncwithLogHandlers_shouldReplaceHandlers_setsHandlers() async {
        let id1 = UUID()
        let id2 = UUID()

        await withDependencies {
            $0.logger = Logger(
                label: "label",
                handlers: {
                    TestLogHandler(id: id1)
                }
            )
        } operation: {
            await withLogHandlers(shouldReplaceExistingHandlers: true) {
                TestLogHandler(id: id2)
            } operation: {
                await Task {
                    /// Log handlers have additional handlers.
                    @Dependency(\.logger) var logger1
                    #expect(logger1.handlers.compactMap {
                        ($0 as? TestLogHandler)?.id
                    } == [id2])
                }.value
            }

            /// Log handlers should reset back to default.
            @Dependency(\.logger) var logger2
            #expect(logger2.handlers.compactMap {
                ($0 as? TestLogHandler)?.id
            } == [id1])
        }
    }
}
