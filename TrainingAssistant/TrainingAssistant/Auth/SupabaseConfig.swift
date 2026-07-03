//
//  SupabaseConfig.swift
//  TrainingAssistant
//
//  Supabase connection settings, read at runtime from `Supabase-Info.plist`
//  in the app bundle. That file is intentionally not committed (see `.gitignore`);
//  copy `supabase/Supabase-Info.example.plist` into the app target and fill it in.
//
//  The anon/publishable key is safe to ship in a client — row-level security, not
//  key secrecy, protects the data — but we keep it out of source control so each
//  environment (dev/prod) can point at its own Supabase project.
//

import Foundation

struct SupabaseConfig {
    let url: URL
    let anonKey: String
    /// Optional deep-link the browser-based OAuth flow (Google) returns to.
    /// Must also be allow-listed in Supabase Auth settings and registered as a URL
    /// scheme in the app's Info tab. `nil` lets the SDK use its default.
    let redirectURL: URL?

    /// Reads the config from `Supabase-Info.plist`. Returns `nil` (rather than
    /// crashing) when the file is missing or malformed, so the app can surface a
    /// clear "not configured" state instead of failing to launch.
    static func load(bundle: Bundle = .main) -> SupabaseConfig? {
        guard
            let plistURL = bundle.url(forResource: "Supabase-Info", withExtension: "plist"),
            let data = try? Data(contentsOf: plistURL),
            let raw = try? PropertyListSerialization.propertyList(from: data, format: nil),
            let dict = raw as? [String: Any],
            let urlString = (dict["SUPABASE_URL"] as? String), !urlString.isEmpty,
            let url = URL(string: urlString),
            let anonKey = (dict["SUPABASE_ANON_KEY"] as? String), !anonKey.isEmpty
        else {
            return nil
        }
        let redirect = (dict["SUPABASE_REDIRECT_URL"] as? String).flatMap(URL.init(string:))
        return SupabaseConfig(url: url, anonKey: anonKey, redirectURL: redirect)
    }
}
