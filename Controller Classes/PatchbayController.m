/*
    This software is distributed under the terms of Pete's Public License version 1.0, a
    copy of which is included with this software in the file "License.html".  A copy can
    also be obtained from http://pete.yandell.com/software/license/ppl-1_0.html
    
    If you did not receive a copy of the license with this software, please notify the
    author by sending e-mail to pete@notahat.com
    
    The current version of this software can be found at http://pete.yandell.com/software
     
    Copyright (c) 2002-2004 Peter Yandell.  All Rights Reserved.
    
    $Id: PatchbayController.m,v 1.2.2.1 2004/01/09 13:53:35 pete Exp $
*/


#import "PatchbayController.h"


@implementation PatchbayController


- (IBAction)displayLicense:(id)sender
{
    [[NSWorkspace sharedWorkspace]
        openFile:[[NSBundle mainBundle] pathForResource:@"License" ofType:@"html"]
    ];
}


- (IBAction)visitWebSite:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://notahat.com/"]];
}


- (IBAction)sendFeedback:(id)sender
{
    NSString* name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    name = [[name componentsSeparatedByString:@" "] componentsJoinedByString:@"%20"];

    NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	version = [[version componentsSeparatedByString:@" "] componentsJoinedByString:@"%20"];
   
    [[NSWorkspace sharedWorkspace] openURL:[NSURL
        URLWithString:[NSString
            stringWithFormat:@"mailto:pete@notahat.com?subject=%@%%20%@", name, version
        ]
    ]];
}


@end
