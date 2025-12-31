# no

`no` is the opposite of `yes`.

It behaves similarly to the Unix `yes` command, but:

* Defaults to printing `n`
* Accepts custom arguments (words to repeat)
* Supports `--times NUMBER` to limit repetitions (infinite by default)

---

## Usage

```sh
no
# n
# n
# n
# ...

no i hate mustard
# i hate mustard
# i hate mustard
# ...

no i hate mustard --times 2
# i hate mustard
# i hate mustard

no --times 5
# n
# n
# n
# n
# n
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
* Creates a man page at `/usr/local/share/man/man1/no.1`
* Works immediately without additional configuration

To remove `no`, run the same script with the `remove` option (also as root):

```sh
./install.sh remove
```

---

## Install & Uninstall (Linux & Others)

*Note: This method of installation is untested.*

**Step 1**: [Download the `no` script](https://github.com/ihatemustard/no/blob/main/no.sh)

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
