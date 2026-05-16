import SwiftUI
import Firebase
internal import Combine

@main
struct MyApp: App {
    
    @StateObject var user: AppUser = AppUser(userdata: loadUser())
    @StateObject var router: Router
    
    init() {
        FirebaseApp.configure()
        
        let savedUser = loadUser()
        let isLoggedIn = savedUser != nil && UserDefaults.standard.bool(forKey: "isLoggedIn")

        _user = StateObject(wrappedValue: AppUser(userdata: savedUser))
        _router = StateObject(wrappedValue: Router(screen: isLoggedIn ? .home : .login))
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path){
                ZStack{
                    switch router.rootView {
                     case .home:
                         MainTabView()
                            .transition(.slide)
                     case .login:
                         LoginView()
                            .transition(.slide)
                     case .register:
                         RegisterView()
                            .transition(.slide)
                     }
                }
                .animation(.bouncy(duration: 0.25), value: router.rootView)
                .navigationDestination(for: AppScreen.self) { screen in
                    switch screen{
                    case .home: if user.userdata != nil {
                        MainTabView()
                    } else {
                        LoginView()
                    }
                    case .login: LoginView()
                    case .register: RegisterView()
                    }
                }
            }
           
//            }
        }
        .environmentObject(user)
        .environmentObject(router)
    }
}


