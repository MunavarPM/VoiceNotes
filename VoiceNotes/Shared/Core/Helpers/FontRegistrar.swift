//
//  FontRegistrar.swift
//  VoiceNotes
//
//  Registers bundled custom fonts (Inter) at launch. Programmatic
//  registration works on both iOS and macOS without Info.plist entries.
//  If the font files aren't bundled yet, this is a safe no-op and the app
//  falls back to the system font.
//

import Foundation
import CoreText

enum FontRegistrar {
    static func registerBundledFonts() {
        for name in InterFont.fileNames {
            let url = Bundle.main.url(forResource: name, withExtension: "ttf")
                ?? Bundle.main.url(forResource: name, withExtension: "otf")
            guard let url else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
