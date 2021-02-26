# Q-Learning Accelerator

Q-Learning Accelerator with AXI Interface


## Evaluation

4 Actions, 16 Bit Rewards

| States | LUTs | FFs | BRAM | DSPs | Frequency |
| ------ | ------ | ------ | ------ | ------ | ------ |
| 16 | 423 | 415 | 0 | 0 | 166MHz |
| 64 | 429 | 419 | 0 | 0 | 166MHz |

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
