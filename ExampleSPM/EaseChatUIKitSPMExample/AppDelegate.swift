import UIKit
import EaseChatUIKit
import ImageIO
import UniformTypeIdentifiers

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UINavigationController(rootViewController: SmokeViewController())
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

/// Offline integration checks. No chat account, app key, or microphone permission is required.
private final class SmokeViewController: UIViewController {
    private let stack = UIStackView()
    private let localizedText = UILabel()
    private let gifView = GIFAnimatedImageView(frame: .zero)
    private var gifURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "EaseChatUIKit · SPM"
        view.backgroundColor = .systemBackground

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            scroll.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -20),
            stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -40)
        ])

        addText("Offline resource and codec checks. Run the shared test scheme for assertions covering overrides and AMR round trips.")
        addText("Resources: \(Bundle.chatBundle.bundleURL.lastPathComponent)")
        showImages()

        localizedText.numberOfLines = 0
        stack.addArrangedSubview(localizedText)
        let languageButton = UIButton(type: .system)
        languageButton.setTitle("Switch 中文 / English", for: .normal)
        languageButton.addTarget(self, action: #selector(toggleLanguage), for: .touchUpInside)
        stack.addArrangedSubview(languageButton)
        updateLocalization()

        addText("GIF: the square below should alternate blue and orange.")
        stack.addArrangedSubview(gifView)
        gifView.heightAnchor.constraint(equalToConstant: 96).isActive = true
        loadGeneratedGIF()
        checkAMREncoding()
    }

    private func showImages() {
        let names = ["default_avatar", "😄", "audio_play_left_light01", "audio_play_right_dark03"]
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 12
        var missing = [String]()
        for name in names {
            let image = UIImage(named: name, in: .chatBundle, compatibleWith: nil)
            if image == nil { missing.append(name) }
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            row.addArrangedSubview(imageView)
        }
        row.heightAnchor.constraint(equalToConstant: 64).isActive = true
        stack.addArrangedSubview(row)
        addText(missing.isEmpty ? "✓ Avatar, emoji, and voice frames loaded" : "✗ Missing images: \(missing.joined(separator: ", "))")

        let overrideView = UIImageView(image: UIImage(named: "copy"))
        overrideView.contentMode = .scaleAspectFit
        overrideView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        stack.addArrangedSubview(overrideView)
        addText("Host image fixture: red rectangle. The shared tests verify that SDK image lookup uses this override.")
    }

    @objc private func toggleLanguage() {
        Appearance.ease_chat_language = Appearance.ease_chat_language == .Chinese ? .English : .Chinese
        updateLocalization()
    }

    private func updateLocalization() {
        let hostValue = LanguageConvertor.localValue(key: "barrage_long_press_menu_copy")
        let sdkValue = LanguageConvertor.localValue(key: "Sent")
        localizedText.text = "Language: \(Appearance.ease_chat_language.rawValue)\nHost override: \(hostValue)\nSDK string: \(sdkValue)"
    }

    private func loadGeneratedGIF() {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".gif")
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.gif.identifier as CFString, 2, nil) else {
            addText("✗ Could not create GIF fixture")
            return
        }
        CGImageDestinationSetProperties(destination, [
            kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]
        ] as CFDictionary)
        for color in [UIColor.systemBlue, .systemOrange] {
            let image = UIGraphicsImageRenderer(size: CGSize(width: 96, height: 96)).image { context in
                color.setFill()
                context.fill(CGRect(x: 0, y: 0, width: 96, height: 96))
            }
            guard let cgImage = image.cgImage else { continue }
            CGImageDestinationAddImage(destination, cgImage, [
                kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: 0.5]
            ] as CFDictionary)
        }
        guard CGImageDestinationFinalize(destination) else {
            addText("✗ Could not finalize GIF fixture")
            return
        }
        gifURL = url
        gifView.loadGif(from: url.path)
    }

    private func checkAMREncoding() {
        for rate: UInt32 in [8_000, 16_000] {
            var pcm = Data()
            for index in 0..<Int(rate / 5) {
                var sample = Int16(sin(Double(index) * 2 * .pi * 440 / Double(rate)) * 8_000).littleEndian
                withUnsafeBytes(of: &sample) { pcm.append(contentsOf: $0) }
            }
            let wave = makeMono16BitWave(sampleRate: rate, pcm: pcm)
            let encoded = rate == 8_000 ? convert8khzWaveToAMR(wave: wave) : convert16khzWaveToAmr(wave: wave)
            let magic = Data((rate == 8_000 ? "#!AMR\n" : "#!AMR-WB\n").utf8)
            let passed = encoded.map { $0.starts(with: magic) && $0.count > magic.count } ?? false
            addText("\(passed ? "✓" : "✗") AMR \(rate / 1_000) kHz: \(encoded?.count ?? 0) bytes")
        }
        let embedded = Bundle.main.privateFrameworksURL?.appendingPathComponent("AMRCodec.framework/AMRCodec")
        let exists = embedded.map { FileManager.default.fileExists(atPath: $0.path) } ?? false
        addText("\(exists ? "✓" : "✗") AMRCodec.framework embedded in app")
    }

    private func addText(_ text: String) {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.text = text
        stack.addArrangedSubview(label)
    }

    deinit {
        if let gifURL { try? FileManager.default.removeItem(at: gifURL) }
    }
}
