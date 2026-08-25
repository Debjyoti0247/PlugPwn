# PlugPwn
PlugPwn emulates a keyboard via a Raspberry Pi Pico (BadUSB-style) to demonstrate physical access attack chains: on insertion, it drives a scripted execution chain (launcher → bypasses UAC → defense-evasion stage → staging and persistence) that establishes a callback to an attacker-controlled C2 listener over mTLS.
