import Foundation

class AppleLocalization {
    let urls: [URL]
    
    init(urls: [URL]) {
        self.urls = urls
    }
    
    private var files: [XCStringsFileContent] = []
    
    func prepare(_ results: inout [VerificationResult]) throws {
        files = try urls.map {
            try JSONDecoder().decode(XCStringsFileContent.self, from: Data(contentsOf: $0))
        }
        
        // Find source language
        let sourceLanguages = Set(files.map(\.sourceLanguage))
        if sourceLanguages.count == 1 {
            sourceLanguage = sourceLanguages.first!
            results.append(.init(level: .info, message: "Found source language \(sourceLanguage)."))
        } else if sourceLanguages.isEmpty {
            results.append(.init(level: .error, message: "Found no source language."))
        } else {
            results.append(.init(level: .error, message: "Found multiple source languages: \"\(sourceLanguages.joined(separator: ", "))\"."))
        }
        
        // Find languages
        languages = Set(files.flatMap { $0.strings.values.flatMap { $0.localizations?.map { $0.key } ?? [] }}).sorted()
        results.append(.init(level: .info, message: "Found languages \(languages.joined(separator: ", ")) in Apple files."))
        
        // Find keys
        keys = Set(files.flatMap { $0.strings.keys }).sorted()
        results.append(.init(level: .info, message: "Found \(keys.count) unique key(s) in Apple files."))
    }
    
    var sourceLanguage: String = ""
    var languages: [String] = []
    var keys: [String] = []
    
    func localizedUnit(key: String, language: String) -> [LocalizedUnit] {
        files
            .enumerated()
            .filter { $0.element.strings[key]?.localizations?[language] != nil }
            .map { ($0.offset, $0.element.strings[key]!.localizations![language]!) }
            .map { LocalizedUnit(key: key, language: language, file: urls[$0.0], value: $0.1.stringUnit?.value) }
    }
    
    func verify(_ results: inout [VerificationResult]) throws -> Bool {
        if keys.isEmpty {
            results.append(.init(level: .error, message: "Found no keys in Apple files."))
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
                            results.append(.init(level: .warning, message: "Multiple different Apple localizations found for key \"\(key)\" in language \(language):\n\(units.map { "\($0.value ?? "")\n└ \($0.file, effect: .faint)" }.joined(separator: "\n"))"))
                        }
                    }
                }
                if !missingLanguages.isEmpty {
                    results.append(.init(level: .warning, message: "No Apple localization found for key \"\(key)\" in language(s) \(missingLanguages.joined(separator: ", "))."))
                }
            }
        }
        return true
    }
    
    func compare(android: AndroidLocalization, _ results: inout [VerificationResult]) throws -> Bool {
        let allKeys = Set(keys + android.keys).sorted()
        for key in allKeys {
            // TODO: How to handle mapping? Apple uses English text as key, Android uses snake_case_id
            let englishKey = android.localizedUnit(key: key, language: "en").first?.value ?? key
            for language in languages {
                let units = localizedUnit(key: englishKey, language: language)
                let otherUnits = android.localizedUnit(key: key, language: language)
                if units.count == 1 && otherUnits.count == 1 {
                    if units[0].value != otherUnits[0].value {
                        results.append(.init(level: .warning, message: "Different localization found for key \"\(key)\" in language \(language): \n\(units.map { "\($0.value ?? "")\n└ \($0.file, effect: .faint)" }.joined(separator: "\n"))\n\(otherUnits.map { "\($0.value ?? "")\n└ \($0.file, effect: .faint)" }.joined(separator: "\n"))"))
                    }
                } else {
                    // DEBUG: results.append(.init(level: .warning, message: "Skipping key \"\(key)\" in language \(language) apple \(units), android \(otherUnits)."))
                }
            }
        }
        return true
    }
}
