import Foundation

struct XCStringsFileContent: Codable {
    let sourceLanguage: String
    let strings: [String: StringLocalization]
    let version: String
}
