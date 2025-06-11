import Foundation

// MARK: - MetadataValue

/// An observability metadata value. `MetadataValue` is string, array, and dictionary literal convertible.
public enum MetadataValue: Sendable {
    /// A metadata value which is an array of `MetadataValue`s.
    ///
    /// Because `MetadataValue` implements `ExpressibleByArrayLiteral`, you don't need to type
    /// `.array([.string("foo"), .string("bar \(buz)")])`, you can just use the more natural `["foo", "bar \(buz)"]`.
    case array([MetadataValue])

    /// A metadata value which is a dictionary from `String` to `MetadataValue`.
    ///
    /// Because `MetadataValue` implements `ExpressibleByDictionaryLiteral`, you don't need to type
    /// `.dictionary(["foo": .string("bar \(buz)")])`, you can just use the more natural `["foo": "bar \(buz)"]`.
    case dictionary(Metadata)

    /// A metadata value which is a `String`.
    ///
    /// Because `MetadataValue` implements `ExpressibleByStringInterpolation`, and `ExpressibleByStringLiteral`,
    /// you don't need to type `.string(someType.description)` you can use the string interpolation `"\(someType)"`.
    case string(String)

    /// A metadata value which is some `CustomStringConvertible`.
    case stringConvertible(any CustomStringConvertible & Sendable)
}

// MARK: - MetadataValue + Equatable

extension MetadataValue: Equatable {
    public static func == (lhs: MetadataValue, rhs: MetadataValue) -> Bool {
        switch (lhs, rhs) {
        case (.string(let lhs), .string(let rhs)):
            return lhs == rhs
        case (.stringConvertible(let lhs), .stringConvertible(let rhs)):
            return lhs.description == rhs.description
        case (.array(let lhs), .array(let rhs)):
            return lhs == rhs
        case (.dictionary(let lhs), .dictionary(let rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}

// MARK: - MetadataValue + ExpressibleByStringLiteral

extension MetadataValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

// MARK: - MetadataValue + ExpressibleByStringInterpolation

extension MetadataValue: ExpressibleByStringInterpolation {}

// MARK: - MetadataValue + ExpressibleByDictionaryLiteral

extension MetadataValue: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, MetadataValue)...) {
        self = .dictionary(.init(uniqueKeysWithValues: elements))
    }
}

// MARK: - MetadataValue + ExpressibleByArrayLiteral

extension MetadataValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: MetadataValue...) {
        self = .array(elements)
    }
}

// MARK: - MetadataValue + CustomStringConvertible

extension MetadataValue: CustomStringConvertible {
    public var description: String {
        // swiftlint:disable:next force_try
        let data = try! JSONSerialization.data(
            withJSONObject: json,
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

// MARK: - MetadataValue + JSON

extension MetadataValue {
    /// A JSON representation of the metadata value.
    var json: Any {
        switch self {
        case .string(let value):
            return value
        case .stringConvertible(let value):
            return value.description
        case .dictionary(let metadata):
            return metadata.mapValues { $0.json }
        case .array(let array):
            return array.map { $0.json }
        }
    }
}
