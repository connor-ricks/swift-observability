import Foundation
@testable import Observability
import Testing

@Suite("WithLogLevel Tests") struct WithLogLevelTests {
    @Test func test_withLogLevel_overridesLogHandler() {
        let history = History<Log>()

        withDependencies {
            $0.logger = Logger(
                label: "label",
                handlers: {
                    TestLogHandler(
                        level: .debug,
                        history: history
                    )
                }
            )
        } operation: {
            /// Logging level should be overridden for the duration of the block
            withLogLevel(.critical) {
                @Dependency(\.logger) var logger1
                for handler in logger1.handlers {
                    #expect(handler.level == .critical)
                }

                /// Logging a critical should succeed.
                logger1.log(.critical, "Log 1")
                /// Logging a warning should be ignored due to critical level.
                logger1.log(.warning, "Log 2")
                #expect(history.logs.count == 1)
                #expect(history.logs[0].message == "Log 1")
            }

            /// Logging level should return to debug after the operation.
            @Dependency(\.logger) var logger2
            for handler in logger2.handlers {
                #expect(handler.level == .debug)
            }

            /// logging a debug should succeed since level is reset back to debug.
            logger2.log(.debug, "Log 3")
            #expect(history.logs.count == 2)
            #expect(history.logs[0].message == "Log 1")
            #expect(history.logs[1].message == "Log 3")
        }
    }

    @Test func test_asyncWithLogLevel_overridesLogHandler() async {
        let history = History<Log>()

        await withDependencies {
            $0.logger = Logger(
                label: "label",
                handlers: {
                    TestLogHandler(
                        level: .debug,
                        history: history
                    )
                }
            )
        } operation: {
            /// Logging level should be overridden for the duration of the block
            await withLogLevel(.critical) {
                @Dependency(\.logger) var logger1
                for handler in logger1.handlers {
                    #expect(handler.level == .critical)
                }

                /// Logging a critical should succeed.
                logger1.log(.critical, "Log 1")
                let task = Task {
                    @Dependency(\.logger) var logger2
                    /// Logging a warning should be ignored due to critical level.
                    logger2.log(.warning, "Log 2")
                    /// Logging a critical should succeed.
                    logger2.log(.critical, "Log 3")
                }

                await task.value
                #expect(history.logs.count == 2)
                #expect(history.logs[0].message == "Log 1")
                #expect(history.logs[1].message == "Log 3")
            }

            /// Logging level should return to debug after the operation.
            @Dependency(\.logger) var logger3
            for handler in logger3.handlers {
                #expect(handler.level == .debug)
            }

            /// Logging a debug should succeed since level is reset back to debug.
            logger3.log(.debug, "Log 4")
            #expect(history.logs.count == 3)
            #expect(history.logs[0].message == "Log 1")
            #expect(history.logs[1].message == "Log 3")
            #expect(history.logs[2].message == "Log 4")
        }
    }
}
