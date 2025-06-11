@_exported import Dependencies
import Foundation

/// An emission handler that outputs formatted logs to the console.
public struct ConsoleEmissionHandler<Emission: ConsoleEmission, Context: Sendable>: Sendable {

    // MARK: Properties

    /// The context for the emission.
    var context: Context

    /// The formatter to use when formatting timestamps.
    var dateFormatter: DateFormatter?

    /// Whether or not the output should include log metadata.
    var shouldOutputMetadata: Bool

    /// A provider that injects additional metadata into each emission.
    public var metadataProvider: any MetadataProvider

    /// The printer that handles outputting logs.
    ///
    /// - Note: Used to observe outputs during testing.
    var print: @Sendable (String) -> Void = { Swift.print($0) }

    // MARK: Emission

    func emit(_ emission: Emission, prefix: String = "") {
        var output = prefix

        if let dateFormatter {
            @Dependency(\.date) var date
            output += " \(dateFormatter.string(from: date()))"
        }

        output += " \(emission.label)"
        output += " (\(emission.name))"

        if !emission.metadata.isEmpty, shouldOutputMetadata {
            output += " metadata: \(emission.metadata.json)"
        }

        print(output)
    }
}
