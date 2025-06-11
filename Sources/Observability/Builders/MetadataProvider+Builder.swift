import Foundation

// MARK: - MetadataProviderBuilder

@resultBuilder
public enum MetadataProviderBuilder {

    // MARK: buildBlock (Single)

    @inlinable
    public static func buildBlock(_ provider: some MetadataProvider) -> some MetadataProvider {
        provider
    }

    // MARK: buildExpxression (Metadata)

    public static func buildExpression(_ metadata: Metadata) -> some MetadataProvider {
        EagerMetadataProvider(metadata)
    }

    // MARK: buildExpression (Array<MetadataProvider>)

    public static func buildExpression(_ providers: [any MetadataProvider]) -> some MetadataProvider {
        LazyMetadataProvider(providers)
    }

    // MARK: buildArray

    @inlinable
    public static func buildArray(_ providers: [some MetadataProvider]) -> some MetadataProvider {
        LazyMetadataProvider(providers)
    }

    // MARK: buildEither

    @inlinable
    public static func buildEither<TrueContent: MetadataProvider, FalseContent: MetadataProvider>(
        first provider: TrueContent
    ) -> _Conditional<TrueContent, FalseContent> {
        _Conditional<TrueContent, FalseContent>.first(provider)
    }

    @inlinable
    static func buildEither<TrueContent: MetadataProvider, FalseContent: MetadataProvider>(
        second provider: FalseContent
    ) -> _Conditional<TrueContent, FalseContent> {
        _Conditional<TrueContent, FalseContent>.second(provider)
    }

    // MARK: buildOptional

    @inlinable
    public static func buildOptional<P: MetadataProvider>(_ provider: P?) -> P? {
        provider
    }

    // MARK: buildLimitedAvailability

    @inlinable
    public static func buildLimitedAvailability<P: MetadataProvider>(_ provider: P?) -> P? {
        provider
    }
}
