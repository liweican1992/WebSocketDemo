

#import "SecondViewController.h"
#import "SocketRocket.h"
#import "NSObject+SRSocket.h"
@interface SecondViewController ()<SRWebSocketDelegate>
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (nonatomic,strong) NSMutableArray * dataArray;
@end

@implementation SecondViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.dataArray = [NSMutableArray array];
    for (int i = 1; i<= 100; i++) {
        NSString *str = [NSString stringWithFormat:@"ws://192.168.1.54:8181"];
        SRWebSocket *socket = [[SRWebSocket alloc]initWithURL:[NSURL URLWithString:str]];
        socket.sockteTag = [NSString stringWithFormat:@"%d",i];
        socket.delegate = self;
        [self.dataArray addObject:socket];
    }
}
- (IBAction)startButtonAction:(UIButton *)sender {
    for (SRWebSocket *socket in self.dataArray) {
        [socket open];
    }
}
- (IBAction)closeButtonAction:(UIButton *)sender {
    for (SRWebSocket *socket in self.dataArray) {
        if (socket.readyState == SR_OPEN) {
            [socket close];
        }
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    
    NSString *str = [NSString stringWithFormat:@"SRWebSocket id = %@ 收到信息 %@",webSocket.sockteTag,message];
    NSLog(@"%@",str);
}
- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    NSString *str = [NSString stringWithFormat:@"打开连接 id= %@",webSocket.sockteTag];
    NSLog(@"%@",str);
    
    //发送
    NSString *tag = webSocket.sockteTag;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (webSocket.readyState != SR_OPEN) {
            NSLog(@"服务未启动 发送失败 Tag = %@",tag);
            return;
        }
        
        [webSocket send:tag];

    });
    
 
}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSString *str = [NSString stringWithFormat:@"连接失败 id= %@",webSocket.sockteTag];
    NSLog(@"%@",str);
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSString *str = [NSString stringWithFormat:@"断开连接 id= %@",webSocket.sockteTag];
    NSLog(@"%@",str);
    webSocket = nil;
}

@end
