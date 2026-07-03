//
//  PlatformRootView.swift (macOS)
//  VoiceNotes
//
//  macOS-specific root wrapper: sets a sensible minimum window size.
//  The dashboard itself is shared.
//

#if os(macOS)
import SwiftUI

struct PlatformRootView: View {
    var body: some View {
        DashboardView()
            .frame(minWidth: 720, minHeight: 520)
    }
}

#Preview {
    PlatformRootView()
}
#endif
