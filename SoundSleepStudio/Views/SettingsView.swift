import SwiftUI

struct SettingsView: View {
    // Sound settings
    @AppStorage(AppStorageKeys.defaultSound) private var defaultSound: String = "Wave"
    @AppStorage(AppStorageKeys.defaultTimerDuration) private var defaultTimerDuration: Int = 15
    
    // Available sound options (same as in HomeView)
    private let soundOptions = ["Wave", "Forest", "Night", "Rain"]
    
    // Timer duration options in minutes
    private let timerOptions = [15, 20, 30, 45, 60]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sound")) {
                    // Sound Picker using Menu
                    Menu {
                        ForEach(soundOptions, id: \.self) { sound in
                            Button(sound) {
                                defaultSound = sound
                            }
                        }
                    } label: {
                        HStack {
                            Text("Default Sound")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(defaultSound)
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(header: Text("Timer")) {
                    // Timer Duration Picker using Menu
                    Menu {
                        ForEach(timerOptions, id: \.self) { minutes in
                            Button("\(minutes) minutes") {
                                defaultTimerDuration = minutes
                            }
                        }
                    } label: {
                        HStack {
                            Text("Default Duration")
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(defaultTimerDuration) minutes")
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Link(destination: URL(string: "https://example.com/terms")!) {
                        HStack {
                            Text("Terms of Service")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
