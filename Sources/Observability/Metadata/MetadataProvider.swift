import Foundation

// MARK: - MetadataProvider

/// A protocol that defines metadata that can be injected into observability services.
public protocol MetadataProvider: Sendable {
    /// The metadata that should be injected.
    var metadata: Metadata { get }
}

// MARK: - EagerMetadataProvider

/// A metadata provider that provides a cached set of metadata.
public struct EagerMetadataProvider: MetadataProvider {
    /// The provider's metadata.
    public let metadata: Metadata

    /// Creates a metadata provider that provides a cached set of metadata.
    @inlinable
    public init(_ metadata: Metadata) {
        self.metadata = metadata
    }
}

// MARK: - MetadataProvider + EagerMetadataProvider

extension MetadataProvider where Self == EagerMetadataProvider {
    /// Creates a metadata provider that provides a cached set of metadata.
    public static func eager(_ provider: @escaping @Sendable () -> Metadata) -> EagerMetadataProvider {
        EagerMetadataProvider(provider())
    }
}

// MARK: - LazyMetadataProvider

/// A metadata provider that provides metadata at the time of the emitter's emission.
public struct LazyMetadataProvider: MetadataProvider {

    // MARK: Properties

    private let provider: @Sendable () -> Metadata

    // MARK: Initializers

    /// Creates a metadata provider that provides metadata at the time of the emitter's emission.
    public init(_ provider: @Sendable @escaping () -> Metadata) {
        self.provider = provider
    }

    /// Creates a metadata provider from a collection of metadata providers
    ///
    /// Key conflicts are resolved by favoring the providers later in the array.
    public init(_ providers: [any MetadataProvider]) {
        self.provider = {
            providers.reduce(into: Metadata()) { metadata, provider in
                metadata.merge(provider.metadata) { _, provider in provider }
            }
        }
    }

    // MARK: MetadataProvider

    /// The provider's metadata.
    public var metadata: Metadata {
        provider()
    }
}

// MARK: - MetadataProvider + LazyMetadataProvider

extension MetadataProvider where Self == LazyMetadataProvider {
    /// Creates a metadata provider that provides metadata at the time of the emitter's emission.
    public static func lazy(_ provider: @escaping @Sendable () -> Metadata) -> LazyMetadataProvider {
        LazyMetadataProvider(provider)
    }
}

// MARK: - Conditional + MetadataProvider

extension _Conditional: MetadataProvider where First: MetadataProvider, Second: MetadataProvider {
    /// Returns the metadata from the provider.
    @inlinable
    public var metadata: Metadata {
        switch self {
        case .first(let first):
            first.metadata
        case .second(let second):
            second.metadata
        }
    }
}

// MARK: - AnyMetadataProvider

/// A type-erased metadata provider.
public struct AnyMetadataProvider: MetadataProvider {

    // MARK: Properties

    private let provider: @Sendable () -> Metadata

    // MARK: Initializers

    /// Creates a type-erased metadata provider.
    public init(_ provider: some MetadataProvider) {
        self.provider = {
            provider.metadata
        }
    }

    // MARK: MetadataProvider

    /// The provider's metadata.
    public var metadata: Metadata {
        provider()
    }
}

// MARK: - MetadataProvider + AnyMetadataProvider

extension MetadataProvider {
    /// Wraps this provider with a type eraser.
    func eraseToAnyMetadataProvider() -> AnyMetadataProvider {
        AnyMetadataProvider(self)
    }
}
