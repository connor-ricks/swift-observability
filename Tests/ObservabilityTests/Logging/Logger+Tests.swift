import Foundation
@testable import SoloObservability
import Testing

@Suite("Logger Tests") struct LoggerTests {
    @Test func test_metadataOperations() {
        var logger1 = Logger(label: "logger", metadata: ["foo": "1"])

        /// Test logger's initial metadata
        #expect(logger1.metadata == ["foo": "1"])

        /// Test updating logger's metadata
        logger1.metadata = ["bar": "2"]
        #expect(logger1.metadata == ["bar": "2"])

        /// Test updating metadata via subscript
        logger1[metadataKey: "baz"] = "3"
        #expect(logger1.metadata == ["bar": "2", "baz": "3"])

        /// Test getting metadata via subscript
        #expect(logger1[metadataKey: "bar"] == "2")

        /// Test making a copy of logger copies storage.
        var logger2 = logger1
        logger2[metadataKey: "qux"] = "4"
        #expect(logger2.metadata == ["bar": "2", "baz": "3", "qux": "4"])
        #expect(logger1.metadata == ["bar": "2", "baz": "3"])
    }

    @Test(arguments: Log.Level.allCases)
    func test_log_onlyCallsLogHandlersWithCorrectDebugLevel(level: Log.Level) {
        let levelUp: Log.Level? = if level < .critical {
            Log.Level.allCases[level.naturalIntegralValue + 1]
        } else {
            nil
        }

        let history1 = History<Log>()
        let history2 = History<Log>()
        let history3 = History<Log>()

        let logger = Logger(label: "logger", handlers: {
            TestLogHandler(level: .trace, history: history1)
            TestLogHandler(level: level, history: history2)
            if let levelUp {
                TestLogHandler(level: levelUp, history: history3)
            }
        })

        logger.log(level, "Log")

        /// Handler one has the lowest level, it should receive all logs.
        #expect(history1.logs.count == 1)
        #expect(history1.logs[0].message == "Log")
        /// Handler two has a matching level, it should receive all logs.
        #expect(history2.logs.count == 1)
        #expect(history2.logs[0].message == "Log")
        /// Handler three has a higher level, it should not receive any logs.
        #expect(history3.logs.isEmpty)
    }

    @Test func test_log_buildsLogWithProvidedPrameters() {
        let history = History<Log>()
        let logger = Logger(label: "test", handlers: {
            TestLogHandler(level: .trace, history: history)
        })

        logger.log(.info, "Log", metadata: ["foo": "bar"])

        #expect(history.logs.count == 1)
        #expect(history.logs[0].message == "Log")
        #expect(history.logs[0].metadata["foo"] == "bar")
        #expect(history.logs[0].level == .info)
    }

    @Test func test_log_buildsMetadataWithCorrectOrdering() {
        let history1 = History<Log>()
        let history2 = History<Log>()
        let logger = Logger(
            label: "logger",
            metadata: [
                "logger-metadata": "A",
                "foo": "A",
            ]
        ) {
            [
                "logger-metadata-provider": "A",
                "foo": "B",
                "bar": "A",
            ]
        } handlers: {
            TestLogHandler(level: .trace, history: history1) {
                [
                    "handler-1": "A",
                    "bar": "B",
                    "baz": "A",
                ]
            }
            TestLogHandler(level: .trace, history: history2) {
                [
                    "handler-2": "A",
                    "bar": "B",
                    "baz": "A",
                ]
            }
        }

        logger.log(.debug, "Log", metadata: [
            "log": "A",
            "baz": "B",
        ])

        #expect(history1.logs.count == 1)
        #expect(history1.logs[0].metadata == [
            "logger-metadata": "A",
            "logger-metadata-provider": "A",
            "handler-1": "A",
            "log": "A",
            "foo": "B", // Overwritten by logger metadata provider
            "bar": "B", // Overwritten by handler metadata provider
            "baz": "B", // Overwritten by log metadata
        ])

        #expect(history2.logs.count == 1)
    }
}
