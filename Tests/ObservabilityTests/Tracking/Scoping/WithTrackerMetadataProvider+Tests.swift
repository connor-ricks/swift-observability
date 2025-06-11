import Foundation
@testable import SoloObservability
import Testing

@Suite("WithTrackerMetadataProvider Tests") struct WithTrackerMetadataProviderTests {
    @Test func test_withTrackerMetadataProvider_mergesMetadata() {
        withDependencies {
            $0.tracker = Tracker(
                label: "label",
                metadataProvider: {
                    [
                        "tracker-metadata-provider": "metadata",
                        "foo": "bar",
                    ]
                },
                handlers: {}
            )
        } operation: {
            withTrackerMetadataProvider {
                [
                    "with-tracking-metadata-provider": "metadata",
                    "foo": "baz",
                ]
            } operation: {
                /// Expect additional metadata to be added/overwritten.
                @Dependency(\.tracker) var tracker1
                #expect(tracker1.metadataProvider.metadata == [
                    "tracker-metadata-provider": "metadata",
                    "with-tracking-metadata-provider": "metadata",
                    "foo": "baz",
                ])
            }

            @Dependency(\.tracker) var tracker2
            #expect(tracker2.metadataProvider.metadata == [
                "tracker-metadata-provider": "metadata",
                "foo": "bar",
            ])
        }
    }

    @Test func test_withTrackerMetadataProviderAndNoInitialMetadata_mergesMetadata() {
        withDependencies {
            $0.tracker = Tracker(
                label: "label",
                handlers: {}
            )
        } operation: {
            withTrackerMetadataProvider {
                [
                    "with-tracking-metadata-provider": "metadata",
                    "foo": "baz",
                ]
            } operation: {
                /// Expect additional metadata to be added/overwritten.
                @Dependency(\.tracker) var tracker1
                #expect(tracker1.metadataProvider.metadata == [
                    "with-tracking-metadata-provider": "metadata",
                    "foo": "baz",
                ])
            }

            @Dependency(\.tracker) var tracker2
            #expect(tracker2.metadataProvider.metadata.isEmpty)
        }
    }

    @Test func test_withTrackerMetadataProvider_shouldReplaceMetadata_setsMetadata() {
        withDependencies {
            $0.tracker = Tracker(
                label: "label",
                metadataProvider: {
                    ["tracker-metadata-provider": "metadata"]
                },
                handlers: {}
            )
        } operation: {
            withTrackerMetadataProvider(shouldReplaceExistingMetadata: true) {
                [
                    "with-tracking-metadata-provider": "metadata",
                ]
            } operation: {
                /// Expect additional metadata to be added/overwritten.
                @Dependency(\.tracker) var tracker1
                #expect(tracker1.metadataProvider.metadata == [
                    "with-tracking-metadata-provider": "metadata",
                ])
            }

            @Dependency(\.tracker) var tracker2
            #expect(tracker2.metadataProvider.metadata == [
                "tracker-metadata-provider": "metadata"
            ])
        }
    }

    @Test func test_asyncWithTrackerMetadataProvider_mergesMetadata() async {
        await withDependencies {
            $0.tracker = Tracker(
                label: "label",
                metadataProvider: {
                    [
                        "tracker-metadata-provider": "metadata",
                        "foo": "bar",
                    ]
                },
                handlers: {}
            )
        } operation: {
            await withTrackerMetadataProvider {
                [
                    "with-tracking-metadata-provider": "metadata",
                    "foo": "baz",
                ]
            } operation: {
                /// Expect additional metadata to be added/overwritten.
                @Dependency(\.tracker) var tracker1

                await Task {
                    #expect(tracker1.metadataProvider.metadata == [
                        "tracker-metadata-provider": "metadata",
                        "with-tracking-metadata-provider": "metadata",
                        "foo": "baz",
                    ])
                }.value
            }

            @Dependency(\.tracker) var tracker2
            #expect(tracker2.metadataProvider.metadata == [
                "tracker-metadata-provider": "metadata",
                "foo": "bar",
            ])
        }
    }

    @Test func test_asyncWithTrackerMetadataProviderAndNoInitialMetadata_mergesMetadata() async {
        await withDependencies {
            $0.tracker = Tracker(
                label: "label",
                handlers: {}
            )
        } operation: {
            await withTrackerMetadataProvider {
                [
                    "with-tracking-metadata-provider": "metadata",
                    "foo": "baz",
                ]
            } operation: {
                /// Expect additional metadata to be added/overwritten.
                @Dependency(\.tracker) var tracker1
                await Task {
                    #expect(tracker1.metadataProvider.metadata == [
                        "with-tracking-metadata-provider": "metadata",
                        "foo": "baz",
                    ])
                }.value
            }

            @Dependency(\.tracker) var tracker2
            #expect(tracker2.metadataProvider.metadata.isEmpty)
        }
    }

    @Test func test_asyncWithTrackerMetadataProvider_shouldReplaceMetadata_setsMetadata() async {
        await withDependencies {
            $0.tracker = Tracker(
                label: "label",
                metadataProvider: {
                    ["tracker-metadata-provider": "metadata"]
                },
                handlers: {}
            )
        } operation: {
            await withTrackerMetadataProvider(shouldReplaceExistingMetadata: true) {
                [
                    "with-tracking-metadata-provider": "metadata",
                ]
            } operation: {
                /// Expect additional metadata to be added/overwritten.
                @Dependency(\.tracker) var tracker1

                await Task {
                    #expect(tracker1.metadataProvider.metadata == [
                        "with-tracking-metadata-provider": "metadata",
                    ])
                }.value
            }

            @Dependency(\.tracker) var tracker2
            #expect(tracker2.metadataProvider.metadata == [
                "tracker-metadata-provider": "metadata"
            ])
        }
    }
}
