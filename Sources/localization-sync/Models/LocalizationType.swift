import Foundation

protocol LocalizationType {
    var languages: [String] { get }
    var keys: [String] { get }
    
    func prepare(_ results: inout [VerificationResult]) throws
    func localizedUnit(key: String, language: String) -> LocalizedUnit?
    func verify(_ results: inout [VerificationResult]) throws -> Bool
}
