import Foundation

struct VerificationResult {
    enum Level {
        case info
        case warning
        case error
    }
    let level: Level
    let message: String
}

extension VerificationResult.Level {
    var text: String {
        switch self {
        case .info:
            "\("[INFO]", effect: .green)"
        case .warning:
            "\("[WARNING]", effect: .yellow)"
        case .error:
            "\("[ERROR]", effect: .red)"
        }
    }
}

