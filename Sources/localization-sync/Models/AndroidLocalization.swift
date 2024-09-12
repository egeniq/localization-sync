import Foundation
import XMLCoder

class AndroidLocalization {
    let urls: [URL]
    
    init(urls: [URL]) {
        self.urls = urls
    }
    
    private var files: [XMLFileContent] = []
    
    func prepare(_ results: inout [VerificationResult]) throws {
        // TODO: Let user specify one, or assume same as Apple?
        let defaultLanguage = "en"
        
        files = try urls.map {
            var content = try XMLDecoder().decode(XMLFileContent.self, from: Data(contentsOf: $0))
            content.language = language(for: $0) ?? defaultLanguage
            return content
        }
        
        // Find languages
        languages = Set(files.map(\.language)).sorted()
        results.append(.init(level: .info, message: "Found languages \(languages.joined(separator: ", ")) in Android files."))
        
        // Find keys
        // TODO: How to handle string-array?
        keys = Set(files.flatMap { $0.string.map(\.name) }).sorted()
        results.append(.init(level: .info, message: "Found \(keys.count) unique key(s) in Android files."))
    }
    
    private func language(for url: URL) -> String? {
        // TODO: Remove debug workaround
        if url.pathComponents.contains("release") { return "nl" }
        let path = url.pathComponents.suffix(2).prefix(1).first!
        let components = path.components(separatedBy: "-")
        if components.count == 2 {
            return components[1]
        } else if components.count > 2  {
            let lastComponents = components.suffix(2)
            let joined = lastComponents.joined(separator: "-")
            if joined.count == 6 {
                return joined.replacingOccurrences(of: "-r", with: "-")
            } else {
                return joined
            }
        }
        return nil
    }
    
    var sourceLanguage: String = ""
    var languages: [String] = []
    var keys: [String] = []
    
    func localizedUnit(key: String, language: String) -> [LocalizedUnit] {
        files
            .enumerated()
            .filter { $0.element.language == language }
            .filter { $0.element.string.contains(where: { $0.name == key }) }
            .flatMap { match in
                match.element.string
                    .filter { $0.name == key }
                    .map {
                        LocalizedUnit(key: key, language: language, file: urls[match.offset], value: $0.value)
                    }
            }
    }
    
    func verify(_ results: inout [VerificationResult]) throws -> Bool {
        if keys.isEmpty {
            results.append(.init(level: .error, message: "Found no keys in Android files."))
        } else if files.count == 1 {
            // Duplicates can't exist
        } else {
            for key in keys {
                var missingLanguages: [String] = []
                for language in languages {
                    let units = localizedUnit(key: key, language: language)
                    if units.isEmpty {
                        if language != sourceLanguage {
                            missingLanguages.append(language)
                        }
                    } else if units.count > 1 {
                        if Set(units.map(\.value)).count != 1 {
                            results.append(.init(level: .warning, message: "Multiple different Android localizations found for key \"\(key)\" in language \(language):\n\(units.map { "\($0.value ?? "")\n└ \($0.file, effect: .faint)" }.joined(separator: "\n"))"))
                        }
                    }
                }
                if !missingLanguages.isEmpty {
                    results.append(.init(level: .warning, message: "No Android localization found for key \"\(key)\" in language(s) \(missingLanguages.joined(separator: ", "))."))
                }
            }
        }
        return true
    }
}
