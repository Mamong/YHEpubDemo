//
//  ZQAVSpeechTool.m
//  ShuWangTongBu
//
//  Created by 肖兆强 on 2018/5/11.
//  Copyright © 2018年 JWZT. All rights reserved.
//

#import "ZQAVSpeechTool.h"
#import <AVFoundation/AVFoundation.h>

@interface ZQAVSpeechTool ()<AVSpeechSynthesizerDelegate>

@property (nonatomic ,strong)AVSpeechSynthesizer *avSpeaker;

@property (nonatomic ,strong)NSArray *paragraphs;

@property (nonatomic ,assign)NSInteger currentParagraphs;


@property (nonatomic ,assign)CGFloat rate;


@end

@implementation ZQAVSpeechTool

// 单例
+(instancetype)shareSpeechTool {
    static ZQAVSpeechTool *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZQAVSpeechTool alloc]init];
    });
    return instance;
}

- (void)speechTextWith:(NSString *)text
{
    if (text.length == 0) {
        return;
    }

    text = [text stringByReplacingOccurrencesOfString:UNICODE_OBJECT_PLACEHOLDER withString:@""];
    _paragraphs = [text componentsSeparatedByString:@"\n"];
    _currentParagraphs = 0;

    //初始化要说出的内容
    [self speechParagraphWith:_paragraphs[_currentParagraphs]];
}

- (void)speechParagraphWith:(NSString *)Paragraph
{
    if (!_avSpeaker) {
        //在iPhone静音模式开启后,声音无法播放,需要打开后台播放
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];

        //初次阅读
        NSUserDefaults *useDef = [NSUserDefaults standardUserDefaults];
        _rate = [useDef floatForKey:@"speechRate"];
        if (!_rate) {
            _rate = 0.5;
        }

        //初始化语音合成器
        _avSpeaker = [[AVSpeechSynthesizer alloc] init];
        _avSpeaker.delegate = self;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"speechParagraph" object:Paragraph];

    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:Paragraph];
    utterance.pitchMultiplier = 1;
    utterance.volume = 1;
    utterance.preUtteranceDelay = 0.5;
    utterance.postUtteranceDelay = 0;

    utterance.rate = _rate;
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    if (!voice) {
        //下载
        return;
    }
    utterance.voice = voice;
    [_avSpeaker speakUtterance:utterance];
}
//切换语速
- (void)changeRate:(CGFloat)rate
{
    _rate = rate;
    NSUserDefaults *useDef = [NSUserDefaults standardUserDefaults];
    [useDef setFloat:rate forKey:@"speechRate"];
    [useDef synchronize];

    [_avSpeaker stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];    //初始化语音合成器
    _avSpeaker = nil;

    //TODO: 不重新读整个段落
    [self speechParagraphWith:_paragraphs[_currentParagraphs]];
}

- (void)pauseSpeech
{
    //暂停朗读
    //AVSpeechBoundaryImmediate 立即停止
    //AVSpeechBoundaryWord    当前词结束后停止
    [_avSpeaker pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}

- (void)continueSpeech
{
    [_avSpeaker continueSpeaking];
    
}

- (void)StopSpeech
{
    //AVSpeechBoundaryImmediate 立即停止
    //AVSpeechBoundaryWord    当前词结束后停止
    [_avSpeaker stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    _avSpeaker = nil;
    [XDSReadManager sharedManager].speeching = NO;
     [[NSNotificationCenter defaultCenter] postNotificationName:@"speechDidStop" object:nil];
}

#pragma mark -
#pragma mark - AVSpeechSynthesizerDelegate
//已经开始
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance{
    NSLog(@"%s",__func__);
    
}
//已经说完
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{
    _currentParagraphs+=1;
    if (_currentParagraphs<_paragraphs.count) {
         //读下一段
        [self speechParagraphWith:_paragraphs[_currentParagraphs]];
    }else{
    
    
    NSInteger currentPage = CURRENT_RECORD.currentPage;
    NSInteger currentChapter = CURRENT_RECORD.currentChapter;
    if (currentPage < CURRENT_RECORD.totalPage - 1) {
        //下一页
        currentPage += 1;
    }else
    {
        if (currentChapter < CURRENT_RECORD.totalChapters - 1) {
            //下一章
            currentChapter += 1;
            currentPage = 0;
        }else
        {
            //全书读完
            [self StopSpeech];
            return;
        }
        
    }
    
    [[XDSReadManager sharedManager] readViewJumpToChapter:currentChapter page:currentPage];
     NSString *content = CURRENT_RECORD.chapterModel.pageStrings[currentPage];
    [self speechTextWith:content];
    
    }
    
}



//已经暂停
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance{
    NSLog(@"%s",__func__);

}
//已经继续说话
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance{
    NSLog(@"%s",__func__);

}
//已经取消说话
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance{
    NSLog(@"%s",__func__);

}
//将要说某段话
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance{
    NSLog(@"%s",__func__);
}

@end
