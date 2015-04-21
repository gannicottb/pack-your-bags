//
//  Level.h
//  PackYourBags
//
//  Created by CMU on 3/2/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Level : CCNode
    @property (nonatomic, assign) float timeLimit;
    @property (nonatomic, copy) NSString *title;
@end
