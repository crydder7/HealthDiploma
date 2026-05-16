import SwiftUI

struct RegisterView: View {
    private let phoneDigitsLimit = 11
    
    @State var name: String = ""
    @State var surname: String = ""
    @State var thirdname: String = ""
    @State var phoneNumber: String = ""
    @State var email: String = ""
    @State var birth: Date = Date()
    @State var gender: String = "Male"
    @State var password: String = ""
    @State var passwordConfirmation: String = ""
    @ObservedObject var authVM = AuthViewModel()
    @State var patient: PatientRegistrationData?
    @State var alertText: String = "Something wrong"
    @State var showAlert: Bool = false
    @State var isVerifyEmailAlert: Bool = false
    @State var sexValues: [String] = ["Male", "Female"]
    @State var isLoading: Bool = false
    private var isPhoneValid: Bool {
        phoneNumber.count == phoneDigitsLimit
    }
    
    //TODO: -Add error handlers, alerts with them and with email message notification
    
    var body: some View {
        VStack{
            Label("Sign up", systemImage: "cross.fill")
                .font(.title)
                .padding()
            Spacer()
            GlassEffectContainer{
                TextField("Enter your name", text: $name)
                    .padding()
                    .glassEffect()
                    .autocorrectionDisabled()
                TextField("Enter your surname", text: $surname)
                    .padding()
                    .glassEffect()
                    .autocorrectionDisabled()
                TextField("Enter your thirdname", text: $thirdname)
                    .padding()
                    .glassEffect()
                    .autocorrectionDisabled()
                TextField("Enter your phone number", text: $phoneNumber)
                    .padding()
                    .keyboardType(.numberPad)
                    .autocorrectionDisabled()
                    .onChange(of: phoneNumber, { oldValue, newValue in
                        phoneNumber = sanitizePhoneNumber(newValue)
                    })
                    .border(.foreground, width: isPhoneValid ? 0 : 1)
                    .glassEffect()
                TextField("Enter your e-mail adress", text: $email)
                    .padding()
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .border(.red, width: validateMail(email) ? 0 : 1)
                    .glassEffect()
                Picker("Gender", selection: $gender) {
                    ForEach(sexValues, id: \.self){ sex in
                        Text(sex).tag(sex)
                    }
                }
                .pickerStyle(.menu)
                DatePicker("Select your birthdate", selection: $birth, displayedComponents: .date)
                    .datePickerStyle(.compact)
                SecureField("Enter your password", text: $password)
                    .padding()
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .glassEffect()
                SecureField("Confirm your password", text: $passwordConfirmation)
                    .padding()
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .border(.red, width: password==passwordConfirmation ? 0 : 1)
                    .glassEffect()
                Spacer()
                
                Button {
                    patient = PatientRegistrationData(name: name, surname: surname, thirdname: thirdname, birthday: birth, gender: gender, phone: phoneNumber)
                    Task{
                        do{
                            isLoading = true
                            try await authVM.signUp(email: email, password: password, registrationData: patient!)
                            alertText = "Check your email (also spam) to finish verification."
                            isLoading = false
                            showAlert = true
                        } catch {
                            isLoading = false
                            alertText = error.localizedDescription
                            showAlert = true
                        }
                    }
                } label: {
                    Label("Register", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                }
                .disabled(!isPhoneValid)
                .buttonStyle(.glass)
                .overlay(content: {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                })
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(title: Text(alertText))
                }
            }
        }
        .padding()
    }
}

//#Preview {
//    RegisterView()
//}


