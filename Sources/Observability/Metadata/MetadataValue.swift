import Foundation

// MARK: - MetadataValue

/// An observability metadata value. `MetadataValue` is string, array, and dictionary literal convertible.
public enum MetadataValue: Sendable {
    /// A metadata value which is an array of `MetadataValue`s.
    ///
    /// Because `MetadataValue` implements `ExpressibleByArrayLiteral`, you don't need to type
    /// `.array([.string("foo"), .string("bar \(buz)")])`, you can just use the more natural `["foo", "bar \(buz)"]`.
    case array([MetadataValue])

    /// A metadata value which is a `Bool`.
    ///
    /// Because `MetadataValue` implements `ExpressibleByBooleanLiteral`,
    /// you don't need to type `.bool(boolValue)` you can use the raw ints.
    case bool(Bool)

    /// A metadata value which is a dictionary from `String` to `MetadataValue`.
    ///
    /// Because `MetadataValue` implements `ExpressibleByDictionaryLiteral`, you don't need to type
    /// `.dictionary(["foo": .string("bar \(buz)")])`, you can just use the more natural `["foo": "bar \(buz)"]`.
    case dictionary(Metadata)

    /// A metadata value which is an `Double`.
    ///
    /// Because `MetadataValue` implements `ExpressibleByFloatLiteral`,
    /// you don't need to type `.double(doubleValue)` you can use the raw double.
    case double(Double)

    /// A metadata value which is an `Int`.
    ///
    /// Because `MetadataValue` implements `ExpressibleByIntegerLiteral`,
    /// you don't need to type `.int(intValue)` you can use the raw int.
    case int(Int)

    /// A nil metadata value.
    case none // swiftlint:disable:this discouraged_none_name

    /// A metadata value which is a `String`.
    ///
    /// Because `MetadataValue` implements `ExpressibleByStringInterpolation`, and `ExpressibleByStringLiteral`,
    /// you don't need to type `.string(someType.description)` you can use the string interpolation `"\(someType)"`.
    case string(String)
}

// MARK: - MetadataValue + Equatable

extension MetadataValue: Equatable {
    public static func == (lhs: MetadataValue, rhs: MetadataValue) -> Bool {
        switch (lhs, rhs) {
        case (.array(let lhs), .array(let rhs)):
            return lhs == rhs
        case (.bool(let lhs), .bool(let rhs)):
            return lhs == rhs
        case (.dictionary(let lhs), .dictionary(let rhs)):
            return lhs == rhs
        case (.double(let lhs), .double(let rhs)):
            return lhs == rhs
        case (.int(let lhs), .int(let rhs)):
            return lhs == rhs
        case (.none, .none):
            return true
        case (.string(let lhs), .string(let rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}

// MARK: - MetadataValue + ExpressibleByArrayLiteral

extension MetadataValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: MetadataValue...) {
        self = .array(elements)
    }
}

// MARK: - MetadataValue + ExpressibleByBooleanLiteral

extension MetadataValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

// MARK: - MetadataValue + ExpressibleByDictionaryLiteral

extension MetadataValue: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, any MetadataValueConvertible)...) {
        self = .dictionary(elements.reduce(into: [:], { dictionary, pair in
            dictionary[pair.0] = pair.1.asMetadataValue()
        }))
    }
}

// MARK: - MetadataValue + ExpressibleByFloatLiteral

extension MetadataValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}

// MARK: - MetadataValue + ExpressibleByIntegerLiteral

extension MetadataValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .int(value)
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

// MARK: - MetadataValue + ExpressibleByNilLiteral

extension MetadataValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .none
    }
}

// MARK: - MetadataValue + CustomStringConvertible

extension MetadataValue: CustomStringConvertible {
    public var description: String {
        // swiftlint:disable:next force_try
        if let json {
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
        } else {
            return "null"
        }
    }
}

// MARK: - MetadataValue + JSON

extension MetadataValue {
    /// A JSON representation of the metadata value.
    var json: Any? {
        switch self {
        case .array(let array):
            return array.map { $0.json }
        case .bool(let value):
            return value
        case .dictionary(let metadata):
            return metadata.mapValues { $0.asMetadataValue().json }
        case .double(let value):
            return value
        case .int(let value):
            return value
        case .string(let value):
            return value
        case .none:
            return nil
        }
    }
}
