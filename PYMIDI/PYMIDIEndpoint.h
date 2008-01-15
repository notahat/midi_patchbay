/*
    This software is distributed under the terms of Pete's Public License version 1.0, a
    copy of which is included with this software in the file "License.html".  A copy can
    also be obtained from http://pete.yandell.com/software/license/ppl-1_0.html
    
    If you did not receive a copy of the license with this software, please notify the
    author by sending e-mail to pete@notahat.com
    
    The current version of this software can be found at http://pete.yandell.com/software
     
    Copyright (c) 2002-2004 Peter Yandell.  All Rights Reserved.
    
    $Id: PYMIDIEndpoint.h,v 1.10 2004/01/12 04:24:30 pete Exp $
*/


#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>
#import <AudioToolbox/AudioToolbox.h>


@class PYMIDIEndpointDescriptor;


@interface PYMIDIEndpoint : NSObject <NSCoding> {
    MIDIEndpointRef		midiEndpointRef;
    NSString*			name;
    SInt32				uniqueID;
    NSString*			displayName;
    
    NSMutableSet*		receivers;
    NSMutableSet*		senders;
    // NSMutableSet*    midiControllers;
}


#pragma mark INITIALISATION

- (id)init;
- (id)initWithName:(NSString*)newName uniqueID:(SInt32)newUniqueID;
- (id)initWithMIDIEndpointRef:(MIDIEndpointRef)newMIDIEndpointRef;
- (void)dealloc;

#pragma mark ARCHIVING

- (id)initWithCoder:(NSCoder*)coder;
- (void)encodeWithCoder:(NSCoder*)coder;

- (PYMIDIEndpointDescriptor*)descriptor;


#pragma mark PROPERTIES

/* Resets the name and uniqueID from the MIDIEndpointRef */
- (void)setPropertiesFromMIDIEndpoint;

- (NSString*)name;
- (BOOL)setName:(NSString*)newName;

- (NSString*)displayName;
- (NSComparisonResult)compareByDisplayName:(PYMIDIEndpoint*)endpoint;

- (SInt32)uniqueID;
- (BOOL)setUniqueID:(SInt32)newUniqueID;

- (MIDIEndpointRef)midiEndpointRef;

- (BOOL)isIACBus;

- (BOOL)isOnline;
- (BOOL)isOffline;
- (BOOL)isInUse;
- (BOOL)isOnlineOrInUse;


#pragma mark SENDING & RECEIVING

- (void)addReceiver:(id)receiver;
- (void)removeReceiver:(id)receiver;
- (void)addSender:(id)sender;
- (void)removeSender:(id)sender;
// - (void)connectToMIDIController:(AUMIDIControllerRef)controller;
// - (void)disconnectFromMIDIController:(AUMIDIControllerRef)controller;
- (void)processMIDIPacketList:(const MIDIPacketList*)packetList sender:(id)sender;


#pragma mark IO

/* Override these to do the hard work */
- (BOOL)ioIsRunning;
- (void)startIO;
- (void)stopIO;


@end
