# Q-Learning Accelerator

Q-Learning Accelerator with AXI Interface

## Evaluation

4 Actions, 16 Bit Rewards, 1 pipeline stage, no BRAM

| States | LUTs | FFs | BRAM | DSPs | Frequency |
| ------ | ------ | ------ | ------ | ------ | ------ |
| 16 | 424 | 415 | 0 | 0 | 178MHz |


4 Actions, 16 Bit Rewards, 1 pipeline stage

| States | LUTs | FFs | BRAM | DSPs | Frequency |
| ------ | ------ | ------ | ------ | ------ | ------ |
| 16 | 360 | 351 | 2 | 0 | 141MHz |


4 Actions, 16 Bit Rewards, 3 pipeline stages

| States | LUTs | FFs | BRAM | DSPs | Frequency |
| ------ | ------ | ------ | ------ | ------ | ------ |
| 16 | 359 | 447 | 2 | 0 | 232MHz |
| 262144 | 445 | 475 | 2 | 0 | 211MHz |

### Comparison

Spano with 16 States, 4 Actions and 16 Bit Rewards: 152MHz

QTAccel with 64 States, 4 Actions: 189 MHz 

## TODO

### Important

1. 8 actions
2. Evaluation
3. Paper

### Optional

1. Max Episodes AXI Register (e.g. for comparison to C implementation)
