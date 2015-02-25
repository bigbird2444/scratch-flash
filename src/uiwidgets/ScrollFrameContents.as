/*
 * Scratch Project Editor and Player
 * Copyright (C) 2014 Massachusetts Institute of Technology
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

// ScrollFrameContents.as
// John Maloney, November 2010
//
// A ScrollFrameContents is a resizable container used as the contents of a ScrollFrame.
// It updates its size to include all of its children, ensures that children do not have
// negative positions (which are outside the scroll range), and can have a color or an
// optional background texture. Set hExtra or vExtra to provide some additional empty
// space to the right or bottom of the content.
//
// Note: The client should call updateSize() after adding or removing contents.

package uiwidgets {
import flash.display.*;
import flash.events.Event;

public class ScrollFrameContents extends Sprite {

	public static const SCROLL_X:String = 'scrollX';
	private static const scrollEventX:Event = new Event(SCROLL_X);
	public static const SCROLL_Y:String = 'scrollY';
	private static const scrollEventY:Event = new Event(SCROLL_Y);
	public static const INTERACTION_BEGAN:String = 'interactionBegan';
	private static const interactionBeganEvent:Event = new Event(INTERACTION_BEGAN, true);

	public var color:uint = 0xE0E0E0;
	public var texture:BitmapData;

	// extra padding using in updateSize
	public var hExtra:int = 10;
	public var vExtra:int = 10;

	override public function set x(value:Number):void {
		if (x != value) {
			super.x = value;
			dispatchEvent(scrollEventX);
		}
	}

	override public function set y(value:Number):void {
		if (y != value) {
			super.y = value;
			dispatchEvent(scrollEventY);
		}
	}

	protected function contentInteraction(target:DisplayObject):void {
		target.dispatchEvent(interactionBeganEvent);
	}

	public function clear(scrollToOrigin:Boolean = true):void {
		while (numChildren > 0) removeChildAt(0);
		if (scrollToOrigin) x = y = 0;
	}

	public function setWidthHeight(w:Number, h:Number):void {
		// Draw myself using the texture bitmap, if available, or a solid gray color if not.
		graphics.clear();
		if (texture) graphics.beginBitmapFill(texture)
		else graphics.beginFill(color);
		graphics.drawRect(0, 0, w, h);
		graphics.endFill();
	}

	public function updateSize():void {
		// Make my size a little bigger necessary to subsume all my children.
		// Also ensure that the x and y positions of all children are positive.
		var minX:Number = 5, maxX:Number = 0, minY:Number = 5, maxY:Number = 0;
		var child:DisplayObject, i:int;
		for (i = 0; i < numChildren; i++) {
			child = getChildAt(i);
			minX = Math.min(minX, child.x);
			minY = Math.min(minY, child.y);
			maxX = Math.max(maxX, child.x + child.width);
			maxY = Math.max(maxY, child.y + child.height);
		}
		// Move children, if necessary, to ensure that all positions are positive.
		if ((minX < 0) || (minY < 0)) {
			var deltaX:int = Math.max(0, -minX + 5);
			var deltaY:int = Math.max(0, -minY + 5);
			for (i = 0; i < numChildren; i++) {
				child = getChildAt(i);
				child.x += deltaX;
				child.y += deltaY;
			}
			maxX += deltaX;
			maxY += deltaY;
		}
		maxX += hExtra;
		maxY += vExtra;
		if (parent is ScrollFrame) {
			maxX = Math.max(maxX, ScrollFrame(parent).visibleW() / scaleX - x);
			maxY = Math.max(maxY, ScrollFrame(parent).visibleH() / scaleY - y);
		}
		setWidthHeight(maxX, maxY);
		if (parent is ScrollFrame) (parent as ScrollFrame).updateScrollbarVisibility();
	}

	protected function scrollToChild(item:DisplayObject):void {
		var frame:ScrollFrame = parent as ScrollFrame;
		if (!frame || !item || item.parent != this) return;
		var itemTop:int = item.y + y - 1;
		var itemBottom:int = itemTop + item.height;
		y -= Math.max(0, itemBottom - frame.visibleH());
		y -= Math.min(0, itemTop);
		frame.updateScrollbars();
	}
}}
