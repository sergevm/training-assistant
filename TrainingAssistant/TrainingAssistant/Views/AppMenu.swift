//
//  AppMenu.swift
//  TrainingAssistant
//
//  Hamburger menu shown on the primary screens (landing, Today, History),
//  offering one-tap navigation to the Members and Classes screens. Selection
//  is driven by @State + navigationDestination(item:) per the project's
//  navigation convention; the enum is a value type, so it's safe as an item.
//

import SwiftUI

enum MenuDestination: String, Identifiable, CaseIterable {
    case members
    case classes

    var id: String { rawValue }

    var title: String {
        switch self {
        case .members: "Members"
        case .classes: "Classes"
        }
    }

    var systemImage: String {
        switch self {
        case .members: "person.2"
        case .classes: "list.bullet.rectangle"
        }
    }
}

extension View {
    /// Adds the app-wide hamburger menu to this screen's navigation bar.
    func appMenuToolbar() -> some View {
        modifier(AppMenuToolbar())
    }
}

private struct AppMenuToolbar: ViewModifier {
    @State private var menuSelection: MenuDestination?

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        ForEach(MenuDestination.allCases) { destination in
                            Button {
                                menuSelection = destination
                            } label: {
                                Label(destination.title, systemImage: destination.systemImage)
                            }
                        }
                    } label: {
                        Label("Menu", systemImage: "line.3.horizontal")
                    }
                }
            }
            .navigationDestination(item: $menuSelection) { destination in
                switch destination {
                case .members: MembersView()
                case .classes: ClassesView()
                }
            }
    }
}
