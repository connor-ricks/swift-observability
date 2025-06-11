import Foundation
@testable import SoloObservability
import Testing

@Suite("MetadataProvider Tests") struct MetadataProviderTests {

    // MARK: MockMetadataProvider

    struct MockMetadataProvider: MetadataProvider, Equatable {
        let id: UUID = UUID()
        let metadata: Metadata
    }

    // MARK: Tests

    @Test func test_builder_buildBlockProvider() {
        let mock = MockMetadataProvider(metadata: ["key": "value"])
        let result = MetadataProviderBuilder.buildBlock(mock)
        #expect(result.metadata == mock.metadata)
    }

    @Test func test_builder_buildBlockMetadata() {
        let metadata: Metadata = ["key": "value"]
        let result = MetadataProviderBuilder.buildExpression(metadata)
        #expect(result.metadata == metadata)
    }

    @Test func test_builder_buildExpressionMetadata() {
        let metadata: Metadata = ["key": "value"]
        let result = MetadataProviderBuilder.buildExpression(metadata)
        #expect(result.metadata == metadata)
    }

    @Test func test_builder_buildExpressionArrayProviders() {
        let metadata1: Metadata = ["foo": "bar"]
        let metadata2: Metadata = ["bar": "baz"]
        let result = MetadataProviderBuilder.buildExpression([
            EagerMetadataProvider(metadata1),
            EagerMetadataProvider(metadata2),
        ])

        #expect(result.metadata == [
            "foo": "bar",
            "bar": "baz",
        ])
    }

    @Test func test_builder_buildArray() {
        let mock1 = MockMetadataProvider(metadata: ["A": "A", "B": "B"])
        let mock2 = MockMetadataProvider(metadata: ["B": "C", "C": "C"])
        let mock3 = MockMetadataProvider(metadata: ["C": "D", "D": "D"])
        let result = MetadataProviderBuilder.buildArray([mock1, mock2, mock3])
        #expect(result.metadata == [
            "A": "A",
            "B": "C",
            "C": "D",
            "D": "D",
        ])
    }

    @Test func test_builder_buildEitherFirst() {
        let mock = MockMetadataProvider(metadata: ["key": "value"])
        let result: _Conditional<MockMetadataProvider, MockMetadataProvider> = MetadataProviderBuilder.buildEither(first: mock)
        #expect(result.metadata == mock.metadata)
    }

    @Test func test_builder_buildEitherSecond() {
        let mock = MockMetadataProvider(metadata: ["key": "value"])
        let result: _Conditional<MockMetadataProvider, MockMetadataProvider> = MetadataProviderBuilder.buildEither(second: mock)
        #expect(result.metadata == mock.metadata)
    }

    @Test func test_builder_buildOptional() {
        let mock = MockMetadataProvider(metadata: ["key": "value"])
        let result1 = MetadataProviderBuilder.buildOptional(mock)
        #expect(result1?.metadata == mock.metadata)

        let result2: MockMetadataProvider? = MetadataProviderBuilder.buildOptional(nil)
        #expect(result2?.metadata == nil)
    }

    @Test func test_builder_buildLimitedAvailability() {
        let mock = MockMetadataProvider(metadata: [:])
        let result = MetadataProviderBuilder.buildLimitedAvailability(mock)
        #expect(result == mock)
    }

    @Test func test_eagerMetadataProvider_isEager() {
        let metadata = LockIsolated<Metadata>(["key": "value"])
        let provider: any MetadataProvider = .eager {
            metadata.value
        }
        metadata.withValue { $0["key"] = "new-value" }
        #expect(provider.metadata == ["key": "value"])
    }

    @Test func test_lazyMetadataProvider_isLazy() {
        let metadata = LockIsolated<Metadata>(["key": "value"])
        let provider: any MetadataProvider = .lazy {
            metadata.value
        }
        metadata.withValue { $0["key"] = "new-value" }
        #expect(provider.metadata == ["key": "new-value"])
    }

    @Test func test_anyMetadataProvider_maintainsErasedBehavior() {
        let eagerMetadata = LockIsolated<Metadata>(["key": "value"])
        let eagerProvider: any MetadataProvider = .eager {
            eagerMetadata.value
        }

        eagerMetadata.withValue { $0["key"] = "new-value" }

        let anyEagerProvider = eagerProvider.eraseToAnyMetadataProvider()
        #expect(anyEagerProvider.metadata == ["key": "value"])

        let lazyMetadata = LockIsolated<Metadata>(["key": "value"])
        let lazyProvider: any MetadataProvider = .lazy {
            lazyMetadata.value
        }

        lazyMetadata.withValue { $0["key"] = "new-value" }

        let anyLazyProvider = lazyProvider.eraseToAnyMetadataProvider()
        #expect(anyLazyProvider.metadata == ["key": "new-value"])
    }
}
