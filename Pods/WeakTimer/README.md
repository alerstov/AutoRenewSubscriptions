# WeakTimer

Simplify work with timer.


### Features
- block based
- no retain cycle on self in block
- no need invalidate, timer will be released with self

### Usage
Start
  ```
      WEAK_TIMER_ONCE(seconds, block_body);   // no repeat timer
      WEAK_TIMER_REPEAT(seconds, block_body); // repeat timer
  ```
Stop
  ```
      WEAK_TIMER_STOP(timerToken);        // stop timer with token
      WEAK_TIMER_STOP_ALL();              // stop all timers
  ```

### Examples

1. Start repeat timer, it will be released with self

  ```
  - (void)viewDidLoad {
      [super viewDidLoad];
      
      WEAK_TIMER_REPEAT(1, {
          self.value++;
      });
  }
  ```
  
2. Save timer token to stop timer later manually

  ```
  // @property (nonatomic) id timerToken;
  -(void)viewDidAppear:(BOOL)animated {
      [super viewDidAppear:animated];
      self.timerToken = WEAK_TIMER_ONCE(5, {
          NSLog(@"5 sec elapsed");
      });
  }
  -(void)viewWillDisappear:(BOOL)animated {
      [super viewWillDisappear:animated];
      WEAK_TIMER_STOP(self.timerToken);
  }
  ```
  
  The token is not necessary if only one timer is used or you need stop all timers
  
  ```
  -(void)viewDidAppear:(BOOL)animated {
      [super viewDidAppear:animated];
      WEAK_TIMER_ONCE(5, {
          NSLog(@"5 sec elapsed");
      });
  }
  -(void)viewWillDisappear:(BOOL)animated {
      [super viewWillDisappear:animated];
      WEAK_TIMER_STOP_ALL();
  }
  ```