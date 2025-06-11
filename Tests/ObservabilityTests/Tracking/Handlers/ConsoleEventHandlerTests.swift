import Foundation
@testable import SoloObservability
import Testing

@Suite("ConsoleEventHandler Tests") struct ConsoleEventHandlerTests {
    @Test func test_handler_withMetadata_matchesFormat() async {
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
                var handler = ConsoleEventHandler(
                    dateFormatter: dateFormatter,
                    shouldOutputMetadata: true,
                    metadataProvider: {
                        ["handler": "metadata"]
                    }
                )

                // swiftlint:disable indentation_width
                handler.print = { @Sendable event in
                    confirmation()
                    #expect(event == """
                    [EVENT] 2025-01-01 00:00:00 com.solo.observability.tracker.tests (Event 1) metadata: {
                      "event" : "metadata",
                      "handler" : "metadata"
                    }
                    """)
                }
                // swiftlint:enable indentation_width

                withEventHandlers(shouldReplaceExistingHandlers: false) {
                    handler
                } operation: {
                    @Dependency(\.tracker) var tracker
                    tracker.track("Event 1", metadata: ["event": "metadata"])
                }
            }
        }
    }

    @Test func test_handler_withMetadataWhenShouldOutputMetadataIsFalse_matchesFormat() async {
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
                var handler = ConsoleEventHandler(
                    dateFormatter: dateFormatter,
                    shouldOutputMetadata: false,
                    metadataProvider: {
                        ["handler": "metadata"]
                    }
                )

                handler.print = { @Sendable event in
                    confirmation()
                    #expect(event == "[EVENT] 2025-01-01 00:00:00 com.solo.observability.tracker.tests (Event 1)")
                }

                withEventHandlers(shouldReplaceExistingHandlers: true) {
                    handler
                } operation: {
                    @Dependency(\.tracker) var tracker
                    tracker.track("Event 1", metadata: ["track": "metadata"])
                }
            }
        }
    }

    @Test func test_handler_withoutMetadata_matchesFormat() async {
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
                var handler = ConsoleEventHandler(
                    dateFormatter: dateFormatter
                )

                handler.print = { @Sendable event in
                    confirmation()
                    #expect(event == """
                [EVENT] 2025-01-01 00:00:00 com.solo.observability.tracker.tests (Event 1)
                """)
                }

                withEventHandlers(shouldReplaceExistingHandlers: true) {
                    handler
                } operation: {
                    @Dependency(\.tracker) var tracker
                    tracker.track("Event 1")
                }
            }
        }
    }
}
