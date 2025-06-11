import Foundation
@testable import SoloObservability
import Testing

@Suite("ConsoleLogHandler Tests") struct ConsoleLogHandlerTests {
    @Test(arguments: Log.Level.allCases)
    func test_handler_withMetadata_matchesFormat(level: Log.Level) async {
        await withDependencies {
            var components = DateComponents()
            components.year = 2_025
            components.month = 1
            components.day = 1
            $0.date = .constant(Calendar.current.date(from: components)!)
        } operation: {
            await confirmation("Expected block to be called once.", expectedCount: 1) { confirmation in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                var handler = ConsoleLogHandler(
                    level: .critical,
                    dateFormatter: dateFormatter,
                    shouldOutputMetadata: true,
                    metadataProvider: {
                        ["handler": "metadata"]
                    }
                )

                /// Validating the get/set operation works on emitter.
                handler.level = .trace
                #expect(handler.level == .trace)

                // swiftlint:disable indentation_width
                handler.print = { @Sendable log in
                    confirmation()
                    #expect(log == """
                    [\(level.rawValue.uppercased())] 2025-01-01 00:00:00 com.solo.observability.logger.tests (Log 1) metadata: {
                      "handler" : "metadata",
                      "log" : "metadata"
                    }
                    """)
                }
                // swiftlint:enable indentation_width

                withLogHandlers(shouldReplaceExistingHandlers: false) {
                    handler
                } operation: {
                    @Dependency(\.logger) var logger
                    logger.log(level, "Log 1", metadata: ["log": "metadata"])
                }
            }
        }
    }

    @Test(arguments: Log.Level.allCases)
    func test_handler_withMetadataWhenShouldOutputMetadataIsFalse_matchesFormat(level: Log.Level) async {
        await withDependencies {
            var components = DateComponents()
            components.year = 2_025
            components.month = 1
            components.day = 1
            $0.date = .constant(Calendar.current.date(from: components)!)
        } operation: {
            await confirmation("Expected block to be called once.", expectedCount: 1) { confirmation in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                var handler = ConsoleLogHandler(
                    level: .trace,
                    dateFormatter: dateFormatter,
                    shouldOutputMetadata: false,
                    metadataProvider: {
                        ["handler": "metadata"]
                    }
                )

                handler.print = { @Sendable log in
                    confirmation()
                    #expect(log == "[\(level.rawValue.uppercased())] 2025-01-01 00:00:00 com.solo.observability.logger.tests (Log 1)")
                }

                withLogHandlers(shouldReplaceExistingHandlers: true) {
                    handler
                } operation: {
                    @Dependency(\.logger) var logger
                    logger.log(level, "Log 1", metadata: ["log": "metadata"])
                }
            }
        }
    }

    @Test(arguments: Log.Level.allCases)
    func test_handler_withoutMetadata_matchesFormat(level: Log.Level) async {
        await withDependencies {
            var components = DateComponents()
            components.year = 2_025
            components.month = 1
            components.day = 1
            $0.date = .constant(Calendar.current.date(from: components)!)
        } operation: {
            await confirmation("Expected block to be called once.", expectedCount: 1) { confirmation in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                var handler = ConsoleLogHandler(
                    level: .trace,
                    dateFormatter: dateFormatter
                )

                handler.print = { @Sendable log in
                    confirmation()
                    #expect(log == """
                [\(level.rawValue.uppercased())] 2025-01-01 00:00:00 com.solo.observability.logger.tests (Log 1)
                """)
                }

                withLogHandlers(shouldReplaceExistingHandlers: true) {
                    handler
                } operation: {
                    @Dependency(\.logger) var logger
                    logger.log(level, "Log 1")
                }
            }
        }
    }
}
