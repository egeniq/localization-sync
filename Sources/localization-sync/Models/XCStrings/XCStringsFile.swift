import Foundation

struct XCStringsFile {
    let url: URL
    
    init?(url: URL) {
        guard url.pathExtension == "xcstrings" else {
            return nil
        }
        self.url = url
    }
}
