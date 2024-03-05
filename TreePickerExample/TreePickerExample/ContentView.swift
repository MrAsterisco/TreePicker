//
//  ContentView.swift
//  TreePickerExample
//
//  Created by Alessio Moiso on 31.01.24.
//

import SwiftUI
import TreePicker
import MenuItemView

struct Feature: TreePickerItem {
	let id: String
	let label: String
	var children: [Feature]
	
	let supportsAdding: Bool
	let addItemLabel: String?
	
	init(
		id: String,
		label: String,
		children: [Feature] = [],
		supportsAdding: Bool = false,
		addItemLabel: String? = nil
	) {
		self.id = id
		self.label = label
		self.children = children
		self.supportsAdding = supportsAdding
		self.addItemLabel = addItemLabel
	}
}

enum FeatureID: String {
	case	feature1 = "co.mrasteris.LevelPickerExample.feature1",
				feature2 = "co.mrasteris.LevelPickerExample.feature2",
					f2Subfeature1 = "co.mrasteris.LevelPickerExample.feature2.subfeature1",
					f2Subfeature2 = "co.mrasteris.LevelPickerExample.feature2.subfeature2",
				feature3 = "co.mraster.LevelPickerExample.feature3"
}

struct ContentView: View {
	@State private var items: [Feature] = [
		Feature(id: FeatureID.feature1.rawValue, label: "Feature 1"),
		Feature(
			id: FeatureID.feature2.rawValue,
			label: "Feature 2",
			children: [
				Feature(
					id: FeatureID.f2Subfeature1.rawValue,
					label: "F2 - Subfeature 1"
				),
				Feature(
					id: FeatureID.f2Subfeature2.rawValue,
					label: "F2 - Subfeature 2",
					supportsAdding: true,
					addItemLabel: "Create New F2 Subfeature..."
				)
			]
		),
		Feature(
			id: FeatureID.feature3.rawValue,
			label: "Feature 3",
			children: [],
			supportsAdding: true,
			addItemLabel: "Create New F3 Subfeature..."
		)
	]
	
	@State private var selectedFeature: Feature.ID?
	
	@State private var isAddingFeature = false
	@State private var addingToFeature: Feature.ID?
	
	@State private var newFeatureID = ""
	@State private var newFeatureName = ""
	@State private var newFeatureSupportsAddingChildren = false
	
	var body: some View {
		VStack(spacing: 12) {
			Text("Selected Feature:")
				.font(.headline)
			
			Text(selectedFeature ?? "No Selection")
				.font(.subheadline)
			
			Text("Use the picker in the toolbar to navigate and create new features.")
				.font(.caption)
				.foregroundStyle(.secondary)
		}
		.frame(width: 800, height: 600)
		.toolbar {
			TreePicker(
				items: $items,
				selectedItem: $selectedFeature
			)
			.onCreateNewItem { featureId in
				addingToFeature = featureId
				isAddingFeature.toggle()
			}
			.view { item in
				VStack {
					Text(item.id)
						.frame(maxWidth: .infinity, alignment: .leading)
						.font(.headline)
					Text("Click to select me.")
						.font(.caption)
						.foregroundStyle(.secondary)
						.frame(maxWidth: .infinity, alignment: .leading)
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding(4)
			}
			.nativeWrappingView { _ in
				MenuItemView()
			}
			.widthOfSegment { _ in
				120
			}
		}
		.sheet(item: $addingToFeature) { addingToFeature in
			VStack {
				Text("Add new children to \(firstFeature(withID: addingToFeature)?.label ?? "Unknown")")
					.font(.headline)
				
				TextField("ID", text: $newFeatureID)
				TextField("Name", text: $newFeatureName)
				Toggle("Allow creating children", isOn: $newFeatureSupportsAddingChildren)
				
				Spacer()
				
				HStack {
					Button(role: .cancel, action: {
						self.addingToFeature = nil
					}) {
						Text("Cancel")
					}
					
					Button(action: {
						self.addingToFeature = nil
						
						guard
							let featureToAdd = firstFeature(withID: addingToFeature)
						else {
							return
						}
						
						appendOrUpdate(
							feature: .init(
								id: newFeatureID,
								label: newFeatureName,
								supportsAdding: newFeatureSupportsAddingChildren,
								addItemLabel: "Create New \(newFeatureName) Subfeature..."
							),
							to: featureToAdd
						)
						
						if !newFeatureSupportsAddingChildren {
							selectedFeature = newFeatureID
						}
						
						newFeatureID = ""
						newFeatureName = ""
						newFeatureSupportsAddingChildren = false
					}) {
						Text("Add")
					}
				}
			}
			.padding()
		}
	}
}

extension ContentView {
	func firstFeature(withID id: String) -> Feature? {
		return items.flat().first(where: { $0.id == id })
	}
	
	func appendOrUpdate(feature: Feature, to parent: Feature) {
		items = items
			.map { appendOrUpdate(feature: feature, startingFrom: $0, appendingTo: parent) }
	}
	
	func appendOrUpdate(feature: Feature, startingFrom root: Feature, appendingTo expectedParent: Feature) -> Feature {
		var updatedRoot = root
		updatedRoot.children.removeAll()
		
		var isUpdating = false
		
		for child in root.children {
			if child.id == feature.id {
				isUpdating = true
				updatedRoot.children.append(feature)
			} else {
				updatedRoot.children.append(
					appendOrUpdate(
						feature: feature,
						startingFrom: child,
						appendingTo: expectedParent
					)
				)
			}
		}
		
		if !isUpdating && root.id == expectedParent.id {
			updatedRoot.children.append(feature)
		}
		
		return updatedRoot
	}
}

extension String: Identifiable {
	public var id: String { self }
}

extension [Feature] {
	func flat() -> [Feature] {
		self + flatMap { $0.children.flat() }
	}
}

#Preview {
	ContentView()
}
