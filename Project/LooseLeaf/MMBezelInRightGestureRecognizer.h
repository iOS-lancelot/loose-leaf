//
//  MMBezelInRightGestureRecognizer.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/24/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "Constants.h"
#import "MMPanGestureDelegate.h"

@interface MMBezelInRightGestureRecognizer : UIGestureRecognizer{
    // direction the user is panning
    MMBezelDirection panDirection;
    CGFloat liftedLeftFingerOffset;
    // use to calculate direction
    CGPoint lastKnownLocation;
    // use to calculate translation
    CGPoint firstKnownLocation;
    
    NSMutableSet* validTouches;

    NSDate* dateOfLastBezelEnding;
    NSInteger numberOfRepeatingBezels;
    
    __weak NSObject<MMPanGestureDelegate>* panDelegate;
    
    UIGestureRecognizerState subState;
}

@property (readonly) NSArray* touches;
@property (nonatomic, weak) NSObject<MMPanGestureDelegate>* panDelegate;
@property (nonatomic, readonly) MMBezelDirection panDirection;
@property (nonatomic, readonly) NSInteger numberOfRepeatingBezels;
@property (nonatomic, readonly) UIGestureRecognizerState subState;
@property (nonatomic, assign) BOOL hasSeenSubstateBegin;

-(CGPoint) translationInView:(UIView*)view;

-(void) resetPageCount;

-(void) cancel;

@end
