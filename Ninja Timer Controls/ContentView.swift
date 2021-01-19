//
//  ContentView.swift
//  Ninja Timer Controls
//
//  Created by Brit'ne Sissom on 5/30/20.
//  Copyright © 2020 Brit'ne Sissom. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var settings = UserSettings()
    @ObservedObject var bluetooth = BLEControl.shared
    @State private var score = 0
    
    func start() {
        bluetooth.writeValue(withValue: "s".data(using: .utf8)!)
    }
    func stop() {
        bluetooth.writeValue(withValue: "p".data(using: .utf8)!)
    }
    func reset() {
        score = 0
        bluetooth.writeValue(withValue: "r".data(using: .utf8)!)
    }
    func connectBLE() {
        bluetooth.connect()
    }
    func pass() {
        score += 1
        bluetooth.writeValue(withValue: "c".data(using: .utf8)!)
    }
    func resetScore() {
        score = 0
    }
    
    func viewSettings() {
    
    }
    
    var body: some View {
    NavigationView {
        ZStack {
            Color("AppColors").edgesIgnoringSafeArea(.all)
            VStack {
                
                
//                if !bluetooth.isEnabled {
//                    Text("Please enable Bluetooth in your Settings to use this app")
//                        .frame(maxWidth: .infinity)
//                        .padding(EdgeInsets(top: 30, leading: 10, bottom: 20, trailing: 10))
//                } else if !bluetooth.isConnected {
//                    Text("You must connect to the Ninja Timer via Bluetooth to use this app")
//                        .frame(maxWidth: .infinity)
//                        .padding(EdgeInsets(top: 30, leading: 10, bottom: 20, trailing: 10))
//                    Button(action: connectBLE) {
//                        Text("CONNECT")
//                        .fontWeight(.semibold)
//                        .frame(width: 150.0, height: 50)
//                        .background(Color.customGreen)
//                        .foregroundColor(Color.black)
//                        .cornerRadius(8)
//                        .overlay(RoundedRectangle(cornerRadius: 8)
//                            .stroke(Color.customGreen, lineWidth: 1))
//                    }
//                } else {
                    VStack(spacing: 40) {
                        Button(action: start) {
                            Text("START")
                            .fontWeight(.semibold)
                            .font(.system(size: 30))
                            .frame(width: 150.0, height: 50)
                            .background(Color.customGreen)
                            .foregroundColor(Color.black)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.customGreen, lineWidth: 1))
                        }
                        Button(action: stop) {
                            Text("STOP")
                            .fontWeight(.semibold)
                            .font(.system(size: 30))
                            .frame(width: 150.0, height: 50)
                            .background(Color.stopRed)
                            .foregroundColor(Color.black)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.stopRed, lineWidth: 1))
                        }
                        
                        Button(action: reset) {
                            Text("RESET")
                            .fontWeight(.semibold)
                            .font(.system(size: 30))
                            .frame(width: 150.0, height: 50)
                            .background(Color.resetGold)
                            .foregroundColor(Color.black)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.resetGold, lineWidth: 1))
                        }
                        
                        Divider().padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                        
                        HStack {
                            Button(action: pass) {
                                Text("CLEAR")
                                .fontWeight(.semibold)
                                .font(.system(size: 30))
                                .frame(width: 150.0, height: 50)
                                .background(Color.customGreen)
                                .foregroundColor(Color.black)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.customGreen, lineWidth: 1))
                            }
                        }
                        
                        Text("Score: " + String(score))
                            .font(.system(size: 30))
                        
                        Divider().padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                        
                        Toggle(isOn: $settings.isLaserEnabled) {
                            Text("Laser Sensor").font(.system(size: 20))
                        }.padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))

//                    }
//                    .padding(.top, 20)
                }.navigationBarTitle("Ninja Timer Controls")
                    .navigationBarItems(trailing:
                        Image(systemName: "gearshape.fill")
                                .font(.system(size: 30.0))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    )
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            //.padding(.top, 30)
        }
        }
    }

}

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

final class UserSettings: ObservableObject {
    var bluetooth: BLEControl
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    init() {
        bluetooth = BLEControl.shared
    }

    @UserDefault("isLaserEnabled", defaultValue: true)
    var isLaserEnabled: Bool {
        willSet {
            objectWillChange.send()
        }
        didSet {
            // send value to arduino via bluetooth
            if (isLaserEnabled) {
                bluetooth.writeValue(withValue: "y".data(using: .utf8)!)
            } else {
                bluetooth.writeValue(withValue: "n".data(using: .utf8)!)
            }
        }
    }
}

extension Color {
    static let stopRed = Color(red: 207 / 255, green: 20 / 255, blue: 43 / 255)
    static let resetGold = Color(red: 247 / 255, green: 215 / 255, blue: 7 / 255)
    static let customGreen = Color(red: 2 / 255, green: 219 / 255, blue: 6 / 255)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
               // .environment(\.colorScheme, .dark)
                .environmentObject(BLEControl.shared)

        }
    }
}
