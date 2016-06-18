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
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textFieldToViewBottomConstraint;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    self.mainTextField.hidden = YES;
    
    [self.transcriptView appendAttributedString:[self botAttributedStringWithText:NSLocalizedString(@"Hello", nil)]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.mainTextField becomeFirstResponder];
    self.mainTextField.delegate = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString* cleanString = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (cleanString.length > 0) {
        NSAttributedString* styledString = [self userAttributedStringWithText:textField.text];
        [self.transcriptView appendAttributedString:styledString];
        [self tellWebtaskBot:textField.text callback:^(NSString *reply) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (reply) {
                    NSAttributedString* styledReply = [self botAttributedStringWithText:reply];
                    [self.transcriptView appendAttributedString:styledReply];
                }
                else {
                    NSLog(@"Reply is nil");
                }
            });
        }];
        textField.text = @"";
        return YES;
    }
    else {
        return NO;
    }
}

- (NSAttributedString*) userAttributedStringWithText:(NSString*)text {
    NSString* formattedString = [NSString stringWithFormat:@"\n%@",text];
    NSMutableAttributedString* styledString = [[NSMutableAttributedString alloc] initWithString:formattedString];
    return styledString;
}

- (NSAttributedString*) botAttributedStringWithText:(NSString*)text {
    NSString* formattedString = [NSString stringWithFormat:@"\n%@",text];
    NSMutableAttributedString* styledString = [[NSMutableAttributedString alloc] initWithString:formattedString];
    NSDictionary* attributes = @{NSForegroundColorAttributeName : [UIColor redColor]};
    [styledString addAttributes:attributes range:NSMakeRange(0, text.length+1)];
    return styledString;
}

- (void) tellWebtaskBot:(NSString*)text callback:(void (^)(NSString* reply))callback {
    NSString * escapedString = [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString* fullURLString = [@"https://webtask.it.auth0.com/api/run/wt-weienw-gmail_com-0/wtbot?text="  stringByAppendingString:escapedString];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fullURLString]];
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURLSessionTask* task = [session dataTaskWithRequest:request
                                        completionHandler:^(NSData * _Nullable data,
                                                            NSURLResponse * _Nullable response,
                                                            NSError * _Nullable error) {
                                            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                            if (error) {
                                                NSLog(@"Webtask error is %@", error);
                                                callback(nil);
                                            }
                                            else {
                                                NSString* replyString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                NSString* stringWithoutOutsideQuotes = [[replyString substringFromIndex:1] substringToIndex:[replyString length]-2];
                                                callback(stringWithoutOutsideQuotes);
                                            }
                                        }];
    [task resume];
}

- (void)keyboardWasShown:(NSNotification *)notification {
    self.mainTextField.hidden = NO;
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.textFieldToViewBottomConstraint.constant = keyboardSize.height;
}

@end
