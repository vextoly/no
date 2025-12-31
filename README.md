# no

`no` is the opposite of `yes`.

It behaves exactly like the Unix `yes` command, but:
- defaults to printing `n`
- (also) accepts custom arguments

## Usage

```sh
no
# n
# n
# n
# ...

no i like cheese
# i like cheese
# i like cheese
# ...
```
### Install & Uninstall (FreeBSD)
Step 1: Download the install script using fetch
```sh
fetch -o install.sh https://raw.githubusercontent.com/ihatemustard/no/refs/heads/main/install.sh
```
Step 2: Make the script executable
```sh
chmod +x install.sh
```
Step 3: Run the script as root (using `doas` or `sudo`)
```sh
./install.sh
```
Installs to `/usr/local/bin/no`.

To remove no, run the same script with the remove option **(also as root)**:
```sh
./install.sh remove
```

### Install & Uninstall (Linux & Others)
*Note: This method of installation is untested.*
1. [Download the `no` script](https://github.com/ihatemustard/no/blob/main/no.sh)
2. Make it executable:
`chmod +x no.sh`

3. Move it to a directory in your PATH (requires root):
`sudo mv no /usr/local/bin/no.sh`

4. Test it:
`no | head`
`no i like cheese | head`

To uninstall:
`sudo rm /usr/local/bin/no.sh`

### Dependencies
- sh (POSIX-compliant shell, usually /bin/sh)
- yes (standard Unix command, included in coreutils or base system)
