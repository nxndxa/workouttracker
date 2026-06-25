import SwiftUI

@main
struct AetherApp: App {
    @State private var store = WorkoutStore()

    var body: some Scene {
        #if os(macOS)
        WindowGroup {
            ContentView(store: store)
                .frame(minWidth: 1040, minHeight: 760)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 1120, height: 800)
        #else
        WindowGroup {
            ContentView(store: store)
        }
        #endif
    }
}
