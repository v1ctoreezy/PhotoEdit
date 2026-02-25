import SwiftUI

@main
struct PhotoEditingApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(PhotoEditingController.shared)
                .environmentObject(Data.shared)
        }
    }
}

