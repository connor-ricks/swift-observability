import Foundation

// MARK: - Metadata

/// `Metadata` is a typealias for `[String: MetadataValue]` the type of the metadata storage.
public typealias Metadata = [String: MetadataValue]

// MARK: - Metadata + CustomStringConvertible

extension Metadata {
    /// A JSON representation of the metadata.
    public var json: String {
        // swiftlint:disable:next force_try
        let data = try! JSONSerialization.data(
            withJSONObject: mapValues { $0.json },
            options: [
                .withoutEscapingSlashes,
                .prettyPrinted,
                .sortedKeys,
                .fragmentsAllowed,
            ]
        )

        return String(data: data, encoding: .utf8) ?? ""
    }
}
