import ArgumentParser
import Foundation

extension LocalizationSync {
    struct Verify: ParsableCommand {
        static var configuration =
            CommandConfiguration(abstract: "Verify that the localization files are valid.")

        @Argument(
            help: "All .xcstrings and .xml files used in the projects.",
            completion: .file(extensions: ["xcstrings", "xml"]), transform: URL.init(fileURLWithPath:))
        var files: [URL]
        
        mutating func run() throws {
            let results = try verify()
            if results.filter({ $0.level == .error }).isEmpty {
                if results.filter({ $0.level == .warning }).isEmpty {
                    print("These localization files are \("valid", effect: .green).")
                } else {
                    print("These localization files are \("valid", effect: .green), but have \(results.filter({ $0.level == .warning }).count, effect: .bold) warning(s).")
                }
                results.forEach {
                    print("\($0.level.text) \($0.message)")
                }
            } else {
                print("These localization files have \(results.count, effect: .bold) issue(s).")
                results.forEach {
                    print("\($0.level.text) \($0.message)")
                }
            }
        }
        
        func verify() throws -> [VerificationResult]  {
            var results = [VerificationResult]()
            
            let localizationFiles = files.compactMap(LocalizationFile.init(url:))
            results.append(.init(level: .info, message: "Found \(localizationFiles.count, effect: .bold) file(s)"))
            
            let appleURLs = localizationFiles.compactMap(\.xcStringsURL)
            let apple: AppleLocalization?
            if !appleURLs.isEmpty {
                apple = AppleLocalization(urls: appleURLs)
                try apple?.prepare(&results)
            } else {
                apple = nil
            }
            
            let androidURLs = localizationFiles.compactMap(\.xmlURL)
            let android: AndroidLocalization?
            if !androidURLs.isEmpty {
                android = AndroidLocalization(urls: androidURLs)
                try android?.prepare(&results)
            } else {
                android = nil
            }
            
            if let apple, let android {
                // TODO: Calculate proposed language map or let user specify one?
                let languageMap: [String: String] = ["pl-PL": "pl", "sl-SI": "sl", "uk-UA": "uk"]
                results.append(.init(level: .info, message: "Mapping language(s) \(languageMap)."))
                try compareLists("language", a: "Apple", apple.languages, b: "Android", android.languages.map { languageMap[$0] ?? $0 }, &results)
                
                try compareLists("key", separator: "\n- ", a: "Apple", apple.keys, b: "Android", android.keys.map { android.localizedUnit(key: $0, language: "en").first?.value ?? $0 }, &results)
            }
            
            let _ = try apple?.verify(&results)
            let _ = try android?.verify(&results)
            
            if let apple, let android {
                let _ = try apple.compare(android: android, &results)
            }
            return results
        }
        
        private func compareLists(_ kind: String, separator: String = ", ", a: String, _ listA: [String], b: String, _ listB: [String], _ results: inout [VerificationResult]) throws {
            guard listA != listB else {
                return
            }
  
            let uniqueToListA = listA.filter { !listB.contains($0) }
            let uniqueToListB = listB.filter { !listA.contains($0) }
            
            if !uniqueToListB.isEmpty {
                results.append(.init(level: .warning, message: "Missing \(kind)(s) \(uniqueToListB.joined(separator: separator)) in \(a) files."))
            }
            
            if !uniqueToListA.isEmpty {
                results.append(.init(level: .warning, message: "Missing \(kind)(s) \(uniqueToListA.joined(separator: separator)) in \(b) files."))
            }
        }
    }
}
