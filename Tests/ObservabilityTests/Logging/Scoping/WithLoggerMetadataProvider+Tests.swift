import Foundation
@testable import SoloObservability
import Testing

@Suite("WithLoggerMetadataProvider Tests") struct WithLoggerMetadataProviderTests {
    @Test func test_withLoggerMetadataProvider_mergesMetadata() {
        withDependencies {
            $0.logger = Logger(
                label: "label",
                metadataProvider: {
                    [
                        "logger-metadata-provider": "metadata",
                        "foo": "bar",
                    ]
                },
                handlers: {}
            )
        } operation: {
            withLoggerMetadataProvider {
                [
                    "with-logging-metadata-provider": "metadata",
                    "foo": "baz",
                ]
            } operation: {
                /// Expect additional metadata to be added/overwritten.
                @Dependency(\.logger) var logger1
                #expect(logger1.metadataProvider.metadata == [
                    "logger-metadata-provider": "metadata",
                    "with-logging-metadata-provider": "metadata",
                    "foo": "baz",
                ])
            }

            @Dependency(\.logger) var logger2
            #expect(logger2.metadataProvider.metadata == [
                "logger-metadata-provider": "metadata",
                "foo": "bar",
            ])
        }
    }

    @Test func test_withLoggerMetadataProviderAndNoInitialMetadata_mergesMetadata() {
        withDependencies {
            $0.logger = Logger(
                label: "label",
                handlers: {}
            )
        } operation: {
            withLoggerMetadataProvider {
                [
                    "with-logging-metadata-provider": "metadata",
                    "foo": "baz",
                ]
            } operation: {
                /// Expect additional metadata to be added/overwritten.
                @Dependency(\.logger) var logger1
                #expect(logger1.metadataProvider.metadata == [
                    "with-logging-metadata-provider": "metadata",
                    "foo": "baz",
                ])
            }

            @Dependency(\.logger) var logger2
            #expect(logger2.metadataProvider.metadata.isEmpty)
        }
    }

    @Test func test_withLoggerMetadataProvider_shouldReplaceMetadata_setsMetadata() {
        withDependencies {
            $0.logger = Logger(
                label: "label",
                metadataProvider: {
                    ["logger-metadata-provider": "metadata"]
                },
                handlers: {}
            )
        } operation: {
            withLoggerMetadataProvider(shouldReplaceExistingMetadata: true) {
                [
                    "with-logging-metadata-provider": "metadata",
                ]
            } operation: {
                /// Expect additional metadata to be added/overwritten.
                @Dependency(\.logger) var logger1
                #expect(logger1.metadataProvider.metadata == [
                    "with-logging-metadata-provider": "metadata",
                ])
            }

            @Dependency(\.logger) var logger2
            #expect(logger2.metadataProvider.metadata == [
                "logger-metadata-provider": "metadata"
            ])
        }
    }

    @Test func test_asyncWithLoggerMetadataProvider_mergesMetadata() async {
        await withDependencies {
            $0.logger = Logger(
                label: "label",
                metadataProvider: {
                    [
                        "logger-metadata-provider": "metadata",
                        "foo": "bar",
                    ]
                },
                handlers: {}
            )
        } operation: {
            await withLoggerMetadataProvider {
                [
                    "with-logging-metadata-provider": "metadata",
                    "foo": "baz",
                ]
            } operation: {
                /// Expect additional metadata to be added/overwritten.
                @Dependency(\.logger) var logger1

                await Task {
                    #expect(logger1.metadataProvider.metadata == [
                        "logger-metadata-provider": "metadata",
                        "with-logging-metadata-provider": "metadata",
                        "foo": "baz",
                    ])
                }.value
            }

            @Dependency(\.logger) var logger2
            #expect(logger2.metadataProvider.metadata == [
                "logger-metadata-provider": "metadata",
                "foo": "bar",
            ])
        }
    }

    @Test func test_asyncWithLoggerMetadataProviderAndNoInitialMetadata_mergesMetadata() async {
        await withDependencies {
            $0.logger = Logger(
                label: "label",
                handlers: {}
            )
        } operation: {
            await withLoggerMetadataProvider {
                [
                    "with-logging-metadata-provider": "metadata",
                    "foo": "baz",
                ]
            } operation: {
                /// Expect additional metadata to be added/overwritten.
                @Dependency(\.logger) var logger1
                await Task {
                    #expect(logger1.metadataProvider.metadata == [
                        "with-logging-metadata-provider": "metadata",
                        "foo": "baz",
                    ])
                }.value
            }

            @Dependency(\.logger) var logger2
            #expect(logger2.metadataProvider.metadata.isEmpty)
        }
    }

    @Test func test_asyncWithLoggerMetadataProvider_shouldReplaceMetadata_setsMetadata() async {
        await withDependencies {
            $0.logger = Logger(
                label: "label",
                metadataProvider: {
                    ["logger-metadata-provider": "metadata"]
                },
                handlers: {}
            )
        } operation: {
            await withLoggerMetadataProvider(shouldReplaceExistingMetadata: true) {
                [
                    "with-logging-metadata-provider": "metadata",
                ]
            } operation: {
                /// Expect additional metadata to be added/overwritten.
                @Dependency(\.logger) var logger1

                await Task {
                    #expect(logger1.metadataProvider.metadata == [
                        "with-logging-metadata-provider": "metadata",
                    ])
                }.value
            }

            @Dependency(\.logger) var logger2
            #expect(logger2.metadataProvider.metadata == [
                "logger-metadata-provider": "metadata"
            ])
        }
    }
}
