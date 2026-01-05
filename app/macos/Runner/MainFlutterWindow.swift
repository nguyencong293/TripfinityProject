import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    // Check if Metal is available (for VMware compatibility)
    let metalDevice = MTLCreateSystemDefaultDevice()
    
    let flutterViewController: FlutterViewController
    if metalDevice == nil {
      // Running in VM without Metal support - use software rendering
      NSLog("Metal not available, using software rendering")
      let project = FlutterDartProject()
      project.dartEntrypointArguments = ["--enable-software-rendering"]
      flutterViewController = FlutterViewController(project: project)
    } else {
      flutterViewController = FlutterViewController()
    }
    
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
