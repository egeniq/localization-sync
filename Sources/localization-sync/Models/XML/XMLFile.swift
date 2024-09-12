import Foundation

struct XMLFile {
    let url: URL
    
    init?(url: URL) {
        guard url.pathExtension == "xml" else {
            return nil
        }
        self.url = url
    }
}
