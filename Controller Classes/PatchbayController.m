#import "PatchbayController.h"


@implementation PatchbayController


- (IBAction)visitWebSite:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://notahat.com/midi_patchbay"]];
}


- (IBAction)sendFeedback:(id)sender
{
    NSString* name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    name = [[name componentsSeparatedByString:@" "] componentsJoinedByString:@"%20"];

    NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	version = [[version componentsSeparatedByString:@" "] componentsJoinedByString:@"%20"];
   
    [[NSWorkspace sharedWorkspace] openURL:[NSURL
        URLWithString:[NSString
            stringWithFormat:@"mailto:midi_patchbay@notahat.com?subject=%@%%20%@", name, version
        ]
    ]];
}


@end
