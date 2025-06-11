import Foundation
@testable import SoloObservability
import Testing

@Suite("MetadataValue Tests") struct MetadataValueTests {

    // MARK: Dog

    struct Dog: CustomStringConvertible {
        var name: String
        var description: String { "Dog(name: \(name))" }
    }

    // MARK: Tests

    @Test func test_metadataValue_equatability() {
        let one: Metadata = [
            "key": "value",
            "array": ["1", "2", "3"],
            "dictionary": [
                "a": "A",
                "b": "B",
            ],
            "dog": .stringConvertible(Dog(name: "Max")),
        ]

        let two = one

        #expect(one == two)

        let three: Metadata = ["key": "value"]
        let four: Metadata = ["key": "VALUE"]
        #expect(three != four)

        let five: Metadata = ["key": ["1", "2"]]
        let six: Metadata = ["key": ["2", "3"]]
        #expect(five != six)

        let seven: Metadata = ["key": ["a": "A"]]
        let eight: Metadata = ["key": ["b": "B"]]
        #expect(seven != eight)

        let nine: Metadata = ["key": .stringConvertible(Dog(name: "Max"))]
        let ten: Metadata = ["key": .stringConvertible(Dog(name: "Fido"))]
        #expect(nine != ten)

        #expect(three != ten)
    }

    @Test func test_metadataValue_description() {
        // swiftlint:disable indentation_width
        let one: MetadataValue = ["key": "value"]
        #expect(one.description == """
        {
          "key" : "value"
        }
        """)
        let two: MetadataValue = ["key": ["1", "2"]]
        #expect(two.description == """
        {
          "key" : [
            "1",
            "2"
          ]
        }
        """)

        let three: MetadataValue = ["key": ["a": "A"]]
        #expect(three.description == """
        {
          "key" : {
            "a" : "A"
          }
        }
        """)

        let four: MetadataValue = ["key": .stringConvertible(Dog(name: "Max"))]
        #expect(four.description == """
        {
          "key" : "Dog(name: Max)"
        }
        """)
        // swiftlint:enable indentation_width
    }
}
