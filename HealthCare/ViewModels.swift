import Foundation
import FirebaseAuth
internal import Combine
import FirebaseFirestore
import Charts
import CoreML

class AuthViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var errorMessage: String?
    
    init() {
        self.user = Auth.auth().currentUser
    }
    
    
    func signUp(email: String, password: String, registrationData: PatientRegistrationData) async throws {
        var uid = ""
        do{
            let result = try await Auth.auth()
                .createUser(withEmail: email, password: password)
            uid = result.user.uid
            try await result.user.sendEmailVerification()
        } catch {
            throw NSError(domain: "Error", code: 404, userInfo: [NSLocalizedDescriptionKey: "Some error, try again later"])
        }
        
        
//        let uid = result.user.uid
        let db = Firestore.firestore()
        
        let snapshot = try await db.collection("doctorData")
            .document("emails")
            .getDocument()
        
        if let data = snapshot.data(), data[email] as? String == "doctor"{
            try await db.collection("users")
                .document(uid)
                .setData([
                    "name": registrationData.name,
                    "surname": registrationData.surname,
                    "thirdname": registrationData.thirdname,
                    "email": email,
                    "phone": registrationData.phone,
                    "role": "doctor"
                ])
        } else {
            try await db.collection("users")
                .document(uid)
                .setData([
                    "name": registrationData.name,
                    "surname": registrationData.surname,
                    "thirdname": registrationData.thirdname,
                    "email": email,
                    "phone": registrationData.phone,
                    "role": "patient"
                ])
            
            try await db.collection("patientsData")
                .document(uid)
                .setData([
                    "birthday": Timestamp(date: registrationData.birthday),
                    "gender": registrationData.gender
                ])
        }
        
        
    }
    
    func signIn(email: String, password: String) async throws -> UserData {
        
        let result = try await Auth.auth()
            .signIn(withEmail: email, password: password)
        
        let user = result.user
        
        guard user.isEmailVerified else {
            try Auth.auth().signOut()
            throw NSError(
                domain: "",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "Подтвердите email"]
            )
        }
        
        let db = Firestore.firestore()
        
        let snapshot = try await db.collection("users")
            .document(user.uid)
            .getDocument()
        
        guard let data = snapshot.data(),
              let roleString = data["role"] as? String,
              let role = UserRole(rawValue: roleString)
        else {
            throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Some error, try again later"])
        }
        
        return UserData(
            id: user.uid,
            name: (data["name"] as? String)!,
            surname: (data["surname"] as? String)!,
            thirdname: (data["thirdname"] as? String) ?? "",
            phone: (data["phone"] as? String)!,
            email: user.email!,
            role: role
        )
    }
    
    func authorizeRole(_ user:UserData)-> (any UserProtocol)?{
        if user.role == .patient {
            let patientVM = PatientViewModel(user: user)
            return patientVM
        } else if user.role == .doctor{
            let doctorVM = DoctorViewModel(user: user)
            return doctorVM
        } else {
            return nil
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        self.user = nil
        UserDefaults.standard.setValue(false, forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "user")
    }
    
    func changePassword(email: String) throws {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            
        }
    }
}


class PatientViewModel: ObservableObject, UserProtocol {
    @Published var user: UserData
    @Published var date: Date = Date()
    @Published var measurements: [RawMeasurement] = []
    
    init?(user: UserData?) {
        guard let user = user else { return nil}
        self.user = user
    }
    
    func getAge() async throws -> Int {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("patientsData")
            .document(user.id)
            .getDocument()
        
        guard let data = snapshot.data(),
              let birthday = data["birthday"] as? Timestamp
        else {
            throw NSError(domain: "", code: 404)
        }

        let birthDate = birthday.dateValue()
        let now = Date()
        let calendar = Calendar.current
        let age = calendar.dateComponents([.year], from: birthDate, to: now).year ?? 0
        return max(0, age)
    }
    
    func getTodayData(date: Date) async throws {
        let uid = user.id
        let db = Firestore.firestore()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let formatted = df.string(from: date)
        let docRef = db.collection("patientsData").document(uid).collection("glucose").document(formatted)
        let snapshot = try await docRef.getDocument()
        guard let data = snapshot.data(), let measurements = data["measurements"] else { throw NSError(domain: "", code: 228, userInfo: [NSLocalizedDescriptionKey: "Нет измерений за выбранную дату"]) }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: measurements) else { return }
        let decoder = JSONDecoder()
        let rawMeasurements = try decoder.decode([RawMeasurement].self, from: jsonData)
        self.measurements = rawMeasurements
    }
    
    func getDocInfo(_ docInfo: DoctorInfo) async throws{
        let uid = user.id
        let db = Firestore.firestore()
        let snapshot = try await db.collection("patientsData").document(uid)
            .getDocument()
        guard let data = snapshot.data(), let docID = data["doctorID"] else { throw NSError(domain: "", code: 228, userInfo: [NSLocalizedDescriptionKey: "Нет лечащего врача"]) }
        let snapshot2 = try await db.collection("users").document(docID as! String)
            .getDocument()
        guard let data2 = snapshot2.data() else { throw NSError(domain: "", code: 228, userInfo: [NSLocalizedDescriptionKey: "Нет данных о  враче"]) }
        docInfo.fullName = "\(data2["surname"] as? String ?? "") \(data2["name"] as? String ?? "") \(data2["thirdname"] as? String ?? "")"
        let birthday = data2["birthday"] as? Timestamp
        docInfo.email = data2["email"] as? String
        let date = birthday?.dateValue()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day,.month,.year], from: date ?? Date())
        docInfo.birthday = "\(components.day ?? 0)/\(components.month ?? 0)/\(components.year ?? 0)"
        docInfo.email = data2["email"] as? String
        docInfo.phone = data2["phone"] as? String
    }
}

class DoctorViewModel: ObservableObject, UserProtocol{
    @Published var user: UserData
    @Published var patients: [DoctorPatientDisplay] = []
    @Published var uids: [String] = []
    @Published var patientsMeasurements: [RawMeasurement] = []
    
    init?(user: UserData?) {
        guard let user = user else { return nil}
        self.user = user
    }

    func loadPatients() async throws -> [DoctorPatientDisplay]{
        self.patients = []
        self.uids = []
        let db = Firestore.firestore()
        
        do{
            let snapshot = try await db.collection("doctorData")
                .document(user.id)
                .getDocument()
            for i in snapshot.data()! {
                let key = i.key.replacing(" ", with: "")
                self.uids.append(key)
            }
        } catch {
            
        }
        
        for i in uids{
            do {
                let snapshot = try await db.collection("users")
                    .document(i)
                    .getDocument()
                let snap2 = try await db.collection("patientsData")
                    .document(i)
                    .getDocument()
                guard let data = snapshot.data() else { throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "No data"])}
                guard let data2 = snap2.data() else { throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "No data"]) }
                let fullName = "\(data["surname"] as? String ?? " ") \(data["name"] as? String ?? " ") \(data["thirdname"] as? String ?? " ")"
                let birthday = data2["birthday"] as? Timestamp
                let date = birthday?.dateValue()
                let calendar = Calendar.current
                let components = calendar.dateComponents([.day,.month,.year], from: date ?? Date())
                let gender = data2["gender"] as? String ?? " "
                let email = data["email"] as? String ?? " "
                let phone = data["phone"] as? String ?? " "
                let patient = DoctorPatientDisplay(fullName: fullName, uid: i, birthday: "\(components.day ?? 0)/\(components.month ?? 0)/\(components.year ?? 0)", gender: gender, phone: phone, email: email)
                
                self.patients.append(patient)
            } catch {
                throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Error"])
            }
        }
        
        return self.patients
    }
    
    func getTodayData(date: Date, uid: String) async throws {
        self.patientsMeasurements = []
        let db = Firestore.firestore()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let formatted = df.string(from: date)
        let docRef = db.collection("patientsData").document(uid).collection("glucose").document(formatted)
        let snapshot = try await docRef.getDocument()
        guard let data = snapshot.data(), let measurements = data["measurements"] else { throw NSError(domain: "", code: 228, userInfo: [NSLocalizedDescriptionKey: "Нет измерений за выбранную дату"]) }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: measurements) else { return }
        let decoder = JSONDecoder()
        let rawMeasurements = try decoder.decode([RawMeasurement].self, from: jsonData)
        self.patientsMeasurements = rawMeasurements
    }
    
}

protocol UserProtocol: ObservableObject{
    var user: UserData{ get set }
}


class ModelPredictViewModel: ObservableObject {
//    @Published var user: UserData
    
    @Published var measurements: [RawMeasurement]
    @Published var userId: String = ""
    private var lags: [Double] = [0, 0, 0, 0, 0, 0, 0]
    private var velocities: [Double] = [0, 0]
    private var acceleration: Double = 0
    private var meanRecent: Double = 0
    private var isFemale: Double = 0
    private var isDiabet: Double = 0
    private var foodImpact: Double = 0
    var cfg = MLModelConfiguration()
    private var model = delta_model()
    
    
    init(userId: String, measurements: [RawMeasurement]) {
//        self.user = user
        self.userId = userId
        self.measurements = measurements
    }
    
    func createLags(){
        let last = measurements.last
        let prev = measurements[measurements.count-2]
        let lastDate = Date(timeIntervalSince1970: TimeInterval(last!.timestamp))
        let prevDate = Date(timeIntervalSince1970: TimeInterval(prev.timestamp))
        let lastTime = lastDate.formatted(date: .omitted, time: .shortened)
        let prevTime = prevDate.formatted(date: .omitted, time: .shortened)
        
        let minutesLast = lastTime.components(separatedBy: ":").map { Int($0)! }.reduce(0, { $0*60 + $1 })
        let minutesPrev = prevTime.components(separatedBy: ":").map { Int($0)! }.reduce(0, { $0*60 + $1 })
        
        let diff = minutesPrev - minutesLast
        var minutes = [minutesLast, 0, 0, 0, 0, minutesPrev]
//        
//        if diff > 45 {
//            //TODO: - Evaluate lags for big time gap
//            
//        } else {
        
            let points: Int = diff/5
            for i in 1...4{
                minutes[i] = minutes[i-1] + points
            }
            self.lags[0] = (last?.glucose.value)!
            self.lags[5] = prev.glucose.value
            for i in 1...4 {
                let numerator = Double(minutes[i] - minutes[i - 1])
                let denominator = Double(minutes[5] - minutes[i])
                
                guard denominator != 0 else { continue }
                
                let x = numerator / denominator
                let y = (lags[5] - lags[i - 1]) * x
                lags[i] = lags[i - 1] + y
//                let x: Double = Double((minutes[i] - minutes[i-1]) / (minutes[5] - minutes[i]))
//                let y = (lags[5] - lags[i-1]) * x
//                lags[i] = lags[i-1] + y
            }
            
            
//        }
        
    }
    
    func getSex() async throws{
        let db = Firestore.firestore()
        let snapshot = try await db.collection("patientsData").document(userId)
            .getDocument()
        guard let sex = snapshot.data()?["gender"] as? String else { throw NSError(domain: "Error", code: 404, userInfo: [NSLocalizedDescriptionKey:"No sex data"])}
        switch sex {
        case "Male": self.isFemale = 0
        case "Female": self.isFemale = 1
        default: self.isFemale = 0
        }
    }
    
    func createVelocity(){
        velocities[0] = lags[0] - lags[1]
        velocities[1] = lags[1] - lags[2]
    }
    
    func createAcceleration(){
        acceleration = velocities[0] - velocities[1]
    }
    
    func createMeanRecent(){
        meanRecent = (lags[0] + lags[1] + lags[2]) / 3
    }
    
    func forecast(minutes: Int) throws -> [RawMeasurement] {
        guard measurements.count > 1 else { throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Some error, try again later"])}
//        TODO: - CHANGE isDiabet to variable from firebase
        self.isDiabet = 0
        Task {
            try await getSex()
        }
        .escalatePriority(to: .high)
        createLags()
        createVelocity()
        createAcceleration()
        createMeanRecent()
        var predict = [Double]()
        do {
            for i in [5, 10, 15, 30]{
                let p = try model.prediction(lag_1: lags[0], lag_2: lags[1], lag_3: lags[2], lag_4: lags[3], lag_5: lags[4], lag_6: lags[5], timeToPredict: Double(i), velocity_1: velocities[0], velocity_2: velocities[1], acceleration: acceleration, meanRecent: meanRecent, isFemale: self.isFemale, isDiabet: self.isDiabet, foodImpact: measurements.last?.foodImpact ?? 0)
                predict.append(p.predicted_delta)
            }
//            let p = try model.prediction(lag_1: lags[0], lag_2: lags[1], lag_3: lags[2], lag_4: lags[3], lag_5: lags[4], lag_6: lags[5], timeToPredict: Double(minutes), velocity_1: velocities[0], velocity_2: velocities[1], acceleration: acceleration, meanRecent: meanRecent, isFemale: self.isFemale, isDiabet: self.isDiabet, foodImpact: measurements.last?.foodImpact ?? 0)
//            predict = p.predicted_delta
        } catch  {
            
        }
        let times = [5,10,15,30]
        var forecasts = [RawMeasurement]()
        var glucoses = [GlucoseData]()
        for i in 0...3{
            predict[i] = predict[i] + measurements.last!.glucose.value
            glucoses.append(GlucoseData(unit: "mmol/L", value: predict[i]))
        }
        for i in 0...3{
            forecasts.append(RawMeasurement(glucose: glucoses[i], timestamp: measurements.last!.timestamp + times[i]*60, foodImpact: 0, isGenerated: true))
        }
//        let newValue = predict + measurements.last!.glucose.value
//        print("last value:", measurements.last!.glucose.value)
//        let glucose = GlucoseData(unit: "mmol/L", value: newValue)
//        let forecasted = RawMeasurement(glucose: glucose, timestamp: measurements.last!.timestamp + minutes*60, foodImpact: 0)
//        print("forecast:", forecasted)
//        print(model.model.modelDescription.inputDescriptionsByName.keys)
//        print("lags", lags)
//        print("timeToPredict", minutes)
//        print("velocity_1", velocities[0])
//        print("velocity_2", velocities[1])
//        print("acceleration", acceleration)
//        print("meanRecent", meanRecent)
//        print("isFemale", isFemale)
//        print("isDiabet", isDiabet)
//        print("foodImpact", foodImpact)
        print(forecasts)
        return forecasts
    }
}


struct DoctorPatientDisplay: Hashable, Identifiable{
    let id = UUID()
    var fullName: String
    var uid: String
    var birthday: String?
    var gender: String?
    var phone: String?
    var email: String?
}

class PickedPatient: ObservableObject, Identifiable{
    var id = UUID()
    @Published var fullName: String
    @Published var uid: String
    @Published var birthday: String?
    @Published var gender: String?
    @Published var phone: String?
    @Published var email: String?
     
    init(fullName: String, uid: String, birthday: String? = nil, gender: String? = nil, phone: String? = nil, email: String? = nil) {
        self.fullName = fullName
        self.uid = uid
        self.birthday = birthday
        self.gender = gender
        self.phone = phone
        self.email = email
    }
}

class DoctorInfo: ObservableObject, Identifiable {
    var id = UUID()
    @Published var fullName: String
    @Published var email: String?
    @Published var birthday: String?
    @Published var gender: String?
    @Published var phone: String?
    
    init(id: UUID = UUID(), fullName: String, email: String? = nil, birthday: String? = nil, gender: String? = nil, phone: String? = nil) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.birthday = birthday
        self.gender = gender
        self.phone = phone
    }
}
