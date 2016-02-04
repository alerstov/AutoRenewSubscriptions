# WeakEvent
Simplify work with events.
Typical usage - events in UI.


## Event creation

```
@interface Button : UIButton
// produce method 'onClick'
EVENT_DECL(Click, id sender);
@end

@implementation Button

EVENT_IMPL(Click)

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)click:(id)sender
{
    EVENT_RAISE(Click, sender);
}

@end
```


## Usage

```
- (void)viewDidLoad {
    
    Button* button = [[Button alloc]initWithFrame:CGRectMake(50, 50, 100, 50)];
    button.backgroundColor = [UIColor grayColor];
    [button setTitle:@"click" forState:UIControlStateNormal];
    [self.view addSubview:button];
    
    // block will be released automatically with self 
    // macros uses weakify/strongify pattern (no retain cycle on 'self')
    // note the comma between block signature and body
    EVENT_ADD(button, onClick:^(id sender), {
        NSLog(@"click 1");
    });
    

    // you can presave the event token to remove event handler before self dies
    self.clickToken = EVENT_ADD(button, onClick:^(id sender), {
        NSLog(@"click 2");
    });
}

- (void)viewWillDisappear {
	        
	EVENT_REMOVE(self.clickToken);

    // or you can remove all event handlers
    // EVENT_REMOVE_ALL();   
}
```