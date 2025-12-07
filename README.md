# Crypto Hash Engine with Brute-Force Nonce Search

## Background
Crypto Hash played an important role in modern digital security systems, including blockchain mining. One of the applications is Bitcoin Mining, which uses a Proof-of-Work (PoW) mechanism that requires miners to repeatedly compute hash values until a result smaller than a predefined target is found. In real world, this process is usually implemented using SHA-256 algorithm and is optimised using ASIC hardware. However, implementing full SHA-256 will be too complex at this time.

## How it works
When the start signal is activated, the mining process begins. The system then generates sequential nonce values using a counter. Each nonce is combined with the message and processed by the hash engine. The resulting hash will be compared with the target. If the condition is satisfied, the system will find = 1 and The successful nonce is stored in found_nonce. And if the condition is not satisfied, The nonce continues incrementing and the search will repeat automatically.

## Finite State Machine
<img width="902" height="218" alt="image" src="https://github.com/user-attachments/assets/5f7e7621-2a6e-4581-8cfa-8e7cc4382d3b" />

## Result
<img width="1082" height="632" alt="image" src="https://github.com/user-attachments/assets/b3d7dcb6-1f61-4965-ba45-09fdf0647877" />
<img width="1075" height="596" alt="image" src="https://github.com/user-attachments/assets/37bad365-aa59-427d-abbd-5a1f13c2f4fc" />




