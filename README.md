# Q-Learning Accelerator

Q-Learning Accelerator with AXI Interface

## Evaltuation

4 Actions, 16 Bit Rewards, 3 pipeline stages

| States | LUTs | FFs | BRAM | DSPs | Frequency |
| ------ | ------ | ------ | ------ | ------ | ------ |
| 16 | 360 | 440 | 0 | 2 | 222MHz |

## Old Evaluation

4 Actions, 16 Bit Rewards, single stage

| States | LUTs | FFs | BRAM | DSPs | Frequency |
| ------ | ------ | ------ | ------ | ------ | ------ |
| 16 | 423 | 415 | 0 | 0 | 166MHz |
| 64 | 429 | 419 | 0 | 0 | 166MHz |
| 256 | 444 | 423 | 0 | 0 | 166MHz |
| 1024 | 460 | 427 | 0 | 0 | 166MHz |


4 Actions, 16 Bit Rewards, 2 pipeline stages

| States | LUTs | FFs | BRAM | DSPs | Frequency |
| ------ | ------ | ------ | ------ | ------ | ------ |
| 16 | 411 | 456 | 0 | 0 | 235MHz+ (possibly up to 250Hz)|
| 64 | 417 | 460 | 0 | 0 | 235MHz+ |
| 1024 | 451 | 468 | 0 | 0 | 235MHz+ |

4 Actions, 16 Bit Rewards, 3 pipeline stages

| States | LUTs | FFs | BRAM | DSPs | Frequency |
| ------ | ------ | ------ | ------ | ------ | ------ |
| 16 | 411 | 456 | 0 | 0 | 300MHz (possibly up to 340MHz)|
| 64 | 435 | 511 | 0 | 0 | 300MHz (possibly up to 340MHz)|
| 1024 | 477 | 519 | 0 | 0 | 300MHz (possibly up to 340MHz)|
| 16384 | 487 | 527 | 0 | 0 | 270MHz |

### Comparison

Spano with 16 States, 4 Actions and 16 Bit Rewards: 152MHz

QTAccel with 64 States, 4 Actions: 189 MHz 

## TODO

### Important


1. Pipelining
2. Evaluation
3. Paper

### Optional

1. Writable Transition- and Reward-Tables
2. Max Episodes AXI Register (e.g. for comparison to C implementation)
