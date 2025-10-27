import Foundation

public protocol MetadataValueConvertible: Sendable, Equatable {
    func asMetadataValue() -> MetadataValue
}

extension MetadataValue: MetadataValueConvertible {
    public func asMetadataValue() -> MetadataValue {
        self
    }
}

extension Array: MetadataValueConvertible where Element: MetadataValueConvertible {
    public func asMetadataValue() -> MetadataValue {
        .array(self.map { $0.asMetadataValue() })
    }
}

extension Bool: MetadataValueConvertible {
    public func asMetadataValue() -> MetadataValue {
        .bool(self)
    }
}

extension Dictionary: MetadataValueConvertible where Key == String, Value == MetadataValue {
    public func asMetadataValue() -> MetadataValue {
        .dictionary(self)
    }
}

extension Double: MetadataValueConvertible {
    public func asMetadataValue() -> MetadataValue {
        .double(self)
    }
}

extension Int: MetadataValueConvertible {
    public func asMetadataValue() -> MetadataValue {
        .int(self)
    }
}

extension String: MetadataValueConvertible {
    public func asMetadataValue() -> MetadataValue {
        .string(self)
    }
}

extension Optional: MetadataValueConvertible where Wrapped: MetadataValueConvertible {
    public func asMetadataValue() -> MetadataValue {
        self?.asMetadataValue() ?? .none
    }
}
