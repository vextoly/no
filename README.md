# no

`no` is the opposite of `yes`.

It behaves similarly to the Unix `yes` command, but:

* Defaults to printing `n`
* Supports `--times` or `-t` to limit repetitions (infinite by default)
* Supports `--interval` or `-i` to add delays between outputs
* Supports `--count` or `-c` to prepend a counter
* Supports `--output` or `-o` to write output to a file
* Supports `--random` or `-r` to repeat random strings from a comma-separated list
* Supports `--command` or `-cmd` to repeatedly execute a shell command and print its output
* Supports `--seq` to generate numeric (`1:10`) or character (`a:z`) sequences
* Supports `--step` to set the increment value (supports decimals like `0.5`)
* Supports `--pad` to zero-pad numeric output (e.g., `--pad 3` becomes `001`)
* Supports `--precision` to set fixed decimal places for numeric output
* Supports `--format` or `-f` for custom printf-style output strings
* Supports `-cols` to arrange output into multiple columns
* Supports `--separator` or `-s` for custom delimiters between items
* Supports `--version` or `-v` and `--help` or `-h`

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
$ no --example string --example2 string2 output
```

## Comparison of `no`

The table below compares the `no` script with other common Unix utilities that generate repeated or sequential output.  

| Feature | no v1.4-fix2 | yes | jot | seq | shuf |
|---------|----|-----|-----|-----|------|
| Infinite repetition | ✅ | ✅ | ❌ | ❌ | ❌ |
| Repetition count | ✅ | ❌ | ✅ | ✅ | ✅ |
| Custom string output | ✅ | ✅ | ❌ | ✅ | ✅ |
| Numeric sequence generation | ✅ | ❌ | ✅ | ✅ | ❌ |
| Character sequence generation | ✅ | ❌ | ✅ | ✅ | ❌ |
| Step / increment support | ✅ | ❌ | ✅ | ✅ | ❌ |
| Zero-padding | ✅ | ❌ | ✅ | ✅ | ❌ |
| Decimal precision formatting | ✅ | ❌ | ✅ | ✅ | ❌ |
| Random selection from list | ✅ | ❌ | ❌ | ❌ | ✅ |
| Execute command repeatedly | ✅ | ❌ | ❌ | ❌ | ❌ |
| Interval / delay between outputs | ✅ | ❌ | ❌ | ❌ | ❌ |
| Columns / custom separator | ✅ | ❌ | ✅ | ❌ | ❌ |
| Supports negative step | ✅ | ❌ | ✅ | ✅ | ❌ |
| Alphabetical ranges (a..z) | ✅ | ❌ | ✅ | ✅ | ❌ |
| Can repeat random items N times | ✅ | ❌ | ❌ | ❌ | ✅ |
| Lightweight | ✅ | ✅ | ✅ | ✅ | ✅ |
| High-Speed | 🟡 | ✅ | ✅ | ✅ | ✅ |

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

## Manual Installation & Removal (Linux + others) *UNTESTED*

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
**Step 1**: Download the [`no minimal`]([https://github.com/ihatemustard/no/blob/main/no.sh](https://github.com/ihatemustard/no/blob/84fadfe65e85aa04b81723047dde77a4455eb5a9/no.sh) script
**Step 2**: Complete all the steps listed above.

---

## Dependencies

* `sh` (POSIX-compliant shell, usually `/bin/sh`)
* `awk`, `printf`, `od` (for random logic)

## To-Do
- [X] Add Features from jot(1)
- [X] TUI Installer
- [X] Include help instead of using `man`
- [ ] Option to scan for new Versions
- [X] Install through Wi-Fi and not locally in Installer
- [X] Add Version Flag
- [X] Add Count Flag
- [X] Fix `--command` and `--seperator` flags
- [ ] Make parsing of flags better

[![FreeBSD Powered Button](https://www.freebsd.org/gifs/power-button.gif)](https://www.freebsd.org)
