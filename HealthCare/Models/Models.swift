import Foundation
import SwiftUI
import FirebaseFirestore
internal import Combine

struct UserData: Codable {
    let id: String
    var name: String
    var surname: String
    var thirdname: String
    var phone: String
    let email: String
    let role: UserRole
}

class AppUser: ObservableObject{
    @Published public var userdata: UserData?
    
    init(userdata: UserData?) {
        self.userdata = userdata
    }
}

enum UserRole: Codable {
    case patient
    case doctor
    
    init?(rawValue: String) {
        switch rawValue {
        case "patient":
            self = .patient
        case "doctor":
            self = .doctor
        default:
            return nil
        }
    }
}

struct Patient {
    var user: UserData
    var name: String
    var surname: String
    var thirdname: String
    var gender: String
    var birthday: Date
    var phone: String
    
//    var glucoseLevels: [Int]
}

struct PatientRegistrationData {
    let name: String
    let surname: String
    let thirdname: String
    let birthday: Date
    let gender: String
    let phone: String
}

struct Doctor{
    var user: UserData
    var name: String
    var surname: String
    var thirdname: String
    var phone: String
}


struct GlucoseData: Codable {
    let unit: String
    var value: Double
}


struct RawMeasurement: Codable, Identifiable {
    let glucose: GlucoseData
    var timestamp: Int
    var foodImpact: Double
    var isGenerated: String = "actual"
    var id = UUID()
    
//    init(glucose: GlucoseData, timestamp: Int, foodImpact: Double, isGenerated: Bool = false, id: UUID = UUID()) {
//        self.glucose = glucose
//        self.timestamp = timestamp
//        self.foodImpact = foodImpact
//        self.isGenerated = isGenerated
//        self.id = id
//    }
    
    enum CodingKeys: String, CodingKey{
        case glucose = "glucose"
        case timestamp = "timestamp"
        case foodImpact = "foodImpact"
    }
}

func loadUser() -> UserData? {
    if let data = UserDefaults.standard.data(forKey: "user") {
        let decoder = JSONDecoder()
        if let user = try? decoder.decode(UserData.self, from: data) {
            return user
        }
    }
    return nil
}

func saveUser(user: UserData) {
    let encoder = JSONEncoder()
    if let encodedData = try? encoder.encode(user) {
        UserDefaults.standard.set(encodedData, forKey: "user")
    }
}

func sanitizePhoneNumber(_ value: String) -> String {
    let digitsOnly = value.filter(\.isNumber)
    return String(digitsOnly.prefix(11))
}

func validateMail(_ value: String) -> Bool {
    let regex = /^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}$/
    
    if let _ = value.wholeMatch(of: regex) {
        return true
    } else {
        return false
    }
}


enum sexPicker {
    case male
    case female
}


enum AppScreen: Hashable {
    case home
//    case profile(String)
//    case settings
//    case details(item: String)
    case login
    case register
}

class Router: ObservableObject {
    @Published var path = NavigationPath()
    @Published var rootView: AppScreen = .login
    
    init(screen: AppScreen){
        rootView = screen
    }
    
    func navigate(to screen: AppScreen) {
        path.append(screen)
    }
    
    func goBack(){
        if path.count > 0 {
            path.removeLast()
        }
    }
    
    func popToRoot() {
//        path.removeLast(path.count)
        path = NavigationPath()
//        path.append(rootView)
    }
    
    func becomeRoot(screen: AppScreen){
        path = NavigationPath()
        rootView = screen
    }
}
