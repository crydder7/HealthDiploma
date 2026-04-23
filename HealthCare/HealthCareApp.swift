import SwiftUI
import Firebase

@main
struct MyApp: App {
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if UserDefaults.standard.bool(forKey: "isLoggedIn") {
//                ChartView(patient: PatientViewModel(user: loadUser())!)
                MainTabView(user: loadUser()!)
            } else {
                LoginView()
            }
        }
    }
}

func loadUser() -> AppUser? {
    if let data = UserDefaults.standard.data(forKey: "user") {
        let decoder = JSONDecoder()
        if let user = try? decoder.decode(AppUser.self, from: data) {
            return user
        }
    }
    return nil
}
