[Back to readme](https://github.com/ihatemustard/no)

# Use Cases for `no`

`no` is a small but extremely flexible output generator and control utility. It started as the conceptual opposite of the Unix `yes` command, but grows into a general-purpose sequence, formatting, and automation tool that replaces many common shell loops and glue scripts.

---

## Why `no` is Useful

* **Loop replacement:** Eliminates `for`, `while`, and `seq | while read` patterns with a single command.
* **Sequence-native:** Numeric, floating-point, negative, and character sequences are first‑class features.
* **Timing control:** Built-in interval and jitter support without external `sleep` logic.
* **Formatting pipeline:** `printf` formatting, padding, width alignment, prefixes, suffixes, and column layouts are all handled internally.
* **Composable:** Filtering, arithmetic, case transforms, styling, and uniqueness can be layered without pipes.

---

## 1. Default Behavior & Prompt Automation

**Automatically answer "no" to a prompt**

```sh
no | ./install-script.sh
```

By default, `no` outputs `n` repeatedly until the consumer exits.

**Limit responses**

```sh
no -t 3
```

---

## 2. Sequence Generation (`--seq`, `--step`, `--cycle`)

Generate numeric, floating-point, and character ranges.

**Simple countdown**

```sh
no --seq 5:1
```

**Timed countdown**

```sh
no --seq 5:1 -i 1
```

**Floating-point sequence**

```sh
no --seq 0:1 --step 0.25 --precision 2
```

Output:

```
0.00
0.25
0.50
0.75
1.00
```

**Alphabet sequence (forward and reverse)**

```sh
no --seq a:z
no --seq Z:A
```

**Infinite cycling sequence**

```sh
no --seq 1:3 --cycle -t 10
```

---

## 3. Formatting & Layout (`--format`, `--pad`, `--width`, `-cols`)

**Zero‑padded IDs**

```sh
no --seq 1:10 --pad 3
```

**Formatted output using printf-style templates**

```sh
no --seq 1:3 -f "User_%03d"
```

**Right-aligned output**

```sh
no --seq 1:5 --width 4
```

**Column layout**

```sh
no --seq 1:12 -cols 4
```

---

## 4. Delimiters & Structured Output (`--separator`)

**Comma-separated list**

```sh
no --seq 1:5 -s ", "
```

**Inline CSV row**

```sh
no --seq 1:4 -s "," -f "%s"
```

---

## 5. Command Execution Loops (`--command`)

Run a command repeatedly with optional timing.

**Lightweight `watch` replacement**

```sh
no --command "date" -i 1
```

**System monitoring**

```sh
no --command "sysctl -n hw.ncpu" -i 5 -c
```

---

## 6. Randomized Output & Jitter (`--random`, `--jitter`)

**Random choice generator**

```sh
no -r "yes,no,maybe" -t 10
```

**Simulated human timing**

```sh
no "ping" -i 1 -j 2
```

---

## 7. Filtering, Arithmetic & Transformation

**Regex filtering**

```sh
no --seq 1:20 --filter '^[12]$'
```

**Inline arithmetic**

```sh
no --seq 1:5 --calc '*10'
```

**Case conversion**

```sh
no "Hello" -t 1 --case upper
```

**Ensure uniqueness**

```sh
no -r "a,b,c" --unique -t 3
```

---

## 8. Styling & Visual Output (`--style`, `--header`)

**Colored or styled output**

```sh
no "ERROR" -t 1 --style bold,red
```

**Print a header once**

```sh
no --seq 1:3 --header "ID" -c
```

---

## 9. File & Template Workflows (`--output`, `--template`)

**Write directly to a file**

```sh
no "Line" -t 5 -o output.txt
```

**Use a template file as input**

```sh
no --template rows.txt -f "[%s]"
```

---

## 10. Real-World Automation Examples

**Create numbered directories**

```sh
no --seq 1:12 -f "Episode_%02d" | xargs mkdir
```

**Stress-test a consumer**

```sh
no "TEST_DATA" -t 1000000 > /dev/null
```

**Generate placeholder content**

```sh
no "Lorem ipsum" -t 50 -o placeholder.txt
```

---

`no` is intentionally small, dependency-free, and composable. If you find yourself reaching for `seq`, `yes`, `watch`, `awk`, `sleep`, and `printf` together — `no` can usually replace all of them with a single, readable command.
