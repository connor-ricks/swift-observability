import Foundation

// MARK: - ConsoleEmission

public protocol ConsoleEmission {
    var label: String { get }
    var name: String { get }
    var metadata: Metadata { get }
}

// MARK: - Log + ConsoleEmission

extension Log: ConsoleEmission {
    public var name: String { message }
}

// MARK: - Event + ConsoleEmission

extension Event: ConsoleEmission {}
