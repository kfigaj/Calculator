//
//  CalculatorViewController.h
//  Calculator
//
//  Created by Krzysztof Figaj on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *display; // main display 
@property (weak, nonatomic) IBOutlet UILabel *history; // shows latest description of program
@end
