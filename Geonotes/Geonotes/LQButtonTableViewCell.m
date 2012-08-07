//
//  LQButtonTableViewCell.m
//  Geonotes
//
//  Created by Kenichi Nakamura on 8/6/12.
//  Copyright (c) 2012 Geoloqi, Inc. All rights reserved.
//

#import "LQButtonTableViewCell.h"

#define kLQDisabledColor        (194.0/255.0)
#define kLQDisabledShadowOffset CGSizeMake(0.0, 0.0)
#define kLQEnabledShadowOffset  CGSizeMake(0.0, -1.0)

@implementation LQButtonTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setButtonState:(BOOL)enabled
{
    self.button.enabled = enabled;
    if (enabled) {
        self.button.titleLabel.shadowColor = [UIColor colorWithHue:0.0 saturation:0.0 brightness:0.0 alpha:0.4];
        self.button.titleLabel.shadowOffset = kLQEnabledShadowOffset;
    } else {
        self.button.titleLabel.shadowColor = nil;
        self.button.titleLabel.shadowOffset = kLQDisabledShadowOffset;
    }
}

+ (LQButtonTableViewCell *)buttonTableViewCellWithTitle:(NSString *)title owner:(id)owner enabled:(BOOL)enabled target:(id)target selector:(SEL)selector
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LQButtonTableViewCell" owner:owner options:nil];
    LQButtonTableViewCell *btvc = (LQButtonTableViewCell *)[nib objectAtIndex:0];
    
    btvc.selectionStyle = UITableViewCellSelectionStyleNone;

    [btvc.button setTitle:title forState:UIControlStateNormal];
    [btvc.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btvc.button setTitleColor:[UIColor colorWithRed:kLQDisabledColor
                                               green:kLQDisabledColor
                                                blue:kLQDisabledColor
                                               alpha:1.0] forState:UIControlStateDisabled];
    
    btvc.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [btvc setButtonState:enabled];
    [btvc.button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return btvc;
}

@end