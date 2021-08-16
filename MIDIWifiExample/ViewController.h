//
//  ViewController.h
//  MIDIWifiExample
//
//  Created by Panayotis Matsinopoulos on 15/8/21.
//

#import <UIKit/UIKit.h>
#import <CoreMIDI/CoreMIDI.h>

@interface ViewController : UIViewController

@property MIDINetworkSession *midiSession;
@property MIDIEndpointRef destinationEndpoint;
@property MIDIPortRef outPort;

- (IBAction) handleKeyDown:(id)sender;
- (IBAction) handleKeyUp:(id)sender;
@end

