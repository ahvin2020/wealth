//
//  DataManager.h
//  Wealth
//
//  Created by Tan Kel Vin on 30/12/12.
//  Copyright (c) 2012 Tan Kel Vin. All rights reserved.
//

@interface DataManager : NSObject {
    @private
    NSDictionary *_constantDictionary;
}

#define CONSTANTS_PLIST @"constants.plist"
#define SPRITES_PLIST @"sprites.plist"

- (id) constantForKeyPath:(NSString *)keyPath;
- (NSDictionary *) loadDictionaryFromPlist:(NSString *)name;

@end
