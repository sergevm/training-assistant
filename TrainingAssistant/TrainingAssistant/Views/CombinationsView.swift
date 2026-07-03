//
//  CombinationsView.swift
//  TrainingAssistant
//
//  Roster of registered handler-dog combinations, grouped by their current
//  class (with a trailing "Unassigned" group).
//

import SwiftUI
import SwiftData

struct CombinationsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var combinations: [Combination]

    @State private var selectedCombination: Combination?
    @State private var isAddingCombination = false

    var body: some View {
        Group {
            if combinations.isEmpty {
                ContentUnavailableView {
                    Label("No Combinations Yet", systemImage: "pawprint")
                } description: {
                    Text("Register a handler and dog to start tracking who trains in each class.")
                } actions: {
                    Button("Add Combination") { isAddingCombination = true }
                        .buttonStyle(.borderedProminent)
                }
            } else {
                List {
                    ForEach(groupedCombinations, id: \.key) { group in
                        Section(group.title) {
                            ForEach(group.items) { combination in
                                Button {
                                    selectedCombination = combination
                                } label: {
                                    CombinationRow(combination: combination)
                                }
                                .buttonStyle(.plain)
                                .contentShape(Rectangle())
                            }
                            .onDelete { offsets in
                                deleteCombinations(in: group.items, at: offsets)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Combinations")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isAddingCombination = true
                } label: {
                    Label("Add Combination", systemImage: "plus")
                }
            }
        }
        .navigationDestination(item: $selectedCombination) { combination in
            CombinationEditorView(combination: combination)
        }
        .sheet(isPresented: $isAddingCombination) {
            NavigationStack {
                CombinationEditorView()
            }
        }
    }

    /// Combinations grouped by current class name (sorted), with a trailing
    /// "Unassigned" group for combinations with no current class.
    private var groupedCombinations: [(key: UUID?, title: String, items: [Combination])] {
        let grouped = Dictionary(grouping: combinations) { $0.currentClass?.id }

        let assignedGroups = grouped
            .compactMap { key, items -> (key: UUID?, title: String, items: [Combination])? in
                guard let key, let trainingClass = items.first?.currentClass else { return nil }
                return (key, trainingClass.name, items.sorted { $0.handlerFullName < $1.handlerFullName })
            }
            .sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }

        let unassignedItems = (grouped[nil] ?? []).sorted { $0.handlerFullName < $1.handlerFullName }
        let unassignedGroup: [(key: UUID?, title: String, items: [Combination])] =
            unassignedItems.isEmpty ? [] : [(nil, "Unassigned", unassignedItems)]

        return assignedGroups + unassignedGroup
    }

    private func deleteCombinations(in items: [Combination], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(items[index])
        }
        try? modelContext.save()
    }
}

private struct CombinationRow: View {
    let combination: Combination

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(combination.handlerFullName)
            Text(combination.dogName)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        CombinationsView()
    }
    .modelContainer(for: [TrainingClass.self, ScheduleEntry.self, Combination.self], inMemory: true)
}
