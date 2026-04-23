import SwiftUI

struct LoginView: View {
    @State var email: String = ""
    @State var password: String = ""
    var authVM: AuthViewModel = .init()
    @State var isLoggedIn: Bool = false
    @State var user: AppUser?
    @State var patientVM: PatientViewModel?
    @State var doctorVM: DoctorViewModel?
    @State var userVM: (any UserProtocol)?
    
    @Environment(\.presentationMode) var presentationMode
    
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
                                try await user = authVM.signIn(email: email, password: password)
                                guard let user = user else { return }
                                userVM = authVM.authorizeRole(user)!
                                patientVM = PatientViewModel(user: user)
                                isLoggedIn = true
                                UserDefaults.standard.setValue(true, forKey: "isLoggedIn")
//                                UserDefaults.standard.set(user, forKey: "user")
                                saveUser(user: user)
                            } catch {
                                
                            }
                           
                        }
                    } label: {
                        Text("Login")
                    }
                    .buttonStyle(.glass)
                    .padding()
                    
                    
                    NavigationLink(isActive: $isLoggedIn) {
                        if let patientVM {
//                            ChartView(patient: patientVM)
                            MainTabView(user: user!)
                        } else {
                            EmptyView()
                        }
                    } label: {
                        EmptyView()
                    }

                    NavigationLink{
                        RegisterView()
                    } label: {
                        Label("Sign up for patient", systemImage: "person.fill")
                    }
                    .buttonStyle(.glass)
                    .padding()
                }
            }
            .padding()
        }
    }
}

//#Preview {
//    LoginView()
//}

func saveUser(user: AppUser) {
    let encoder = JSONEncoder()
    if let encodedData = try? encoder.encode(user) {
        UserDefaults.standard.set(encodedData, forKey: "user")
    }
}
