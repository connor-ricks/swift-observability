import Foundation
@testable import SoloObservability
import Testing

@Suite("LoggerMetadata Tests") struct MetadataTests {

    // MARK: Dog

    struct Dog: CustomStringConvertible {
        var name: String
        var description: String { "Dog(name: \(name))" }
    }

    // MARK: Tests

    @Test func test_metadata_json() {
        let metadata: Metadata = [
            "key": "value",
            "array": ["1", "2", "3"],
            "dictionary": [
                "a": "A",
                "b": "B",
                "c": ["1", "2", "3"],
                "d": [
                    "1": "a",
                    "2": "b",
                    "3": "c",
                ],
            ],
            "dog": .stringConvertible(Dog(name: "Max")),
        ]

        // swiftlint:disable indentation_width
        #expect(metadata.json == """
        {
          "array" : [
            "1",
            "2",
            "3"
          ],
          "dictionary" : {
            "a" : "A",
            "b" : "B",
            "c" : [
              "1",
              "2",
              "3"
            ],
            "d" : {
              "1" : "a",
              "2" : "b",
              "3" : "c"
            }
          },
          "dog" : "Dog(name: Max)",
          "key" : "value"
        }
        """)
        // swiftlint:enable indentation_width
    }
}
