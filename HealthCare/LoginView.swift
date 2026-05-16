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
    @State var isLoading: Bool = false
//    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack{
            Label("HEALTHCARE", systemImage: "cross.fill")
                .font(.title)
                .bold()
                .padding()
            
            Spacer()
            
            GlassEffectContainer{
                TextField("Enter your email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .glassEffect()
                
                SecureField("Enter your password", text: $password)
                    .autocorrectionDisabled()
                    .padding()
                    .glassEffect()
                
                Spacer()
                Button {
                    Task {
                        do{
                            isLoading = true
                            try await user.userdata = authVM.signIn(email: email, password: password)
                            guard let user = user.userdata else { return }
                            userVM = authVM.authorizeRole(user)!
                            patientVM = PatientViewModel(user: user)
                            isLoggedIn = true
                            UserDefaults.standard.setValue(true, forKey: "isLoggedIn")
                            saveUser(user: user)
                            self.user.userdata = user
                            isLoading = false
                            router.becomeRoot(screen: .home)
                        } catch {
                            isLoading = false
                            errorText = error.localizedDescription
                            showError = true
                        }
                    }
                } label: {
                    Label("Login", systemImage: "key.horizontal.fill")
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                }
                .buttonStyle(.glass)
                .padding()
                .alert(isPresented: $showError){
                    Alert(title: Text("Error"), message: Text(errorText))
                }
                
                Button {
                    router.navigate(to: .register)
                } label: {
                    Label("Sign up", systemImage: "person.fill")
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                }
                .buttonStyle(.glass)
                .padding()
                
            }
        }
        .padding()
        .overlay {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
    }
}

//#Preview {
//    LoginView()
//}


