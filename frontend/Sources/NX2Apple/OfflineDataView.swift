import SwiftUI
import AppKit
import NXCore

/// Optional sources are explicitly selected and inspected before packaging.
struct OfflineDataView: View {
    var t: (String) -> String
    @Binding var saveFolder: String
    @Binding var cacheFolder: String
    @State private var summary = ""
    @State private var error = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(t("offline.title")).font(.headline)
            VStack(alignment: .leading, spacing: 12) {
                Text(t("offline.note"))
                    .font(.caption).foregroundStyle(.secondary)
                sourceRow(t("offline.save"), path: $saveFolder, caches: false)
                sourceRow(t("offline.cache"), path: $cacheFolder, caches: true)
                if !summary.isEmpty { Text(summary).font(.caption).foregroundStyle(.secondary) }
                if !error.isEmpty { Text(error).font(.caption).foregroundStyle(.red) }
                Text(t("offline.warning"))
                    .font(.caption).foregroundStyle(.secondary)
            }.padding(16).frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 14))
        }
    }

    private func sourceRow(_ title: String, path: Binding<String>, caches: Bool) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                Text(path.wrappedValue.isEmpty ? t("offline.none") : path.wrappedValue)
                    .font(.caption).foregroundStyle(.secondary).lineLimit(1).truncationMode(.middle)
            }
            Spacer()
            if !path.wrappedValue.isEmpty { Button(t("offline.clear")) { path.wrappedValue = ""; summary = ""; error = "" } }
            Button(t("offline.choose")) { choose(path, caches: caches) }
        }
    }

    private func choose(_ path: Binding<String>, caches: Bool) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            let inventory = try OfflineDataInventory.inspect(url, caches: caches)
            path.wrappedValue = url.path
            summary = "\(inventory.files) files, " + ByteCountFormatter.string(fromByteCount: inventory.bytes, countStyle: .file)
            error = ""
        } catch {
            self.error = error.localizedDescription
        }
    }
}
