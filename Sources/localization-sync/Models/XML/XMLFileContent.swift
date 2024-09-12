import Foundation
import XMLCoder

struct XMLFileContent: Codable, Equatable {
    var language: String = ""
    
    let string: [StringResource]
    let stringArray: [StringArrayResource]
    
    enum CodingKeys: String, CodingKey {
        case string
        case stringArray = "string-array"
    }
}

struct StringResource: Codable, Equatable {
    let name: String
    let translatable: String?
    let value: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case translatable
        case value = ""
    }
}

struct StringArrayResource: Codable, Equatable {
    let name: String
    let translatable: String?
    let item: [Item]
    
    enum CodingKeys: String, CodingKey {
        case name
        case translatable
        case item
    }
}

struct Item: Codable, Equatable {
    let value: String
    
    enum CodingKeys: String, CodingKey {
        case value = ""
    }
}
