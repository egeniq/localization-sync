import ArgumentParser
import Foundation

@main
struct LocalizationSync: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Sync localizations between Apple and Android projects.",
        discussion: """
        Keep your localizations in both Apple and Android projects in sync.
        """,
        version: "0.0.1",
        subcommands: [Verify.self])
}
