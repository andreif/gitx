//
//  PBFileChangesTableView.m
//  GitX
//
//  Created by Pieter de Bie on 09-10-08.
//  Copyright 2008 Pieter de Bie. All rights reserved.
//

#import "PBFileChangesTableView.h"
#import "PBGitIndexController.h"

@implementation PBFileChangesTableView

#pragma mark NSTableView overrides

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	if ([self delegate]) {
		NSPoint eventLocation = [self convertPoint: [theEvent locationInWindow] fromView: nil];
		NSInteger rowIndex = [self rowAtPoint:eventLocation];
		[self selectRowIndexes:[NSIndexSet indexSetWithIndex:rowIndex] byExtendingSelection:TRUE];
		return [(PBGitIndexController*)[self delegate] menuForTable: self];
	}

	return nil;
}

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
	return NSDragOperationEvery;
}

#pragma mark NSView overrides

- (void)keyDown:(NSEvent *)theEvent
{
    PBGitIndexController* controller = (PBGitIndexController*)[self delegate];

    bool isUnstagedView = [self tag] == 0;
    bool isStagedView = !isUnstagedView;
    
    bool commandDown = theEvent.modifierFlags & NSCommandKeyMask;
    
    if([theEvent.characters isEqualTo:@"s"] && commandDown && isUnstagedView) {
        NSInteger oldSelectedRowIndex = self.selectedRow;
        [controller stageSelectedFiles];

        // Try to select the file after the one that was just staged, which will have the same index now
        NSInteger rowIndexToSelect = oldSelectedRowIndex;
        if(rowIndexToSelect > self.numberOfRows - 1) {
            rowIndexToSelect = self.numberOfRows - 1;
        }
        

        [self selectRowIndexes:[NSIndexSet indexSetWithIndex:rowIndexToSelect] byExtendingSelection:NO];
    }
    else if([theEvent.characters isEqualTo:@"u"] && commandDown && isStagedView) {
        NSInteger oldSelectedRowIndex = self.selectedRow;
        [controller unstageSelectedFiles];

        // Try to select the file after the one that was just staged, which will have the same index now
        NSInteger rowIndexToSelect = oldSelectedRowIndex;
        if(rowIndexToSelect > self.numberOfRows - 1) {
            rowIndexToSelect = self.numberOfRows - 1;
        }

        [self selectRowIndexes:[NSIndexSet indexSetWithIndex:rowIndexToSelect] byExtendingSelection:NO];

    }
    else {
        [super keyDown:theEvent];     
    }
}

-(BOOL)acceptsFirstResponder
{
    return [self numberOfRows] > 0;
}

-(NSView *)nextKeyView
{
    return [(PBGitIndexController*)[self delegate] nextKeyViewFor:self];
}

-(NSView *)previousKeyView
{
    return [(PBGitIndexController*)[self delegate] previousKeyViewFor:self];
}

@end
