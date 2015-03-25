//
//  Item.m
//  PackYourBags
//
//  Created by CMU on 3/25/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Item.h"

@implementation Item

- (void) onEnter{
    [super onEnter];
    
    self.userInteractionEnabled = YES;

}


- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    
    
}
- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    
}
- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    [self drop];
}
- (void)touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    [self drop];
}

- (BOOL)drop{
    //Do the whole drop algorithm here
}

@end
