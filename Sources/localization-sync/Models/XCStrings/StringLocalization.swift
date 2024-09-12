import Foundation

struct StringLocalization: Codable, Equatable {
    let comment: String?
    let extractionState: String?
    let localizations: [String: Localizaton]?
}

extension StringLocalization: CustomStringConvertible {
    var description: String {
        """
          localizations:
        \(localizations?.myDescription ?? "N/A")
          extractionState: \(extractionState ?? "N/A")
          comment:
            \(comment ?? "N/A")
        
        """
    }
}

extension [String: Localizaton] {
    var myDescription: String {
        keys.sorted().map {
            "    \($0): \(self[$0]?.stringUnit?.description ?? "N/A")"
        }.joined(separator: "\n")
    }
}
