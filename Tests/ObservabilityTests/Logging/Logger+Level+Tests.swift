import Foundation
@testable import SoloObservability
import Testing

@Suite("Logger+Level Tests") struct LoggerLevelTests {
    @Test(arguments: Log.Level.allCases)
    func test_level_severity(level: Log.Level) {
        #expect(Log.Level.allCases[level.naturalIntegralValue] == level)
    }

    @Test(arguments: Log.Level.allCases)
    func test_level_severityComparable(level: Log.Level) {
        for other in Log.Level.allCases {
            if other.naturalIntegralValue < level.naturalIntegralValue {
                #expect(other < level)
            } else if other.naturalIntegralValue == level.naturalIntegralValue {
                #expect(other == level)
            } else {
                #expect(other > level)
            }
        }
    }
}
