/*
    This software is distributed under the terms of Pete's Public License version 1.0, a
    copy of which is included with this software in the file "License.html".  A copy can
    also be obtained from http://pete.yandell.com/software/license/ppl-1_0.html
    
    If you did not receive a copy of the license with this software, please notify the
    author by sending e-mail to pete@notahat.com
    
    The current version of this software can be found at http://pete.yandell.com/software
     
    Copyright (c) 2002-2004 Peter Yandell.  All Rights Reserved.
    
    $Id: Patch.h,v 1.5.2.3 2004/01/25 10:10:50 pete Exp $
*/


#import <AppKit/AppKit.h>
#import <CoreMIDI/CoreMIDI.h>

#import <PYMIDI/PYMIDIEndpoint.h>


@interface Patch : NSObject <NSCoding> {
    BOOL			isInLimbo;
    
    BOOL			isEnabled;
    
    PYMIDIEndpoint*	input;
    
    BOOL			shouldFilterChannel;
    unsigned int	channelMask;
    
    BOOL			shouldAllowNotes;
    BOOL			shouldFilterRange;
    Byte			lowestAllowedNote;
    Byte			highestAllowedNote;
    
    BOOL			shouldTranspose;
    int				transposeDistance;
    
    BOOL			shouldRemapChannel;
    int				remappingChannel;
    
    BOOL			shouldTransmitClock;
    
    PYMIDIEndpoint*	output;
}

#pragma mark Initialisation

- (Patch*)initWithInput:(PYMIDIEndpoint*)newInput output:(PYMIDIEndpoint*)newOutput;
- (Patch*)initFromPatch:(Patch*)patch;
- (void)dealloc;

- (id)initWithCoder:(NSCoder*)coder;
- (void)encodeWithCoder:(NSCoder*)coder;

#pragma mark Limbo handling

- (BOOL)isInLimbo;
- (void)banishToLimbo;
- (void)rescueFromLimbo;

#pragma mark Description

- (NSString*)description;

#pragma mark Enabling

- (BOOL)isEnabled;
- (void)setIsEnabled:(BOOL)newIsEnabled;

#pragma mark Input

- (PYMIDIEndpoint*)input;
- (void)setInput:(PYMIDIEndpoint*)newInput;

#pragma mark Filters - Filter channels

- (BOOL)shouldFilterChannel;
- (void)setShouldFilterChannel:(BOOL)newShouldFilterChannel;
- (unsigned int)channelMask;
- (void)setChannelMask:(unsigned int)newChannelMask;

#pragma mark Filters - Remap channels

- (BOOL)shouldRemapChannel;
- (void)setShouldRemapChannel:(BOOL)newShouldRemapChannel;
- (int)remappingChannel;
- (void)setRemappingChannel:(int)newRemappingChannel;

#pragma mark Filters - Allow notes

- (BOOL)shouldAllowNotes;
- (void)setShouldAllowNotes:(BOOL)newShouldAllowNotes;

#pragma mark Filters - Filter range

- (BOOL)shouldFilterRange;
- (void)setShouldFilterRange:(BOOL)newShouldFilterRange;
- (Byte)lowestAllowedNote;
- (void)setLowestAllowedNote:(Byte)newLowestAllowedNote;
- (Byte)highestAllowedNote;
- (void)setHighestAllowedNote:(Byte)newHighestAllowedNote;

#pragma mark Filters - Transpose

- (BOOL)shouldTranspose;
- (void)setShouldTranspose:(BOOL)newShouldTranspose;
- (int)transposeDistance;
- (void)setTransposeDistance:(int)newTransposeDistance;

#pragma mark Filters - Transmit clock

- (BOOL)shouldTransmitClock;
- (void)setShouldTransmitClock:(BOOL)newShouldTransmitClock;

#pragma mark Output

- (PYMIDIEndpoint*)output;
- (void)setOutput:(PYMIDIEndpoint*)newOutput;

#pragma mark MIDI packet handling

- (void)processMIDIPacketList:(const MIDIPacketList*)packetList sender:(id)sender;

@end
