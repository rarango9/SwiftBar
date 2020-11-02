import Cocoa
import SwiftUI
import ShellOut

class App: NSObject {
    public static func openPluginFolder() {
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: Preferences.shared.pluginDirectoryPath ?? "")
    }

    public static func changePluginFolder() {
        let dialog = NSOpenPanel()
        dialog.title                   = "Choose plugin folder"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = true
        dialog.canChooseFiles          = false
        dialog.canCreateDirectories    = true
        dialog.allowsMultipleSelection = false

        guard dialog.runModal() == .OK,
              let path = dialog.url?.path
        else {return}

        Preferences.shared.pluginDirectoryPath = path
        delegate.pluginManager.refreshAllPlugins()
    }

    public static func getPlugins() {
        let url = URL(string: "https://github.com/orgs/swiftbar/")!
        NSWorkspace.shared.open(url)
    }

    public static func openPreferences() {
        let panel = NSPanel(contentViewController: NSHostingController(rootView: PreferencesView().environmentObject(Preferences.shared)))
        panel.title = "Preferences"
        NSApp.runModal(for: panel)
    }

    public static func runInTerminal(script: String, runInBackground: Bool = false) {
        if runInBackground {
            _ = try? shellOut(to: script)
            return
        }
        let script = """
        tell application "Terminal"
            do script "\(script)" in front window
            activate
        end tell
        """
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            if let outputString = scriptObject.executeAndReturnError(&error).stringValue {
                print(outputString)
            } else if let error = error {
                print("error: ", error)
            }
        }
    }
}
