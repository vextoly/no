# Use Cases for `no`

`no` is a flexible automation and testing tool. While it looks simple, it is useful in many real-world and playful scenarios.

---

## 1. Default Negative Input Replacement

The most basic use: replacing `yes` with a negative response.

Example:
no

Output:
n
n
n
...

Why:
Some scripts or programs expect repeated input. `no` provides a fast, explicit way to send negative responses.

---

## 2. Custom Repeated Text

no "I disagree"

Use case:
Testing programs that read from stdin, stress-testing input handling, or scripting repetitive output.

---

## 3. Limiting Output with --times / -t

no --times 3

Use case:
Prevent infinite output when piping into commands like head, sed, or logs.

---

## 4. Timed Input with --interval / -i

no --interval 0.5 --times 5

Use case:
Simulating human-like delays for scripts that expect pauses between inputs.

---

## 5. Logging Output with --output / -o

no example -o output.txt --times 5

Use case:
Writing automated responses to files without shell redirection.

---

## 6. Counting Output with --count / -c

no --count --times 3

Output:
1: n
2: n
3: n

Use case:
Debugging, logging, or tracking how many responses were sent.

---

## 7. Randomized Responses with --random / -r

no --random "no,nah,nop,never" --times 4

Use case:
Testing scripts that should handle varying input instead of a fixed value.

---

## 8. Executing Commands Repeatedly (--command / -cmd)

no --command "date" --times 3

Why this exists:
Sometimes you want dynamic output, not static text.

Practical reasons:
- Poll system state (uptime, who, df -h)
- Generate changing data for pipelines
- Replace simple watch-style loops
- Feed live command output into another program

Example with delay:
no --command "uptime" --interval 1

---

## 9. Combining Features

no --command "echo no" --count --interval 0.2 --times 5

Use case:
Demonstrates that no is composable and predictable.

---

## 10. Automation & Testing Tool

Because no:
- Is POSIX sh
- Has no dependencies
- Works in pipes
- Can run infinitely or finitely

It is ideal for CI testing, script mocking, input fuzzing, and terminal demos.

---

## Philosophy

no is intentionally simple.

If yes is optimism,
no is realism.
