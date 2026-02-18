[![IDC License](https://img.shields.io/badge/License-IDC-blue.svg)](LICENSE)

<sub>If you found this project helpful or enjoyed using it, please consider giving it a star!</sub>

# no

`no` is the opposite of `yes`.

It behaves similarly to the Unix `yes` command, but:

## Default Behavior

* Defaults to printing `n` infinitely if no arguments are provided.

## Control Flags

* `--times, -t`: Limits repetitions (e.g., `-t 5` prints 5 times).
* `--interval, -i`: Adds a fixed delay (in seconds) between each output.
* `--jitter, -j`: Adds a random delay (0 to N seconds) on top of the interval.
* `--output, -o`: Writes the output to one or multiple specified files, streams, or devices.
* `--command, -cmd`: Repeatedly executes a shell command and captures its output for each iteration.
* `--random, -r`: Picks a random string from a comma-separated list or template for each iteration.
* `--skip`: Ignores the first N items of a sequence, repetition, or template.
* `--version, -v`: Displays metadata or internal state information.
* `--help, -h`: Displays the help manual and usage instructions.
* `--unique`: Ensures every output of no is unique.

## Sequences & Math

* `--seq`: Generates numeric (e.g., `1:10`) or character (e.g., `a:z`) sequences.
* `--step`: Sets the increment/decrement value (supports decimals like `0.5`).
* `--cycle`: Repeats sequences infinitely (requires a limit via `-t`).
* `--pad`: Zero-pads numeric output to a specific length (e.g., `--pad 3` becomes `001`).
* `--precision`: Sets fixed decimal places for floating-point numeric output.
* `--calc`: Performs arithmetic operations on numeric output (e.g., `'+5'`, `'*2'`).

## Formatting & Visuals

* `--format, -f`: Applies a custom printf-style string (e.g., `-f "ID-%s"`).
* `--case`: Transforms text case using `upper`, `lower`, or `swap`.
* `--color / --style`: Wraps output in ANSI color codes; supports named colors, hex codes, or style combinations (`bold`, `underline`, `italic`).
* `--header`: Prints a single designated line once before the main process begins.
* `--prefix`: Adds a specific string before every output item.
* `--suffix`: Adds a specific string after every output item.
* `--width`: Right-aligns the output to a fixed character width.
* `--trim`: Removes leading/trailing whitespace from output items.

## Layout & Parsing

* `-cols`: Arranges the output into N columns using tabbed spacing.
* `--separator, -s`: Defines custom delimiters between items (defaults to `\n`).
* `--count, -c`: Prepends an incrementing line counter (e.g., `1: text`).
* `--template`: Uses content from a file or string as the source text.
* `--filter`: Outputs only items matching a specified regular expression.
* `--`: Stops parsing flags; everything following is treated as literal text.
* `--verify`: Runs an internal suite of self-tests to ensure all logic functions correctly.

For practical examples and ways to use `no`, see the [Use Cases](usecases.md) page.

---

## Usage

```sh
$ no
n
n
n
...

$ no i hate mustard
i hate mustard
i hate mustard
...

# You can pass (multiple) arguments
$ no --example string --example2 string2 "output"
```

## Comparison of `no`

The table below compares the `no` script with other common Unix utilities that generate repeated or sequential output.  

| Feature                         | no | yes | jot | seq | shuf |
| ------------------------------- | -------- | --- | --- | --- | ---- |
| Infinite repetition             | ✅        | ✅   | ❌   | ❌   | ❌    |
| Repetition count                | ✅        | ❌   | ✅   | ✅   | ✅    |
| Custom string output            | ✅        | ✅   | ❌   | ✅   | ✅    |
| Numeric sequence generation     | ✅        | ❌   | ✅   | ✅   | ❌    |
| Character sequence generation   | ✅        | ❌   | ✅   | ✅   | ❌    |
| Step/increment support          | ✅        | ❌   | ✅   | ✅   | ❌    |
| Zero-padding                    | ✅        | ❌   | ✅   | ✅   | ❌    |
| Decimal precision formatting    | ✅        | ❌   | ✅   | ✅   | ❌    |
| Random selection from list      | ✅        | ❌   | ❌   | ❌   | ✅    |
| Execute command repeatedly      | ✅        | ❌   | ❌   | ❌   | ❌    |
| Interval/delay between outputs  | ✅        | ❌   | ❌   | ❌   | ❌    |
| Columns/custom separator        | ✅        | ❌   | ✅   | ❌   | ❌    |
| Supports negative step          | ✅        | ❌   | ✅   | ✅   | ❌    |
| Alphabetical ranges(a..z)       | ✅        | ❌   | ✅   | ✅   | ❌    |
| Can repeat random items N times | ✅        | ❌   | ❌   | ❌   | ✅    |
| Random Jitter Delay             | ✅        | ❌   | ❌   | ❌   | ❌    |
| Case(Upper/Lower/Swap)          | ✅        | ❌   | ❌   | ❌   | ❌    |
| ANSI Color Support              | ✅        | ❌   | ❌   | ❌   | ❌    |
| CSV/File Header Support         | ✅        | ❌   | ❌   | ❌   | ❌    |
| Sequence Cycling                | ✅        | ❌   | ❌   | ❌   | ❌    |
| Skip N Items                    | ✅        | ❌   | ❌   | ❌   | ❌    |
| Standard--flag=val Parsing      | ✅        | ❌   | ❌   | ❌   | ❌    |
| Lightweight                     | ✅        | ✅   | ✅   | ✅   | ✅    |

---

## Install & Uninstall (FreeBSD)

**Step 1**: Download the install script using `fetch`

```sh
fetch -o install.sh https://raw.githubusercontent.com/ihatemustard/no/refs/heads/main/install.sh
```

**Step 2**: Make the script executable

```sh
chmod +x install.sh
```

**Step 3**: Run the script as root (using `doas` or `sudo`)

```sh
./install.sh
```

* Installs the command to `/usr/local/bin/no`

To remove `no`, run the same script **(also as root)**.

---

## Manual Installation & Removal (Linux + others)

**Step 1**: Download the [`no`](https://github.com/ihatemustard/no/blob/main/no.sh) script

**Step 2**: Make it executable

```sh
chmod +x no.sh
```

**Step 3**: Move it to a directory in your PATH (requires root)

```sh
sudo mv no.sh /usr/local/bin/no
```

**Step 4**: Test it

```sh
no -h
```

To remove `no`, run:

```sh
sudo rm /usr/local/bin/no
```

**Install no minimal (Not recommended)**

**Step 1**: Download the [`no minimal`](https://github.com/ihatemustard/no/blob/84fadfe65e85aa04b81723047dde77a4455eb5a9/no.sh) script

**Step 2**: Complete all the steps listed above.

---

## Dependencies

* `sh` (POSIX-compliant shell, usually `/bin/sh`)
* `awk`, `printf`, `od` (for random logic)

## To-Do
- [X] Add Features from jot(1)
- [X] TUI Installer
- [X] Include help instead of using `man`
- [X] Install through Wi-Fi and not locally in Installer
- [X] Add Version Flag
- [X] Add Count Flag
- [X] Fix `--command` and `--seperator` flags
- [X] Make parsing better
- [X] Add `--filter` (filter or modify output)
- [X] Support multiple targets with `--output`
- [X] Add simple arithmetic operations
- [X] Add improved ANSI Styling (Bold, underline, hex)
- [X] Multi-line templates / `--template` support
- [X] Update [Use Cases](usecases.md) page to latest
- [X] Add flag `--unique`: Ensures every output of no is unique.
- [X] Add flag `--trim`: Removes leading/trailing whitespace from output items.
