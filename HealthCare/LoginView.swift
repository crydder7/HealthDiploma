import SwiftUI

struct LoginView: View {
    @EnvironmentObject var user: AppUser
    @State var email: String = ""
    @State var password: String = ""
    var authVM: AuthViewModel = .init()
    @State var isLoggedIn: Bool = false
//    @State var user: UserData?
    @State var patientVM: PatientViewModel?
    @State var doctorVM: DoctorViewModel?
    @State var userVM: (any UserProtocol)?
    @State var errorText: String = ""
    @State var showError: Bool = false
//    @ObservedObject var viewController = ViewController.shared
    @EnvironmentObject var router: Router
//    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack{
            VStack{
                GlassEffectContainer{
                    TextField("Enter your email", text: $email)
                        .textInputAutocapitalization(.never)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    SecureField("Enter your password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    
                    Button {
                        Task {
                            do{
                                try await user.userdata = authVM.signIn(email: email, password: password)
                                guard let user = user.userdata else { return }
                                userVM = authVM.authorizeRole(user)!
                                patientVM = PatientViewModel(user: user)
                                isLoggedIn = true
                                UserDefaults.standard.setValue(true, forKey: "isLoggedIn")
                                saveUser(user: user)
                                router.navigate(to: .home)
                            } catch {
                                errorText = error.localizedDescription
                                showError = true
                            }
                           
                        }
                    } label: {
                        Text("Login")
                    }
                    .buttonStyle(.glass)
                    .padding()
                    .alert(isPresented: $showError){
                        Alert(title: Text("Error"), message: Text(errorText))
                    }
                    
                    
//                    NavigationLink(isActive: $isLoggedIn) {
//                        if user.userdata != nil {
//                            MainTabView(user: user)
//                        }
//                    } label: {
//                        EmptyView()
//                    }
                    
                    Button {
                        router.navigate(to: .register)
                        print(router.path)
                    } label: {
                        Label("Sign up", systemImage: "person.fill")
                    }
                    .buttonStyle(.glass)
                    .padding()
                    
                }
            }
            .onAppear(){
                if user.userdata != nil{
                    router.becomeRoot(screen: .home)
                }
            }
            .padding()
            .navigationDestination(for: AppScreen.self) { screen in
                switch screen{
                case .home: MainTabView()
                case .login: LoginView()
                case .register: RegisterView()
                }
            }
        }
    }
}

//#Preview {
//    LoginView()
//}


