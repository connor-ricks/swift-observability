import Foundation

// swiftlint:disable:next type_name
public enum _Conditional<First: Sendable, Second: Sendable>: Sendable {
    case first(First)
    case second(Second)
}
