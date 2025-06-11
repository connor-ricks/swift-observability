import Foundation
@testable import SoloObservability
import Testing

@Suite("EventHandler Tests") struct EventHandlerTests {
    @Test func test_defaultMetadataProvider_isEmpty() {
        struct FooHandler: EventHandler {
            func track(_ event: Event) {}
        }

        #expect(FooHandler().metadataProvider.metadata.isEmpty)
    }

    @Test func test_builder_buildExpression() {
        let id = UUID()
        let component = EventHandlerBuilder.buildExpression(
            TestEventHandler(id: id)
        )

        switch component {
        case .element(let handler as TestEventHandler):
            #expect(handler.id == id)
        default:
            Issue.record("Incorrect component")
        }
    }

    @Test func test_builder_buildBlock() {
        let one = UUID()
        let two = UUID()
        let three = UUID()
        let component = EventHandlerBuilder.buildBlock(
            .array([TestEventHandler(id: one), TestEventHandler(id: two)]),
            .element(TestEventHandler(id: three)),
            .empty
        )

        switch component {
        case .array(let handlers):
            let ids = handlers.compactMap { ($0 as? TestEventHandler)?.id }
            #expect(ids == [one, two, three])
        default:
            Issue.record("Incorrect component")
        }
    }

    @Test func test_builder_buildArray() {
        let one = UUID()
        let two = UUID()
        let three = UUID()
        let component = EventHandlerBuilder.buildArray([
            .array([TestEventHandler(id: one), TestEventHandler(id: two)]),
            .element(TestEventHandler(id: three)),
            .empty,
        ])

        switch component {
        case .array(let handlers):
            let ids = handlers.compactMap { ($0 as? TestEventHandler)?.id }
            #expect(ids == [one, two, three])
        default:
            Issue.record("Incorrect component")
        }
    }

    @Test func test_builder_buildEitherFirst() {
        let id = UUID()
        let component = EventHandlerBuilder.buildEither(first: .element(TestEventHandler(id: id)))

        switch component {
        case .element(let handler as TestEventHandler):
            #expect(handler.id == id)
        default:
            Issue.record("Incorrect component")
        }
    }

    @Test func test_builder_buildEitherSecond() {
        let id = UUID()
        let component = EventHandlerBuilder.buildEither(second: .element(TestEventHandler(id: id)))

        switch component {
        case .element(let handler as TestEventHandler):
            #expect(handler.id == id)
        default:
            Issue.record("Incorrect component")
        }
    }

    @Test func test_builder_buildOptional() {
        let component1 = EventHandlerBuilder.buildOptional(nil)

        switch component1 {
        case .empty:
            break
        default:
            Issue.record("Incorrect component")
        }

        let id = UUID()
        let component2 = EventHandlerBuilder.buildOptional(.element(TestEventHandler(id: id)))

        switch component2 {
        case .element(let handler as TestEventHandler):
            #expect(handler.id == id)
        default:
            Issue.record("Incorrect component")
        }
    }

    @Test func test_builder_buildLimitedAvailability() {
        let id = UUID()
        let component = EventHandlerBuilder.buildLimitedAvailability(.element(TestEventHandler(id: id)))

        switch component {
        case .element(let handler as TestEventHandler):
            #expect(handler.id == id)
        default:
            Issue.record("Incorrect component")
        }
    }

    @Test func test_builder_buildFinalResult() {
        let id1 = UUID()
        let id2 = UUID()
        let handlers1 = EventHandlerBuilder.buildFinalResult(
            .array([
                TestEventHandler(id: id1),
                TestEventHandler(id: id2),
            ])
        )

        #expect(handlers1.count == 2)
        #expect((handlers1[0] as? TestEventHandler)?.id == id1)
        #expect((handlers1[1] as? TestEventHandler)?.id == id2)

        let id3 = UUID()
        let handlers2 = EventHandlerBuilder.buildFinalResult(
            .element(TestEventHandler(id: id3))
        )

        #expect(handlers2.count == 1)
        #expect((handlers2[0] as? TestEventHandler)?.id == id3)

        let handlers3 = EventHandlerBuilder.buildFinalResult(.empty)
        #expect(handlers3.isEmpty)
    }
}
