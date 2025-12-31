[Back to readme](https://github.com/ihatemustard/no)

# Use Cases for `no`

`no` is a modern, high-performance sequence generator and automation utility. While it begins as the logical opposite of the classic Unix `yes` command, its advanced features make it a lightweight alternative to complex loops in shell scripting.

## Why `no` is a Useful Tool

* **Readability:** Replaces messy `for i in $(seq 1 10); do...done` loops with clean, one-line commands.
* **Native Logic:** Handles floating-point math, zero-padding, and character sequences (`a:z`) natively, which standard POSIX shells struggle with.
* **Simulation:** With `--interval` and `--random`, it can simulate human input or unpredictable network traffic for testing.
* **Formatting:** Built-in `printf` support allows generating structured data (JSON, CSV, SQL) without piping into multiple text processors.

## 1. Sequence Generation (`--seq`, `--step`)

Handles numeric and alphabetical ranges, including reverse counts and custom increments.

**Default Negative Input: Send a stream of "n" to a prompt**

```bash
no | ./install-script.sh
```

**Countdown for a script launch**

```bash
no --seq 5:1 --interval 1
```

**Floating point increments**

```bash
no --seq 0:1 --step 0.25 --precision 2
```

Output:

```
0.00, 0.25, 0.50, 0.75, 1.00
```

## 2. Advanced Data Formatting (`--format` / `-f`)

Wrap output in a template instead of just printing a number.

**Generating dummy filenames or URLs**

```bash
no --seq 1:3 -f "https://api.example.com/v1/user/%03d"
```

**SQL Migration Helper: Generate 100 placeholder entries**

```bash
no --seq 1:100 -f "INSERT INTO users (id, name) VALUES (%d, 'User_%d');"
```

**Networking: Generate a list of IP addresses**

```bash
no --seq 1:254 -f "192.168.1.%s"
```

## 3. Grid & Layout Control (`-cols`)

Useful for quick terminal dashboards or organizing long lists into readable chunks.

**Organizing the alphabet into columns**

```bash
no --seq a:z -cols 13
```

**Displaying a large number of IDs**

```bash
no --seq 1:100 --pad 3 -cols 10
```

## 4. Custom Delimiters (`--separator` / `-s`)

Define how items are separated instead of standard one-item-per-line output.

**Creating a comma-separated list**

```bash
no --seq 101:105 -s ", "
```

**JSON Array Construction**

```bash
no --seq 1:5 -s ", " -f "%d" | sed 's/.*/[&]/'
```

Output:

```
[1, 2, 3, 4, 5]
```

## 5. Automated System Monitoring (`--command` / `-cmd`)

Combine command execution with intervals to create a lightweight "watch" tool.

**CPU Temperature Monitor**

```bash
no --command "sysctl -n hw.acpi.thermal.tz0.temperature" --interval 1 --count
```

**Connectivity Heartbeat**

```bash
no --command "ping -c 1 8.8.8.8 > /dev/null && echo 'Online' || echo 'Offline'" --interval 5
```

## 6. Real-Life Workflow Examples

**Media Management: Create a numbered list of scene folders**

```bash
no --seq 1:20 -f "Scene_%02d" | xargs mkdir
```

**Web Testing (Fuzzing)**

```bash
no --random "200,404,500,403" -i 0.5 -f "curl -X POST -d 'status=%s' localhost:3000/test" | sh
```

**Stress Testing: Bombard a service with a specific string**

```bash
no "OVERFLOW_TEST_DATA" --times 1000000 > /dev/null
```

**Frontend Prototyping: Generate 50 lines of placeholder text**

```bash
no "Lorem ipsum dolor sit amet." --times 50 --output placeholder.txt
```
