import SwiftUI
import Firebase
internal import Combine

//TODO: -Create class to control Views
//@MainActor class ViewController: ObservableObject {
//    static let shared = ViewController(isLoggedIn: UserDefaults.standard.bool(forKey: "isLoggedIn"), user: UserDefaults.standard.object(forKey: "user") as? AppUser)
//    @Published var isLoggedIn: Bool
//    @Published var user: AppUser?
//    private var authVM = AuthViewModel()
//    
//    private init(isLoggedIn: Bool, user: AppUser?) {
//        self.isLoggedIn = isLoggedIn
//        self.user = user
//    }
//    
//    func logIn(email: String, password: String) async throws -> AppUser? {
//        Task{
//            let user = try await authVM.signIn(email: email, password: password)
//            self.isLoggedIn = true
//        }
//        return user
//    }
//    
//    func logOut(){
//        self.authVM.signOut()
//        self.isLoggedIn = false
//    }
//}


@main
struct MyApp: App {
    
    @StateObject var user: AppUser = AppUser(userdata: loadUser())
    @StateObject var router: Router = Router()
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
//            if user.userdata != nil {
//                NavigationStack{
//                    MainTabView(user: AppUser(userdata: loadUser()))
//                }
//            } else {
            NavigationStack(path: $router.path){
                LoginView()
            }
//            }
        }
        .environmentObject(user)
        .environmentObject(router)
    }
}


