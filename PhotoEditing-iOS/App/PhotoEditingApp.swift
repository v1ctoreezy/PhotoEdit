import SwiftUI

@main
struct PhotoEditingApp: App {
    let persistenceController = PersistenceController.shared
    
    // register initial UserDefaults values every launch
    init() {
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(PhotoEditingController.shared)
                .environmentObject(Data.shared)
        }
    }
}

