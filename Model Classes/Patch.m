/*
    This software is distributed under the terms of Pete's Public License version 1.0, a
    copy of which is included with this software in the file "License.html".  A copy can
    also be obtained from http://pete.yandell.com/software/license/ppl-1_0.html
    
    If you did not receive a copy of the license with this software, please notify the
    author by sending e-mail to pete@notahat.com
    
    The current version of this software can be found at http://pete.yandell.com/software
     
    Copyright (c) 2002-2004 Peter Yandell.  All Rights Reserved.
    
    $Id: Patch.m,v 1.7.2.3 2004/01/25 10:03:13 pete Exp $
*/


#import "Patch.h"

#import <PYMIDI/PYMIDI.h>



@interface Patch (private)

- (NSString*)channelFilterDescription;
- (NSString*)noteFilterDescription;
- (NSString*)clockDescription;

- (unsigned int)processMIDIMessage:(Byte*)message ofLength:(unsigned int)length;

@end



@implementation Patch



#pragma mark Initialisation


- (Patch*)initWithInput:(PYMIDIEndpoint*)newInput output:(PYMIDIEndpoint*)newOutput
{
    isInLimbo = YES;
    
    input  = [newInput retain];
    [input addReceiver:self];
    
    shouldFilterChannel = NO;
    channelMask         = 0;

    shouldRemapChannel	= NO;
    remappingChannel	= 1;
        
    shouldAllowNotes	= YES;
    shouldFilterRange	= NO;
    lowestAllowedNote	= 0;
    highestAllowedNote	= 127;
    
    shouldTranspose		= NO;
    transposeDistance	= 0;
    
    shouldTransmitClock = NO;
    
    output = [newOutput retain];
    [output addSender:self];
    
    isEnabled = YES;
    
    return self;
}


- (Patch*)initFromPatch:(Patch*)patch
{
    BOOL useNextMIDIChannel = NO;
    
    [self initWithInput:[patch input] output:[patch output]];
    
    if ([patch shouldFilterChannel]) {
        [self setShouldFilterChannel:YES];
        channelMask = [patch channelMask];
    }
    
    [self setShouldAllowNotes:[patch shouldAllowNotes]];
    
    if ([patch shouldFilterRange]) {
        [self setShouldFilterRange:YES];
        if ([patch highestAllowedNote] < 127)
            [self setLowestAllowedNote:[patch highestAllowedNote] + 1];
        useNextMIDIChannel = YES;
    }
    
    if ([patch shouldRemapChannel]) {
        [self setShouldRemapChannel:YES];
        // *** Need to bounds check this:
        if (useNextMIDIChannel)
            [self setRemappingChannel:[patch remappingChannel] + 1];
        else
            [self setRemappingChannel:[patch remappingChannel]];
    }

    return self;
}


- (void)dealloc
{
    [input removeReceiver:self];
    [input  release];
    
    [output removeSender:self];
    [output release];
    
    [super dealloc];
}


- (id)initWithCoder:(NSCoder*)coder
{
    self = [self
        initWithInput:[coder decodeObjectForKey:@"Input"]
        output:[coder decodeObjectForKey:@"Output"]
    ];
    
    isEnabled = [coder decodeBoolForKey:@"IsEnabled"];
    
    shouldFilterChannel = [coder decodeBoolForKey:@"ShouldFilterChannel"];
    channelMask = [coder decodeIntForKey:@"ChannelMask"];
    shouldRemapChannel = [coder decodeBoolForKey:@"ShouldRemapChannel"];
    remappingChannel = [coder decodeIntForKey:@"RemappingChannel"];
    
    shouldAllowNotes = [coder decodeBoolForKey:@"ShouldAllowNotes"];
    shouldFilterRange = [coder decodeBoolForKey:@"ShouldFilterRange"];
    lowestAllowedNote = [coder decodeIntForKey:@"LowestAllowedNote"];
    highestAllowedNote = [coder decodeIntForKey:@"HighestAllowedNote"];
    shouldTranspose = [coder decodeBoolForKey:@"ShouldTranspose"];
    transposeDistance = [coder decodeIntForKey:@"TransposeDistance"];
    
    shouldTransmitClock = [coder decodeBoolForKey:@"ShouldTransmitClock"];
    
    return self;
}


- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeBool:isEnabled forKey:@"IsEnabled"];
    
    [coder encodeObject:input forKey:@"Input"];
    
    [coder encodeBool:shouldFilterChannel forKey:@"ShouldFilterChannel"];
    [coder encodeInt:channelMask forKey:@"ChannelMask"];
    [coder encodeBool:shouldRemapChannel forKey:@"ShouldRemapChannel"];
    [coder encodeInt:remappingChannel forKey:@"RemappingChannel"];
    
    [coder encodeBool:shouldAllowNotes forKey:@"ShouldAllowNotes"];
    [coder encodeBool:shouldFilterRange forKey:@"ShouldFilterRange"];
    [coder encodeInt:lowestAllowedNote forKey:@"LowestAllowedNote"];
    [coder encodeInt:highestAllowedNote forKey:@"HighestAllowedNote"];
    [coder encodeBool:shouldTranspose forKey:@"ShouldTranspose"];
    [coder encodeInt:transposeDistance forKey:@"TransposeDistance"];
    
    [coder encodeBool:shouldTransmitClock forKey:@"ShouldTransmitClock"];
    
    [coder encodeObject:output forKey:@"Output"];
}



#pragma mark Limbo handling

// Patches can be marked as being in limbo when they're no longer in use
// but still need to be kept around. The standard case where this happens
// is a patch that has been deleted from a document but still exists within
// the undo manager's stack.
//
// When a patch is in limbo it doesn't transmit any data.

- (BOOL)isInLimbo
{
    return isInLimbo;
}

- (void)banishToLimbo
{
    isInLimbo = YES;
}

- (void)rescueFromLimbo
{
    isInLimbo = NO;
}



#pragma mark Description


- (NSString*)description
{
    NSMutableArray* parts = [NSMutableArray arrayWithCapacity:0];
    NSString* description;
    
    description = [self channelFilterDescription];
    if (description != nil) [parts addObject:description];

    description = [self noteFilterDescription];
    if (description != nil) [parts addObject:description];
    
    description = [self clockDescription];
    if (description != nil) [parts addObject:description];
    
    return [parts componentsJoinedByString:@"; "];
}


- (NSString*)channelFilterDescription
{
    NSString* description;
    
    NSMutableArray* parts = [NSMutableArray arrayWithCapacity:0];
    int i;
    int groupLow;
    int groupHigh;
    BOOL hasPlural = NO;

    if (shouldFilterChannel) {
        i = 0;
        while (i < 16) {
            while (i < 16 && ((channelMask >> i) & 1) == 0) i++;
            groupLow = i;
            
            while (i < 16 && ((channelMask >> i) & 1) == 1) i++;
            groupHigh = i - 1;
            
            switch (groupHigh - groupLow + 1) {
            case 0:
                break;
                
            case 1:
                [parts addObject:[NSString stringWithFormat:@"%d", groupLow + 1]];
                break;
                
            default:
                [parts addObject:[NSString stringWithFormat:@"%d-%d", groupLow + 1, groupHigh + 1]];
                hasPlural = 1;
                break;
            }
        }
        
        if (hasPlural || [parts count] > 1) {
            description = [NSString stringWithFormat:@"channels %@", [parts componentsJoinedByString:@", "]];
        }
        else if ([parts count] > 0) {
            description = [NSString stringWithFormat:@"channel %@", [parts objectAtIndex:0]];
        }
        else {
            description = @"no channels";
        }
    }
    else
        description = @"all channels";
        
    if (shouldRemapChannel) {
        description = [NSString stringWithFormat:@"%@ %C channel %d", description, 0x2192, (int)remappingChannel];
    }

    return description;
}


- (NSString*)noteFilterDescription
{
	PYMIDIManager* manager = [PYMIDIManager sharedInstance];

    NSString* description;
    
    if (!shouldAllowNotes) {
        return nil;
    }
    else if (shouldFilterRange) {
        description = [NSString stringWithFormat:@"notes %@-%@",
            [manager nameOfNote:lowestAllowedNote], 
            [manager nameOfNote:highestAllowedNote]
        ];
    }
    else
        description = @"all notes";

    if (shouldTranspose) {
        description = [NSString stringWithFormat:@"%@ transpose %+d",
            description,
            (int)transposeDistance
        ];
    }

    return description;
}


- (NSString*)clockDescription
{
    if (shouldTransmitClock)
        return @"clock";
    else
        return nil;
}



#pragma mark Enabling


- (BOOL)isEnabled
{
    return isEnabled;
}

- (void)setIsEnabled:(BOOL)newIsEnabled
{
    isEnabled = newIsEnabled;
}



#pragma mark Input


- (PYMIDIEndpoint*)input
{
    return input;
}


- (void)setInput:(PYMIDIEndpoint*)newInput
{
    [input removeReceiver:self];
    
    [input autorelease];
    input = [newInput retain];
    
    [input addReceiver:self];
}



#pragma mark Filters - Filter channels


- (BOOL)shouldFilterChannel
{
    return shouldFilterChannel;
}

- (void)setShouldFilterChannel:(BOOL)newShouldFilterChannel
{
    shouldFilterChannel = newShouldFilterChannel;
}

- (unsigned int)channelMask
{
    return channelMask;
}

- (void)setChannelMask:(unsigned int)newChannelMask
{
    channelMask = newChannelMask;
}



#pragma mark Filters - Remap channels


- (BOOL)shouldRemapChannel
{
    return shouldRemapChannel;
}

- (void)setShouldRemapChannel:(BOOL)newShouldRemapChannel
{
    shouldRemapChannel = newShouldRemapChannel;
}

- (int)remappingChannel
{
    return remappingChannel;
}

- (void)setRemappingChannel:(int)newRemappingChannel
{
    remappingChannel = newRemappingChannel;
}




#pragma mark Filters - Allow notes


- (BOOL)shouldAllowNotes
{
    return shouldAllowNotes;
}

- (void)setShouldAllowNotes:(BOOL)newShouldAllowNotes
{
    shouldAllowNotes = newShouldAllowNotes;
}



#pragma mark Filters - Filter range


- (BOOL)shouldFilterRange
{
    return shouldFilterRange;
}

- (void)setShouldFilterRange:(BOOL)newShouldFilterRange
{
    shouldFilterRange = newShouldFilterRange;
}

- (Byte)lowestAllowedNote
{
    return lowestAllowedNote;
}

- (void)setLowestAllowedNote:(Byte)newLowestAllowedNote
{
    lowestAllowedNote = newLowestAllowedNote;
}

- (Byte)highestAllowedNote
{
    return highestAllowedNote;
}

- (void)setHighestAllowedNote:(Byte)newHighestAllowedNote
{
    highestAllowedNote = newHighestAllowedNote;
}



#pragma mark Filters - Transpose


- (BOOL)shouldTranspose
{
    return shouldTranspose;
}

- (void)setShouldTranspose:(BOOL)newShouldTranspose
{
    shouldTranspose = newShouldTranspose;
}

- (int)transposeDistance
{
    return transposeDistance;
}

- (void)setTransposeDistance:(int)newTransposeDistance
{
    transposeDistance = newTransposeDistance;
}



#pragma mark Filters - Transmit clock


- (BOOL)shouldTransmitClock
{
    return shouldTransmitClock;
}

- (void)setShouldTransmitClock:(BOOL)newShouldTransmitClock
{
    shouldTransmitClock = newShouldTransmitClock;
}



#pragma mark Output


- (PYMIDIEndpoint*)output
{
    return output;
}


- (void)setOutput:(PYMIDIEndpoint*)newOutput
{
    [output removeSender:self];
    
    [output autorelease];
    output = [newOutput retain];
    
    [output addSender:self];
}



#pragma mark MIDI packet handling


BOOL isDataByte (Byte b)		{ return b < 0x80; }
BOOL isStatusByte (Byte b)		{ return b >= 0x80 && b < 0xF8; }
BOOL isRealtimeByte (Byte b)	{ return b >= 0xF8; }


unsigned int
midiPacketListSize (const MIDIPacketList* packetList)
{
    const MIDIPacket*	packet;
    int					i;
    
    packet = &packetList->packet[0];
    for (i = 0; i < packetList->numPackets; i++)
        packet = MIDIPacketNext (packet);
        
    return (void*)packet - (void*)packetList;
}


unsigned int
findEndOfMessage (const MIDIPacket* packet, unsigned int startIndex)
{
    unsigned int i;
    
    // Look for the status byte of the next message, or the end of the packet
    for (i = startIndex + 1; i < packet->length && !isStatusByte (packet->data[i]); i++);
        
    // Skip backwords over any realtime data at the end of the packet
    while (isRealtimeByte (packet->data[--i]));
    
    return i;
}


- (void)processMIDIPacketList:(const MIDIPacketList*)inPacketList sender:(id)sender
{
    NSMutableData*		data;
    MIDIPacketList*		outPacketList;
    const MIDIPacket*	inPacket;
    MIDIPacket*			outPacket;
    int					i, j;
    int					messageStart, messageEnd;
    int					outMessageStart;
    int					outMessageLength;
    
    if (isInLimbo || !isEnabled) return;
    
    // Uncomment the following lines to disable all the filtering for
    // debugging purposes.
    //[output processMIDIPacketList:inPacketList sender:self];
    //return;

    data = [NSMutableData dataWithLength:midiPacketListSize (inPacketList)];
    outPacketList = (MIDIPacketList*)[data mutableBytes];
    
    outPacketList->numPackets = 0;
    
    inPacket = &inPacketList->packet[0];
    outPacket = &outPacketList->packet[0];
    for (i = 0; i < inPacketList->numPackets; i++) {
        outPacket->timeStamp = inPacket->timeStamp;
        outPacket->length = 0;
        
        // First we skip over any SysEx continuation at the start of the packet
        // and simply copy it to the output packet without changing it.
        for (j = 0; j < inPacket->length && !isStatusByte (inPacket->data[j]); j++) {
            if (shouldTransmitClock || !isRealtimeByte (inPacket->data[j]))
                outPacket->data[outPacket->length++] = inPacket->data[j];
        }
        
        // Now we loop over the remaining MIDI messages in the packet
        messageStart = j;
        while (messageStart < inPacket->length) {
            messageEnd = findEndOfMessage (inPacket, messageStart);
            
            // Copy any realtime bytes in this message to the new packet
            if (shouldTransmitClock) {
                for (j = messageStart; j <= messageEnd; j++) {
                    if (isRealtimeByte (inPacket->data[j]))
                        outPacket->data[outPacket->length++] = inPacket->data[j];
                }
            }
            
            // Save our starting place in the output packet
            outMessageStart = outPacket->length;
            
            // Copy across everything in this message that's not a realtime byte to the new packet
            for (j = messageStart; j <= messageEnd; j++) {
                if (!isRealtimeByte (inPacket->data[j]))
                    outPacket->data[outPacket->length++] = inPacket->data[j];
            }
            
            // Process the message with all our fabulous filters
            outMessageLength = outPacket->length - outMessageStart;
            outMessageLength = [self processMIDIMessage:&outPacket->data[outMessageStart] ofLength:outMessageLength];
            outPacket->length = outMessageStart + outMessageLength;
                        
            // Copy over any realtime bytes following this message
            for (j = messageEnd + 1; j < inPacket->length && !isStatusByte (inPacket->data[j]); j++) {
                if (shouldTransmitClock)
                    outPacket->data[outPacket->length++] = inPacket->data[j];
            }
            
            // Set the start of the next message to be where we finished up
            messageStart = j;
        }
        
        // If we generated an output packet then add it to the list
        if (outPacket->length > 0) {
            outPacketList->numPackets++;
            outPacket = MIDIPacketNext (outPacket);
        }
        
        inPacket = MIDIPacketNext (inPacket);
    }
    
    // Pass the new packet list out for processing
    if (outPacketList->numPackets > 0)
        [output processMIDIPacketList:outPacketList sender:self];
}


- (unsigned int)processMIDIMessage:(Byte*)message ofLength:(unsigned int)length
{
    // If this is a system message we don't touch it
    if (message[0] >= 0xF0) return length;
    
    // Process for channel filtering
    if (shouldFilterChannel) {
        int channel = message[0] & 0x0F;
        if (((channelMask >> channel) & 1) == 0) return 0;
    }
    
    // Process for note blocking
    // (Note that we block channel pressure and pitch bend messages too)
    if (!shouldAllowNotes && (message[0] < 0xB0 || message[0] >= 0xD0)) {
        return 0;
    }
    
    // Process for range filtering
    if (shouldFilterRange && message[0] < 0xB0) {
        int i, j;
        j = 1;
        for (i = 1; i < length; i += 2) {
            if (message[i] >= lowestAllowedNote && message[i] <= highestAllowedNote) {
                message[j]   = message[i];
                message[j+1] = message[i+1];
                j += 2;
            }
        }
        length = j;
        
        if (length == 1) return 0;
    }
    
    // Process for transposition
    if (shouldTranspose && message[0] < 0xB0) {
        int i, j;
        j = 1;
        for (i = 1; i < length; i += 2) {
            int note = (int)message[i] + transposeDistance;
            if (note >= 0 && note <= 127) {
                message[j] = note;
                message[j+1] = message[i+1];
                j += 2;
            }
        }
        length = j;
        
        if (length == 1) return 0;
    }
        
    // Processing for channel remapping
    if (shouldRemapChannel) {
        message[0] = (message[0] & 0xF0) | (remappingChannel - 1);
    }
    
    return length;
}







/*
    copy over any sysex and realtime data at the start of the packet
    for each message in the packet:
        find the status byte of the next message
        skip backwards over any realtime data to find the last data byte of this message
        
        copy across any realtime data embedded in this message
        process the message itself and copy it across if necessary
        
        copy across any realtime data at the tail of this message
*/

        
/*
    Assumptions:
        - a packet may have sysex continuation data at it's beginning, which means no status byte
          (although there may be realtime bytes before the first data byte)
        - moving realtime bytes that are embedded in message to immediately before those messages
          will have no effect
*/


@end
