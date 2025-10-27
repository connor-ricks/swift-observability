import Foundation
@testable import Observability
import Testing

@Suite("LogHandler Tests") struct LogHandlerTests {
    @Test func test_defaultMetadataProvider_isEmpty() {
        struct FooHandler: LogHandler {
            var level: Log.Level = .critical
            func log(_ log: Log) {}
        }

        #expect(FooHandler().metadataProvider.metadata.isEmpty)
    }

    @Test func test_builder_buildExpression() {
        let id = UUID()
        let component = LogHandlerBuilder.buildExpression(
            TestLogHandler(id: id)
        )

        switch component {
        case .element(let handler as TestLogHandler):
            #expect(handler.id == id)
        default:
            Issue.record("Incorrect component")
        }
    }

    @Test func test_builder_buildBlock() {
        let one = UUID()
        let two = UUID()
        let three = UUID()
        let component = LogHandlerBuilder.buildBlock(
            .array([TestLogHandler(id: one), TestLogHandler(id: two)]),
            .element(TestLogHandler(id: three)),
            .empty
        )

        switch component {
        case .array(let handlers):
            let ids = handlers.compactMap { ($0 as? TestLogHandler)?.id }
            #expect(ids == [one, two, three])
        default:
            Issue.record("Incorrect component")
        }
    }

    @Test func test_builder_buildArray() {
        let one = UUID()
        let two = UUID()
        let three = UUID()
        let component = LogHandlerBuilder.buildArray([
            .array([TestLogHandler(id: one), TestLogHandler(id: two)]),
            .element(TestLogHandler(id: three)),
            .empty,
        ])

        switch component {
        case .array(let handlers):
            let ids = handlers.compactMap { ($0 as? TestLogHandler)?.id }
            #expect(ids == [one, two, three])
        default:
            Issue.record("Incorrect component")
        }
    }

    @Test func test_builder_buildEitherFirst() {
        let id = UUID()
        let component = LogHandlerBuilder.buildEither(first: .element(TestLogHandler(id: id)))

        switch component {
        case .element(let handler as TestLogHandler):
            #expect(handler.id == id)
        default:
            Issue.record("Incorrect component")
        }
    }

    @Test func test_builder_buildEitherSecond() {
        let id = UUID()
        let component = LogHandlerBuilder.buildEither(second: .element(TestLogHandler(id: id)))

        switch component {
        case .element(let handler as TestLogHandler):
            #expect(handler.id == id)
        default:
            Issue.record("Incorrect component")
        }
    }

    @Test func test_builder_buildOptional() {
        let component1 = LogHandlerBuilder.buildOptional(nil)

        switch component1 {
        case .empty:
            break
        default:
            Issue.record("Incorrect component")
        }

        let id = UUID()
        let component2 = LogHandlerBuilder.buildOptional(.element(TestLogHandler(id: id)))

        switch component2 {
        case .element(let handler as TestLogHandler):
            #expect(handler.id == id)
        default:
            Issue.record("Incorrect component")
        }
    }

    @Test func test_builder_buildLimitedAvailability() {
        let id = UUID()
        let component = LogHandlerBuilder.buildLimitedAvailability(.element(TestLogHandler(id: id)))

        switch component {
        case .element(let handler as TestLogHandler):
            #expect(handler.id == id)
        default:
            Issue.record("Incorrect component")
        }
    }

    @Test func test_builder_buildFinalResult() {
        let id1 = UUID()
        let id2 = UUID()
        let handlers1 = LogHandlerBuilder.buildFinalResult(
            .array([
                TestLogHandler(id: id1),
                TestLogHandler(id: id2),
            ])
        )

        #expect(handlers1.count == 2)
        #expect((handlers1[0] as? TestLogHandler)?.id == id1)
        #expect((handlers1[1] as? TestLogHandler)?.id == id2)

        let id3 = UUID()
        let handlers2 = LogHandlerBuilder.buildFinalResult(
            .element(TestLogHandler(id: id3))
        )

        #expect(handlers2.count == 1)
        #expect((handlers2[0] as? TestLogHandler)?.id == id3)

        let handlers3 = LogHandlerBuilder.buildFinalResult(.empty)
        #expect(handlers3.isEmpty)
    }
}
