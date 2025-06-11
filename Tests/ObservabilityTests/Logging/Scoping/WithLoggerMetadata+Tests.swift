import Foundation
@testable import SoloObservability
import Testing

@Suite("WithLoggerMetadata Tests") struct WithLoggerMetadataTests {
    @Test func test_withLoggerMetadata_overridesLoggerMetadata() {
        withDependencies {
            $0.logger = Logger(label: "1", metadata: [
                "foo": "A",
                "bar": "B",
            ])
        } operation: {
            withLoggerMetadata([
                "foo": "overwritten",
                "baz": "C",
            ]) {
                @Dependency(\.logger) var logger
                #expect(logger.metadata == [
                    "foo": "overwritten",
                    "bar": "B",
                    "baz": "C",
                ])
            }

            @Dependency(\.logger) var logger
            #expect(logger.metadata == [
                "foo": "A",
                "bar": "B",
            ])
        }
    }

    @Test func test_withLoggerMetadata_combinePicksOld_overridesLoggerMetadata() {
        withDependencies {
            $0.logger = Logger(label: "1", metadata: [
                "foo": "A",
                "bar": "B",
            ])
        } operation: {
            withLoggerMetadata([
                "foo": "overwritten",
                "baz": "C",
            ]) { old, _ in
                old
            } operation: {
                @Dependency(\.logger) var logger
                #expect(logger.metadata == [
                    "foo": "A",
                    "bar": "B",
                    "baz": "C",
                ])
            }

            @Dependency(\.logger) var logger
            #expect(logger.metadata == [
                "foo": "A",
                "bar": "B",
            ])
        }
    }

    @Test func test_asyncWithLoggerMetadata_overridesLoggerMetadata() async {
        await withDependencies {
            $0.logger = Logger(label: "1", metadata: [
                "foo": "A",
                "bar": "B",
            ])
        } operation: {
            await withLoggerMetadata([
                "foo": "overwritten",
                "baz": "C",
            ]) {
                await Task {
                    @Dependency(\.logger) var logger
                    #expect(logger.metadata == [
                        "foo": "overwritten",
                        "bar": "B",
                        "baz": "C",
                    ])
                }.value
            }

            @Dependency(\.logger) var logger
            #expect(logger.metadata == [
                "foo": "A",
                "bar": "B",
            ])
        }
    }

    @Test func test_asyncWithLoggerMetadata_combinePicksOld_overridesLoggerMetadata() async {
        await withDependencies {
            $0.logger = Logger(label: "1", metadata: [
                "foo": "A",
                "bar": "B",
            ])
        } operation: {
            await withLoggerMetadata([
                "foo": "overwritten",
                "baz": "C",
            ]) { old, _ in
                old
            } operation: {
                await Task {
                    @Dependency(\.logger) var logger
                    #expect(logger.metadata == [
                        "foo": "A",
                        "bar": "B",
                        "baz": "C",
                    ])
                }.value
            }

            @Dependency(\.logger) var logger
            #expect(logger.metadata == [
                "foo": "A",
                "bar": "B",
            ])
        }
    }
}
