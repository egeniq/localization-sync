import Foundation

struct StringUnit: Codable, Equatable {
    let state: String
    let value: String
}

extension StringUnit: CustomStringConvertible {
    var description: String {
        "\(value) (\(state))"
    }
}
