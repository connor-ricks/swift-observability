import Foundation
@testable import Observability
import Testing

@Suite("MetadataValue Tests") struct MetadataValueTests {

    // MARK: Tests

    @Test func test_metadataValue_equatability() {
        let one: Metadata = [
            "array": ["1", "2", "3"],
            "bool": true,
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
            "double": 5.0,
            "int": 5,
            "string": "hello world!",
            "nullable": nil,
        ]

        let two = one
        #expect(one == two)

        let three: Metadata = ["array": ["1", "2", "3"]]
        let four: Metadata = ["array": ["2", "3", "4"]]
        #expect(three != four)

        let five: Metadata = ["bool": false]
        let six: Metadata = ["bool": true]
        #expect(five != six)

        let seven: Metadata = ["dictionary": [ "a": "A" ]]
        let eight: Metadata = ["dictionary": [ "b": "B" ]]
        #expect(seven != eight)

        let nine: Metadata = ["double": 5.5]
        let ten: Metadata = ["double": 5.0]
        #expect(nine != ten)

        let eleven: Metadata = ["int": 6]
        let twelve: Metadata = ["int": 5]
        #expect(eleven != twelve)

        let thirteen: Metadata = ["string": "hello world!"]
        let fourteen: Metadata = ["string": "goodbye world!"]
        #expect(thirteen != fourteen)

        let fifteen: Metadata = ["nullable": nil]
        let sixteen: Metadata = ["nullable": 5]
        #expect(fifteen != sixteen)
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
        // swiftlint:enable indentation_width
    }
}
