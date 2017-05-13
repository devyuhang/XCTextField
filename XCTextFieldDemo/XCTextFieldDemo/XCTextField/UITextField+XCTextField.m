//
//  UITextField+XCTextField.m
//  XCTextFieldDemo
//
//  Created by xenon on 17/5/12.
//  Copyright © 2017年 Code 1 Bit Co.,Ltd. All rights reserved.
//

#import "UITextField+XCTextField.h"
#import <objc/runtime.h>

@interface UITextField ()
/// @brief To save the origin layer.borderColor;
@property (readwrite, nonatomic) CGColorRef borderColor;
/// @brief To save the origin layer.borderWidth;
@property (readwrite, nonatomic) CGFloat borderWidth;
/// @brief To save the origin layer.cornerRadius;
@property (readwrite, nonatomic) CGFloat cornerRadius;
/// @brief When correct is true, border color will not change again.
@property (readwrite, nonatomic) BOOL correct;
@end

@implementation UITextField (XCTextField)
@dynamic fieldType;
@dynamic checkResult;

#pragma mark - Initialiaze Configuration
- (void)configurationWithType:(XCTextFieldType)type {
    
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    /*!
     @todo HOW can I use only one enum property to control this TF?
     */
    self.fieldType = type;
    
    // Disable Apple auto suggestion as default.
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.spellCheckingType = UITextSpellCheckingTypeNo;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    
    // Give self a default type, if user does NOT setup.
    if (!self.layer.borderColor) {
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    if (!self.layer.borderWidth) {
        self.layer.borderWidth = 1.5f;
    }
    if (!self.layer.cornerRadius) {
        self.layer.cornerRadius = self.frame.size.height / 7.5f;
    }
    
    // Save the origin border style.
    self.cornerRadius = self.layer.cornerRadius;
    self.borderWidth = self.layer.borderWidth;
    self.borderColor = self.layer.borderColor;
    
    // Configure each type as well.
    switch (type) {
        case XCTextFieldTypeCellphone: {
            self.keyboardType  = UIKeyboardTypePhonePad;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
            self.textContentType = UITextContentTypeTelephoneNumber;
#endif
            break;
        }
        case XCTextFieldTypePassword: {
            self.secureTextEntry = YES;
            self.keyboardType = UIKeyboardTypeASCIICapable;
            break;
        }
        case XCTextFieldTypeEmail: {
            self.keyboardType = UIKeyboardTypeEmailAddress;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
            self.textContentType = UITextContentTypeEmailAddress;
#endif
            break;
        }
        case XCTextFieldTypeCAPTCHA: {
            self.keyboardType = UIKeyboardTypeNamePhonePad;
            break;
        }
        case XCTextFieldTypeCreditCard: {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
            self.textContentType = UITextContentTypeCreditCardNumber;
#else
            self.keyboardType = UIKeyboardTypeNumberPad;
#endif
            break;
        }
        case XCTextFieldTypeIDCard: {
            self.keyboardType = UIKeyboardTypeNamePhonePad;
            break;
        }
        default: {
            // default type.
            break;
        }
    }
}


#pragma mark - Public method

- (void)inputCheckForceCorrect:(BOOL)flag {
    
    // Check the text according to the rules.
    
    if (!self.text.length) {
        // Verfy empty string.
        self.checkResult = [NSString stringWithFormat:@"%@, Empty textField.", self];
        [self incorrectAnimation];
        !flag ? : [self becomeFirstResponderWhenFirstIncorrect];
        return;
    }
    
    // Rules:
    switch (self.fieldType) {
        case XCTextFieldTypeEmail: {
            [self emailCheck];
            break;
        }
        case XCTextFieldTypeIDCard: {
            [self IDCardCheck];
            break;
        }
        case XCTextFieldTypePassword: {
            [self passwordCheck];
            break;
        }
        default: {
            self.correct ? : [self correctAnimation];
            break;
        }
    }
    
    !flag ? : [self becomeFirstResponderWhenFirstIncorrect];
}


#pragma mark - #### BEGIN Properties setter getter ####
- (void)setFieldType:(XCTextFieldType)newFieldType {
    objc_setAssociatedObject(self,
                             @selector(fieldType),
                             @(newFieldType),
                             OBJC_ASSOCIATION_ASSIGN);
}

- (XCTextFieldType)fieldType {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setCheckResult:(NSString *)newCheckResult {
    objc_setAssociatedObject(self,
                             @selector(checkResult),
                             newCheckResult,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)checkResult {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBorderColor:(CGColorRef)newBorderColor {
    objc_setAssociatedObject(self,
                             @selector(borderColor),
                             CFBridgingRelease(CGColorCreateCopy(newBorderColor)),
                             OBJC_ASSOCIATION_ASSIGN);
}

- (CGColorRef)borderColor {
    return (__bridge CGColorRef)(objc_getAssociatedObject(self, _cmd));
}

- (void)setBorderWidth:(CGFloat)newBorderWidth {
    objc_setAssociatedObject(self,
                             @selector(borderWidth),
                             @(newBorderWidth),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)borderWidth {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setCornerRadius:(CGFloat)newCornerRadius {
    objc_setAssociatedObject(self,
                             @selector(cornerRadius),
                             @(newCornerRadius),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)cornerRadius {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setCorrect:(BOOL)correct {
    objc_setAssociatedObject(self,
                             @selector(correct),
                             @(correct),
                             OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)correct {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

#pragma mark #### END Properties setter getter ####
#pragma mark -

#pragma mark - Field Animation
- (void)correctAnimation {
    
    NSLog(@"get radius = %f", self.cornerRadius);
    NSLog(@"get width = %f", self.borderWidth);
    NSLog(@"get color = %@", self.borderColor);
    
    self.correct = YES;
    self.checkResult = @"Correct textField.";
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:1.5f animations:^{
            self.layer.borderColor = [[UIColor greenColor] CGColor];
            self.layer.borderWidth = self.layer.borderWidth ? : 0.5f;
            self.layer.cornerRadius = self.layer.cornerRadius ? : self.frame.size.height / 7.5;
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(1.5 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                           self.layer.borderColor = self.borderColor;
                           self.layer.borderWidth = self.borderWidth;
                           self.layer.cornerRadius = self.cornerRadius;
        });
    });
    
}

- (void)incorrectAnimation {
    NSLog(@"%zi", self.fieldType);
    self.correct = NO;
    [UIView animateWithDuration:0.9f animations:^{
        self.layer.borderColor = [[UIColor redColor] CGColor];
        self.layer.borderWidth = self.layer.borderWidth ? : 0.5f;
        self.layer.cornerRadius = self.layer.cornerRadius ? : self.frame.size.height / 7.5;
    }];
}

#pragma mark - Field Action
- (void)becomeFirstResponderWhenFirstIncorrect {
    
    for (UIView *subview in self.superview.subviews) {
        if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)subview;
            if (!textField.correct) {
                [textField becomeFirstResponder];
                break;
            }
        }
    }
    //    [[self class] howCanIUseSelfInClassMethod];
}

#pragma mark - Text Check
- (void)emailCheck {
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    if (![emailTest evaluateWithObject:self.text]) {
        self.checkResult = @"Email Address in invalid format.";
        [self incorrectAnimation];
    } else {
        self.correct ? : [self correctAnimation];
    }
}

- (void)passwordCheck {
    
}

- (void)creditCardCheck {
    /** Luhn algorithm
        @see https://en.wikipedia.org/wiki/Luhn_algorithm
     */
}

- (void)IDCardCheck {
    /**
        @brief 中国大陆居民身份证算法
        地址码: 前六位
        生日期码: 七到十四位
        顺序码: 十五到十七位（17位：奇数为男性，偶数为女性）
        校验码: 最后一位 ISO 7064:1983.MOD 11-2
        前十七位系数: {7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2}
        每位的数字和对应的系数相乘后相加，后对11取余。
        余数对照表: {"1", "0", "X", "9", "8", "7", "6", "5", "4", "3", "2"}
     */
    
    if (self.text.length != 18) {
        [self incorrectAnimation];
        return;
    }
    
    if (checkIDCard(self.text.UTF8String)) {
        self.correct ? : [self correctAnimation];
    } else {
        [self incorrectAnimation];
    }
}

bool checkIDCard(const char *idCardString) {
    
    long long strLen = strlen(idCardString);
    char lastChar = idCardString[strLen - 1];
    int factors[] = {7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2};
    char * retrieve[] = {"1", "0", "X", "9", "8", "7", "6", "5", "4", "3", "2"};
    
    long long sum = 0;
    for (int i = 0; i < strLen - 1; i ++) {
        char c = idCardString[i];
        sum += (c - 48) * factors[i];
    }
    
    int position = sum % 11;
    char code = *retrieve[position];
    
    if (code == lastChar) {
        return true;
    } else {
        return false;
    }
    
}


#pragma mark - Test Method
+ (void)howCanIUseSelfInClassMethod {
    
    /**
     * 一个科学试验：在 + 方法中找到 self 的对象指针。
     *
     */
    
    
    for (UIView *subview in [(__bridge UIView *)class_getProperty([UIView class], "superview") subviews]) {
        if ([subview isKindOfClass:self]) {
            UITextField *textField = (UITextField *)subview;
            if (!textField.correct) {
                [textField becomeFirstResponder];
                break;
            }
        }
    }
    NSLog(@"%@", self);
}

@end
