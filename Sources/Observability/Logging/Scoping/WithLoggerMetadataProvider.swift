import Foundation

// MARK: - WithLoggerMetadataProvider

/// Updates the current logger's metadata provider for the duration of a synchronous operation.
///
/// - Note: Providing `true` for the `shouldReplaceExistingMetadata` property
///   will result in all previously set metadata being overridden for the duration of the operation.
///
/// ```swift
/// withLoggerMetadataProvider(shouldReplaceExistingMetadata: false)) {
///     ["id": "my-req"]
/// }, operation: {
///     @Dependency(\.logger) var logger
///     // Logs include ["id: "my-req", "only-on": "B"] as part of their metadata.
///     logger.log(.debug, "Hello new world!", metadata: ["only-on": "B")
/// }
///
/// @Dependency(\.logger) var logger
/// // Log include ["only-on": "A"] as part of their metadata.
/// logger.log(.debug, "Hello old world!", metadata: ["only-on": "A")
/// ```
///
/// - Important: Key conflicts are resolved by favoring the provided values over the existing values.
///   If the builder contains multiple providers that also have conflcits, providers closer to the top of the builder
///   block will be favored.
///
/// - Parameters:
///    - shouldReplaceExistingMetadata: Whether or not the provided metadata provider should
///      replace the existing metadata provider or be merged with the existing metadata provider..
///    - metadataProvider: The metadata provider to be added to the logger.
///    - operation: An operation to perform wherein the logger has been overridden.
/// - Returns: The result returned from `operation`.
@discardableResult
public func withLoggerMetadataProvider<R>(
    shouldReplaceExistingMetadata: Bool = false,
    @MetadataProviderBuilder _ metadataProvider: @Sendable () -> some MetadataProvider,
    operation: () throws -> R
) rethrows -> R {
    try withLogger({
        if shouldReplaceExistingMetadata {
            $0.set(metadataProvider: metadataProvider)
        } else {
            $0.merge(metadataProvider: metadataProvider)
        }
    }, operation: operation)
}

/// Updates the current logger's metadata provider for the duration of an asynchronous operation.

/// ```swift
/// await withLoggerMetadataProvider(shouldReplaceExistingMetadata: false) {
///     ["id": "my-req"]
/// }, operation: {
///     @Dependency(\.logger) var logger
///     // Logs include ["id: "my-req", "only-on": "B"] as part of their metadata.
///     logger.log(.debug, "Hello new world!", metadata: ["only-on": "B")
/// }
///
/// @Dependency(\.logger) var logger
/// // Log include ["only-on": "A"] as part of their metadata.
/// logger.log(.debug, "Hello old world!", metadata: ["only-on": "A")
/// ```
///
/// - Important: Key conflicts are resolved by favoring the provided values over the existing values.
///   If the builder contains multiple providers that also have conflcits, providers closer to the top of the builder
///   block will be favored.
///
/// - Parameters:
///    - isolation: The isolation associated with the operation.
///    - shouldReplaceExistingMetadata: Whether or not the provided metadata provider should
///      replace the existing metadata provider or be merged with the existing metadata provider.
///    - metadataProvider: The metadata provider to be added to the logger.
///    - operation: An operation to perform wherein the logger has been overridden.
/// - Returns: The result returned from `operation`.
@discardableResult
public func withLoggerMetadataProvider<R>(
    isolation: isolated (any Actor)? = #isolation,
    shouldReplaceExistingMetadata: Bool = false,
    @MetadataProviderBuilder _ metadataProvider: @Sendable () -> some MetadataProvider,
    operation: () async throws -> R
) async rethrows -> R {
    try await withLogger({
        if shouldReplaceExistingMetadata {
            $0.set(metadataProvider: metadataProvider)
        } else {
            $0.merge(metadataProvider: metadataProvider)
        }
    }, operation: operation)
}

// MARK: - Helpers

extension Logger {
    /// Updates the logger by merging the given additional metadata provider into the existing
    /// metadata provider.
    ///
    /// - Important: Key conflicts are resolved by favoring the provided values over the existing values.
    ///   If the builder contains multiple providers that also have conflcits, providers closer to the top of the builder
    ///   block will be favored.
    ///
    /// - Parameters:
    ///   - additionalMetadata: A closure that provides the additional metadata to merge.
    /// - Returns: A new logger with the additional metadata added.
    fileprivate mutating func merge(@MetadataProviderBuilder metadataProvider additionalMetadataProvider: () -> some MetadataProvider) {
        self.metadataProvider = LazyMetadataProvider([
            metadataProvider,
            additionalMetadataProvider(),
        ])
    }

    /// Updates the logger by replacing existing metadata provider with the provided metadata provider.
    ///
    /// - Parameters:
    ///   - metadata: A closure that provides the metadata.
    /// - Returns: A new logger with the metadata replaced.
    fileprivate mutating func set(@MetadataProviderBuilder metadataProvider: () -> some MetadataProvider) {
        self.metadataProvider = metadataProvider()
    }
}
