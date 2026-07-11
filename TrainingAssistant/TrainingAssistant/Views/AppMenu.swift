//
//  AppMenu.swift
//  TrainingAssistant
//
//  Hamburger menu shown at the top right of the primary screens (landing,
//  Today, History), offering one-tap navigation to the Members and Classes
//  screens plus a confirmed Sign Out. Selection is driven by
//  @State + navigationDestination(item:) per the project's navigation
//  convention; the enum is a value type, so it's safe as an item.
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
    @Environment(AuthService.self) private var authService

    @State private var menuSelection: MenuDestination?
    @State private var showsSignOutConfirmation = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(MenuDestination.allCases) { destination in
                            Button {
                                menuSelection = destination
                            } label: {
                                Label(destination.title, systemImage: destination.systemImage)
                            }
                        }
                        Divider()
                        Button(role: .destructive) {
                            showsSignOutConfirmation = true
                        } label: {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
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
            .confirmationDialog(
                "Sign out of Training Assistant?",
                isPresented: $showsSignOutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Sign Out", role: .destructive) {
                    Task { await authService.signOut() }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Your classes and schedule stay on this device.")
            }
    }
}
