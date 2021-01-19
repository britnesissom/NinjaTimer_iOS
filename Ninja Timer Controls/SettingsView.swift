//
//  Settings.swift
//  Ninja Timer Controls
//
//  Created by Brit'ne Sissom on 1/18/21.
//  Copyright © 2021 Brit'ne Sissom. All rights reserved.
//

import SwiftUI
import Combine

struct SettingsView: View {
    @ObservedObject var settings = UserSettings()
    
    var body: some View {
        VStack {
            Toggle(isOn: $settings.isLaserEnabled) {
                    Text("Laser Sensor").font(.system(size: 20))
                }.padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
        }
        .navigationBarTitle("Settings", displayMode: .inline)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .padding(.top, 30)
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            //SettingsView().environment(\.colorScheme, .dark)
            SettingsView()
        }
    }
}
