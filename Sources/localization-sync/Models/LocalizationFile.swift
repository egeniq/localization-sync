import Foundation

enum LocalizationFile {
    case xcStrings(XCStringsFile)
    case xml(XMLFile)
    
    init?(url: URL) {
        if let xcStrings = XCStringsFile(url: url) {
            self = .xcStrings(xcStrings)
        } else if let xml = XMLFile(url: url) {
            self = .xml(xml)
        } else {
            return nil
        }
    }
    
    var url: URL {
        switch self {
        case let .xcStrings(file):
            file.url
        case let .xml(file):
            file.url
        }
    }
    
    var xcStringsURL: URL? {
        switch self {
        case let .xcStrings(file):
            file.url
        case .xml:
            nil
        }
    }
    
    var xmlURL: URL? {
        switch self {
        case .xcStrings:
            nil
        case let .xml(file):
            file.url
        }
    }
}

