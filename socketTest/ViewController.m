//
//  ViewController.m
//  socketTest
//
//  Created by CC on 16/12/22.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "ViewController.h"
#import "SocketRocket.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
@interface ViewController ()<SRWebSocketDelegate>{
    NSInteger i;
}
@property (nonatomic,strong) SRWebSocket * socket;
@property (nonatomic,strong) NSTimer * pingTimer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    i = 0;
    self.textView.editable = NO;
    self.textView.layoutManager.allowsNonContiguousLayout = NO;

}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    NSString *str = [NSString stringWithFormat:@"收到信息 %@",message];
    self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"%@ \n",str]];
    [_textView scrollRangeToVisible:NSMakeRange(_textView.text.length, 1)];

    NSLog(@" 收到信息： %@",message);
    
}
- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    NSString *str = [NSString stringWithFormat:@"打开连接 %@",webSocket];
    self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"%@ \n",str]];
    [_textView scrollRangeToVisible:NSMakeRange(_textView.text.length, 1)];

    self.openButton.enabled = NO;

    NSLog(@"open %@",webSocket);
    self.pingTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(sendHeart:) userInfo:nil repeats:YES];


}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"连接失败，这里可以实现掉线自动重连，要注意以下几点");
    NSLog(@"1.判断当前网络环境，如果断网了就不要连了，等待网络到来，在发起重连");
    NSLog(@"2.判断调用层是否需要连接，例如用户都没在聊天界面，连接上去浪费流量");
    NSLog(@"3.连接次数限制，如果连接失败了，重试10次左右就可以了，不然就死循环了。或者每隔1，2，4，8，10，10秒重连...f(x) = f(x-1) * 2, (x<5)  f(x)=10, (x>=5)");
    self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"连接失败 \n"]];
    [_textView scrollRangeToVisible:NSMakeRange(_textView.text.length, 1)];

    [self resetSocket];
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"连接断开，清空socket对象，清空该清空的东西，还有关闭心跳！");
    self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"连接断开，清空socket对象，清空该清空的东西，还有关闭心跳！ \n"]];
    [_textView scrollRangeToVisible:NSMakeRange(_textView.text.length, 1)];

    [self resetSocket];
}
- (SRWebSocket *)socket{
    if (!_socket) {
        NSString *str = [NSString stringWithFormat:@"ws://192.168.1.54:8181?ip=%@",[self getIPAddress]];
        _socket = [[SRWebSocket alloc]initWithURL:[NSURL URLWithString:str]];
        _socket.delegate = self;
    }
    return _socket;
}
- (IBAction)sendButtonAction:(UIButton *)sender {
    if (_socket.readyState != SR_OPEN) {
        self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"服务未启动！ \n"]];
        [_textView scrollRangeToVisible:NSMakeRange(_textView.text.length, 1)];

        return;
    }
    i ++;
    NSString *str = @"jiaoxingjia";

//    NSString *str = [NSString stringWithFormat:@"ip:%@ hello world%ld",[self getIPAddress],(long)i];
    [self.socket send:str];
    self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"%@ \n",str]];
    [_textView scrollRangeToVisible:NSMakeRange(_textView.text.length, 1)];


}
- (IBAction)openButtonAction:(id)sender {
    [self.socket open];
}
- (IBAction)closeButtonAction:(id)sender {
    if (_socket.readyState == SR_OPEN) {
        [self.socket close];
    }
}
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
    NSLog(@"%@",pongPayload);
}
#pragma mark -
#pragma mark 心跳包
- (void)sendHeart:(NSTimer *)timer{
//    [_socket sendPing:[NSData dataWithBytes:@"trip" length:5]];
//    self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"发送心跳包❤️ \n"]];
//    [_textView scrollRangeToVisible:NSMakeRange(_textView.text.length, 1)];
}
-(void)resetSocket{
    _socket = nil;
    [self.pingTimer invalidate];
    self.pingTimer = nil;
    self.openButton.enabled = YES;

}
- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

@end
