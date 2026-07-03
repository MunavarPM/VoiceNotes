//
//  PlatformRootView.swift (iOS)
//  VoiceNotes
//
//  iOS-specific root wrapper. Kept thin — the dashboard is shared.
//

#if os(iOS)
import SwiftUI

struct PlatformRootView: View {
    var body: some View {
        DashboardView()
    }
}

#Preview {
    PlatformRootView()
}
#endif
