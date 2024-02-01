#if canImport(AppKit)
import SwiftUI

/// A view that displays a segmented control with menus to support
/// hierarchal navigation of items.
///
/// # Overview
///	You can use a tree picker to display a list of items that can be
///	navigated hierarchically. The tree picker displays a segmented control
///	with menus for items that define children.
///
///	To represent the selection, all involved items are highlighted: the parent
///	item in the segmented control, plus all the parent items in the menus.
///	The appearance of the selected item in the segmented control is controlled
///	by the system, just like all menu items.
///
///	You can also define a handler that is called when the user selects the
///	"Create New" menu for items that allow this.
///
///	# Content
/// To populate the picker, you provide a binding to an array of items
/// that conform to ``TreePickerItem``.
///
/// A simple example of a struct conforming to the protocol looks like this:
///
/// ```swift
/// struct Item: TreePickerItem {
/// 	let id: String
/// 	let label: String
/// 	let children: [Item]
///
///		// Optional, defaults to nil
///		let image: NSImage?
/// 	// Optional, defaults to false
/// 	let supportsAdding: Bool
/// 	// Optional, defaults to nil
/// 	let addItemLabel: String?
/// }
/// ```
///
/// Items define the hierarchy using their `children` property.
/// 
/// The picker will display a segmented control with the top-level items:
/// for each item that has a non-empty array of `children`, a menu will
/// be added with the list of children; each child that has a non-empty array of
/// `children` will create a submenu, and so on.
///
/// # Selection
/// Changing selection in the picker or in one of the menus updates the `selectedItem` picker.
/// The same can be achieved programmatically by updating the value of the same binding.
///
/// Setting the selection to `nil` will cause the picker to deselect all items.
public struct TreePicker<Item: TreePickerItem>: View {
	@Binding var items: [Item]
	@Binding var selectedItem: Item.ID?
	
	var createNewItemHandler: ((Item.ID) -> ())? = nil
	
	/// Create a new picker with the given items and selection.
	///
	/// - parameters:
	/// 	- items: The items to display.
	/// 	- selectedItem: The currently selected item.
	public init(items: Binding<[Item]>, selectedItem: Binding<Item.ID?>) {
		self._items = items
		self._selectedItem = selectedItem
	}
	
	public var body: some View {
		SegmentedControl(
			items: $items,
			selectedItem: $selectedItem,
			createNewItemHandler: createNewItemHandler
		)
	}
}

public extension TreePicker {
	/// Set the closure to be invoked when the create new menu item is selected.
	///
	/// - note: This closure is applicable only for items that return `true` to `allowsAdding`.
	func onCreateNewItem(_ handler: @escaping (Item.ID) -> ()) -> some View {
		var newSelf = self
		newSelf.createNewItemHandler = handler
		return newSelf
	}
}
#endif
