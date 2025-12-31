# no

`no` is the opposite of `yes`.

It behaves similarly to the Unix `yes` command, but:

* Defaults to printing `n`
* Supports `--times` or `-t` to limit repetitions (infinite by default)
* Supports `--interval` or `-i` to add delays between outputs
* Supports `--count` or `-c` to prepend a counter
* Supports `--output` or `-o` to write output to a file
* Supports `--random` or `-r` to repeat random strings from a comma-separated list
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

# You can pass (multiple) arguments
$ no --example string --example2 string2 output
...
```

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
* Works immediately without additional configuration

To remove `no`, run the same script with the `remove` option **(also as root)**:

```sh
./install.sh remove
```

---

## Install & Uninstall (Linux & Unix-like systems)

*Note: This method of installation is untested.*

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
no | head
```

To remove `no`, run:

```sh
sudo rm /usr/local/bin/no
```

---

## Dependencies

* `sh` (POSIX-compliant shell, usually `/bin/sh`)
