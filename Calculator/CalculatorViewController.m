//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Krzysztof Figaj on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController()

@property (nonatomic) BOOL userIsInTheMiddleOfEnteringNumber;
@property (nonatomic, strong) CalculatorBrain *brain;

- (void)appendToHistory:(NSString*)text;
- (void)removeEqualsFromHistoryEnd;

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize history = _history;
@synthesize userIsInTheMiddleOfEnteringNumber = _userIsInTheMiddleOfEnteringNumber;
@synthesize brain = _brain;

- (CalculatorBrain *) brain {
    if (!_brain) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}

- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit  = [sender currentTitle];
    if (self.userIsInTheMiddleOfEnteringNumber && 
        ![@"0" isEqualToString:self.display.text]) { // prevent addng two zeros. 
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text  = digit;
        self.userIsInTheMiddleOfEnteringNumber = YES;
    }
    // once user has pressed digit equals sign must be removed from history label. 
    [self removeEqualsFromHistoryEnd]; 
}

- (IBAction)dotPressed {
    if(self.userIsInTheMiddleOfEnteringNumber) {
        // add only one dot
        NSRange currentDotRange = [self.display.text rangeOfString:@"."];
        if(currentDotRange.location == NSNotFound)
            self.display.text = [self.display.text stringByAppendingString:@"."];
    } else{
        self.display.text = @"0.";
        self.userIsInTheMiddleOfEnteringNumber = YES;
    }
}

- (IBAction)enterPressed {
    NSString  *currentText = self.display.text;
    if([currentText hasSuffix:@"."]){
        // just becasue 0. looks bad in history label.
        currentText = [currentText substringToIndex:[currentText length]-1];
    }
    [self.brain pushOperand:[currentText doubleValue]];
    [self appendToHistory:currentText];
    self.userIsInTheMiddleOfEnteringNumber = NO;
}

- (IBAction)operationPressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringNumber) {
        [self enterPressed];
    }
    
    NSString *operation = [sender currentTitle];
    double result = [self.brain performOperation:operation];
    self.display.text = [[NSString alloc] initWithFormat:@"%g", result];
    // user can press operation button two times so handle this case
    [self removeEqualsFromHistoryEnd]; 
    [self appendToHistory:[operation stringByAppendingString:@" ="]];
    
}

- (void)appendToHistory:(NSString*)text {
    // append string to history label
    NSString *currentHistory = self.history.text;
    // optionally add space between operand and operators
    if([currentHistory length] != 0 && ![currentHistory hasSuffix:@" "]) {
        currentHistory = [currentHistory stringByAppendingString:@" "];
    }
    self.history.text = [currentHistory stringByAppendingString:text];
}

- (void)removeEqualsFromHistoryEnd {
    // conditionaly remove equal sign from the end of the history label.
    if([self.history.text hasSuffix:@"="]) {
        self.history.text = [self.history.text substringToIndex:[self.history.text length]-1];
    }
}

- (IBAction)clearPressed:(id)sender {
    [self.brain clear];
    self.display.text = @"0";
    self.history.text = @"";
    self.userIsInTheMiddleOfEnteringNumber = NO;
}

- (IBAction)backspacePressed:(id)sender {
    if(self.userIsInTheMiddleOfEnteringNumber) {
        NSString* withoutLast = [self.display.text substringToIndex:[self.display.text length]-1];
        if ([withoutLast length] == 0 || [withoutLast isEqualToString:@"-"]) {
            self.display.text = @"0";
            self.userIsInTheMiddleOfEnteringNumber = NO;
        } else {
            self.display.text = withoutLast;
        }
    }
}

- (IBAction)changeSignPressed:(id)sender {
    NSString *currentDisplay = self.display.text;
    if ([currentDisplay doubleValue] == 0.0) {
        // no need to change a sign of zero
        return;
    }
    
    if (self.userIsInTheMiddleOfEnteringNumber) {
        if ([currentDisplay hasPrefix:@"-"]) {
            self.display.text = [currentDisplay substringFromIndex:1];
        } else {
            self.display.text = [@"-" stringByAppendingString:currentDisplay];
        }
    } else {
        [self operationPressed:sender];
    }
}


@end
