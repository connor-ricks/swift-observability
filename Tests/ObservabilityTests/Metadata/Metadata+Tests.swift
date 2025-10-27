import Foundation
@testable import Observability
import Testing

@Suite("LoggerMetadata Tests") struct MetadataTests {

    // MARK: Tests

    @Test func test_metadata_json() {
        let dictionary: Metadata = [
            "a": "A",
            "b": "B",
            "c": ["1", "2", "3"],
            "d": [
                "1": "a",
                "2": "b",
                "3": "c",
            ],
        ]
        let metadata = Metadata([
            "array": ["1", "2", "3"],
            "bool": true,
            "dictionary": dictionary,
            "double": 5.0,
            "int": 5,
            "string": "hello world!",
        ])

        // swiftlint:disable indentation_width
        #expect(metadata.json == """
        {
          "array" : [
            "1",
            "2",
            "3"
          ],
          "bool" : true,
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
          "double" : 5,
          "int" : 5,
          "string" : "hello world!"
        }
        """)
        // swiftlint:enable indentation_width
    }
}
