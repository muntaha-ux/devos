import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    // DevOS is a single-theme light app; lock appearance to Aqua
    self.appearance = NSAppearance(named: .aqua)

    super.awakeFromNib()
  }
}
