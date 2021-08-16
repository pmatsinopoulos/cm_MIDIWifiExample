//
//  ViewController.m
//  MIDIWifiExample
//
//  Created by Panayotis Matsinopoulos on 15/8/21.
//

#import <CoreMIDI/CoreMIDI.h>
#import "ViewController.h"
#import "CheckError.h"

#define DESTINATION_ADDRESS @"192.168.1.12"

@implementation ViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self connectToHost];
}

- (IBAction) handleKeyDown:(id)sender {
  NSInteger note = [sender tag];
  NSLog(@"tag: %d", (Byte)note);
  [self sendNoteOnEvent:(Byte)note
               velocity:127];
}

- (IBAction) handleKeyUp:(id)sender {
  NSInteger note = [sender tag];
  [self sendNoteOffEvent:(Byte)note
                velocity:127];
}

- (void) sendStatus:(Byte)status data1:(Byte)data1 data2:(Byte)data2 {
  MIDIPacketList packetList;
  
  packetList.numPackets = 1;
  packetList.packet[0].length = 3;
  packetList.packet[0].data[0] = status;
  NSLog(@"data 1: %d", data1);
  packetList.packet[0].data[1] = data1;
  packetList.packet[0].data[2] = data2;
  packetList.packet[0].timeStamp = 0;
  
  CheckError(MIDISend(self.outPort, self.destinationEndpoint, &packetList),
             "Sending MIDI messages");
}

- (void) sendNoteOnEvent:(Byte)key velocity:(Byte)velocity {
  [self sendStatus:0x90
             data1:key & 0x7F
             data2:velocity & 0x7F];
}

- (void) sendNoteOffEvent:(Byte)key velocity:(Byte)velocity {
  [self sendStatus:0x80
             data1:key & 0x07
             data2:velocity & 0x07];
}


- (void) connectToHost {
  MIDINetworkHost *host = [MIDINetworkHost hostWithName:@"MyMIDIWifi"
                                                address:DESTINATION_ADDRESS
                                                   port:5004];
  if (!host) {
    NSLog(@"cannot instantinate the MIDINetworkHost");
    return;
  }
  NSLog(@"host: %@, name: %@, netServiceName: %@, netServiceDomain: %@, address: %@, port: %lu",
        host, host.name, host.netServiceName, host.netServiceDomain,
        host.address, host.port);
  
  MIDINetworkConnection *connection = [MIDINetworkConnection connectionWithHost:host];
  if (!connection) {
    NSLog(@"Cannot connect to the MIDI host");
    return;
  }
  NSLog(@"connection: %@", connection);
  
  self.midiSession = [MIDINetworkSession defaultSession];
  if (self.midiSession) {
    NSLog(@"Got MIDI Session");
    
    [self.midiSession addConnection:connection];
    self.midiSession.enabled = YES;
    self.destinationEndpoint = [self.midiSession destinationEndpoint];
    
    MIDIClientRef client;
    CheckError(MIDIClientCreate(CFSTR("MyMIDIWifi Client"), NULL, NULL, &client),
               "Creating the MIDI clien");

    MIDIPortRef outPort;

    CheckError(MIDIOutputPortCreate(client, CFSTR("Output port on my MIDI client"), &outPort),
               "Creating the output port on the MIDI client");
    self.outPort = outPort;
    
    NSLog(@"Got output port");
  }
}


@end
