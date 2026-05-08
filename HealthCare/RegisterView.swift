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
    @State var alertText: String = ""
    @State var showAlert: Bool = false
    @State var isVerifyEmailAlert: Bool = false
    @State var sexValues: [String] = ["Male", "Female"]
    private var isPhoneValid: Bool {
        phoneNumber.count == phoneDigitsLimit
    }
    
    //TODO: -Add error handlers, alerts with them and with email message notification
    
    var body: some View {
        VStack{
            Label("Patient sign up", systemImage: "cross.fill")
                .padding()
            GlassEffectContainer{
                TextField("Enter your name", text: $name)
                    .textFieldStyle(.roundedBorder)
                TextField("Enter your surname", text: $surname)
                    .textFieldStyle(.roundedBorder)
                TextField("Enter your thirdname", text: $thirdname)
                    .textFieldStyle(.roundedBorder)
                TextField("Enter your phone number", text: $phoneNumber)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .onChange(of: phoneNumber, { oldValue, newValue in
                        phoneNumber = sanitizePhoneNumber(newValue)
                    })
                    .border(.foreground, width: isPhoneValid ? 0 : 1)
                TextField("Enter your e-mail adress", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .border(.red, width: validateMail(email) ? 0 : 1)
                Picker("Gender", selection: $gender) {
                    ForEach(sexValues, id: \.self){ sex in
                        Text(sex).tag(sex)
                    }
                }
                .pickerStyle(.menu)
                DatePicker("Select your birthdate", selection: $birth, displayedComponents: .date)
                    .datePickerStyle(.compact)
                SecureField("Enter your password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                SecureField("Confirm your password", text: $passwordConfirmation)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .border(.red, width: password==passwordConfirmation ? 0 : 1)
                Button("Register") {
                    patient = PatientRegistrationData(name: name, surname: surname, thirdname: thirdname, birthday: birth, gender: gender, phone: phoneNumber)
                    Task{
                        do{
                            try await authVM.signUp(email: email, password: password, registrationData: patient!)
                            showAlert = true
                            alertText = "Check your email (also spam) to verification."
                        } catch{
                            showAlert = true
                            alertText = "Ошибка, повторите попытку позже"
                        }
                    }
                }
                .disabled(!isPhoneValid)
                .buttonStyle(.glass)
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


