# Inter font — drop the files here

The "Ask AI" label uses **Inter**. Add the font files to this folder and
they'll be bundled automatically (this target uses file-system synchronized
groups) and registered at launch by `FontRegistrar`.

Bundled (Google Fonts "Inter", 18pt optical size):

- `Inter_18pt-Regular.ttf`  (PostScript: `Inter18pt-Regular`)
- `Inter_18pt-Medium.ttf`   (PostScript: `Inter18pt-Medium`)
- `Inter_18pt-SemiBold.ttf` (PostScript: `Inter18pt-SemiBold`)
- `Inter_18pt-Bold.ttf`     (PostScript: `Inter18pt-Bold`)

No Info.plist changes are needed — `FontRegistrar.registerBundledFonts()`
registers them programmatically on both iOS and macOS.

Until the files are present, `Font.inter(...)` gracefully falls back to the
system font (SF Pro), so the app still builds and runs.

> The PostScript name must match the filename base (e.g. `Inter-SemiBold`). If
> your copy uses different names, update `InterFont` in `Font+App.swift`.
