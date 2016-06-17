//
//  ViewController.m
//  WebtaskSpike
//
//  Created by Weien Wang on 6/16/16.
//  Copyright © 2016 Weien Wang. All rights reserved.
//

#import "ViewController.h"
#import "JRTranscriptView.h"

@interface ViewController () <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet JRTranscriptView *transcriptView;
@property (strong, nonatomic) IBOutlet UITextField *mainTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.mainTextField becomeFirstResponder];
    self.mainTextField.delegate = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSAttributedString* styledString = [self userAttributedStringWithText:textField.text];
    [self.transcriptView appendAttributedString:styledString];
    textField.text = @"";
    return YES;
}

- (NSAttributedString*) userAttributedStringWithText:(NSString*)text {
    NSString* formattedString = [NSString stringWithFormat:@"\n%@",text];
    NSMutableAttributedString* styledString = [[NSMutableAttributedString alloc] initWithString:formattedString];
    return styledString;
}

- (NSAttributedString*) botAttributedStringWithText:(NSString*)text {
    NSMutableAttributedString* styledString = [[NSMutableAttributedString alloc] initWithString:text];
    NSDictionary* attributes = @{NSForegroundColorAttributeName : [UIColor redColor]};
    [styledString addAttributes:attributes range:NSMakeRange(0, text.length)];
    return styledString;
}



@end
