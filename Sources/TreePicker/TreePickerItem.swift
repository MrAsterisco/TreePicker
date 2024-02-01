//
//  LevelPickerItem.swift
//
//
//  Created by Alessio Moiso on 27.01.24.
//

#if canImport(AppKit)
import AppKit

/// A type that represent an item to be displayed in a ``TreePicker``.
public protocol TreePickerItem: Identifiable, Hashable {
	associatedtype Children: TreePickerItem where ID == Self.ID
	
	/// Get the label.
	var label: String { get }
	/// Get the image.
	var image: NSImage? { get }
	/// Get the children.
	var children: [Children] { get }
	
	/// Get whether new children can be added dynamically.
	var supportsAdding: Bool { get }
	/// Get the label of the menu item that can be used to create new children.
	var addItemLabel: String? { get }
}

public extension TreePickerItem {
	var image: NSImage? { nil }
	var supportsAdding: Bool { false }
	var addItemLabel: String? { nil }
}
#endif
