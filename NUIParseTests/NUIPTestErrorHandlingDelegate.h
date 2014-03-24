//
//  NUIPTestErrorHandlingDelegate.h
//  NUIParse
//
//  Created by Thomas Davie on 05/02/2012.
//  Copyright (c) 2012 In The Beginning... All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NUIParse.h"

@interface NUIPTestErrorHandlingDelegate : NSObject <NUIPTokeniserDelegate, NUIPParserDelegate>

@property (readwrite, assign) BOOL hasEncounteredError;

@end
