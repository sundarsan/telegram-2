//
//  TGBottomTextAttachment.m
//  Telegram
//
//  Created by keepcoder on 14/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGBottomTextAttachment.h"
#import "TGBottomSignals.h"
#import "MessageReplyContainer.h"
#import "TGAnimationBlockDelegate.h"
#import "TGWebpageAttach.h"
#import "TGForwardContainer.h"
@interface TGBottomTextAttachment ()
@end

@implementation TGBottomTextAttachment

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self =[super initWithFrame:frameRect]) {
        //self.backgroundColor = [NSColor redColor];
    }
    
    return self;
}

-(SSignal *)resignal:(TL_conversation *)conversation animateSignal:(SSignal *)animateSignal {
    
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        return [[TGBottomSignals textAttachment:conversation] startWithNext:^(id next) {
            
            
            TMView *currentView = nil;
            TGInputMessageTemplate *template = [TGInputMessageTemplate templateWithType:TGInputMessageTemplateTypeSimpleText ofPeerId:conversation.peer_id];

            __block BOOL animated = NO;
            
            [animateSignal startWithNext:^(id next) {
                animated = [next boolValue];
            }];
            
            if(self.subviews.count > 0) {
                
                TMView *view = [self.subviews lastObject];
                
                if([view isKindOfClass:[MessageReplyContainer class]] && [next isKindOfClass:[TL_localMessage class]]) {
                    
                    MessageReplyContainer *replyContainer = (MessageReplyContainer *)view;
                    
                    if(replyContainer.replyObject.replyMessage.channelMsgId == template.replyMessage.n_id) {
                        [subscriber putNext:@(view ? 50 : 0)];
                        
                        return;
                    }
                    
                } else if([view isKindOfClass:[TGForwardContainer class]] && [next isKindOfClass:[NSArray class]]) {
                    
                } else if([view isKindOfClass:[TGWebpageAttach class]] && [next isKindOfClass:[TLWebPage class]]) {
                    TGWebpageAttach *webpage = (TGWebpageAttach *)view;
                    
                    if(webpage.webpage.n_id == [(TLWebPage *)next n_id]) {
                        [subscriber putNext:@(view ? 50 : 0)];
                        
                        return;
                    }
                }

               // if(animated) {
                    
//                    [self.subviews enumerateObjectsUsingBlock:^(__kindof NSView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
//                        view.wantsLayer = YES;
//                        
//                        TGAnimationBlockDelegate *delegate = [[TGAnimationBlockDelegate alloc] initWithLayer:view.layer];
//                        
//                        [delegate setCompletion:^(BOOL completed) {
//                            [view removeFromSuperview];
//                        }];
//                        
//                        
//                        
//                        CAAnimation *animation = [TMAnimations fadeWithDuration:0.2 fromValue:1.0 toValue:0.0];
//                        
//                        animation.delegate = delegate;
//                        
//                        [view.layer addAnimation:animation forKey:@"opacity"];
//                    }];
                    
                    
                    
             //   } else {
                    [self removeAllSubviews];
              //  }
                
                
            }
            
            if([next isKindOfClass:[TL_localMessage class]]) { // reply
                
                
                TGReplyObject *replyObject = [[TGReplyObject alloc] initWithReplyMessage:next fromMessage:nil tableItem:nil];
                
                MessageReplyContainer *replyContainer = [[MessageReplyContainer alloc] initWithFrame:NSMakeRect(0, 0 , NSWidth(self.frame), replyObject.containerHeight)];
                
                replyContainer.deleteHandler = ^{
                    
                    [template setReplyMessage:nil save:YES];
                    [template performNotification];
                    
                };
                
                [replyContainer setReplyObject:replyObject];
                
                
                currentView = replyContainer;
                
            } else if([next isKindOfClass:[NSArray class]]) { // forward
                
            } else if([next isKindOfClass:[TL_webPage class]] || [next isKindOfClass:[TL_webPagePending class]]) { // webpage
                TGWebpageAttach *webpage = [[TGWebpageAttach alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.frame), 30) webpage:next link:template.webpage inputTemplate:template];
               
                currentView = webpage;
                
            }
            
            if(currentView) {
                currentView.backgroundColor = self.backgroundColor;
                currentView.autoresizingMask = NSViewWidthSizable;
                
                [currentView setCenteredYByView:self];
                
                [self addSubview:currentView positioned:NSWindowBelow relativeTo:[self.subviews lastObject]];
                
                if(animated) {
                    CABasicAnimation *animation = (CABasicAnimation *) [TMAnimations fadeWithDuration:0.2 fromValue:0.0 toValue:1.0f];
                   
                    [currentView.layer addAnimation:animation forKey:@"opacity"];
                }
                
                
            }
            
            
            [subscriber putNext:@(currentView ? 50 : 0)];
            
        }];
        
    }];
    
    
    
    return nil;
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
}


@end