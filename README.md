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
**Note**: You must run the install script as root.
```sh
fetch -o - https://raw.githubusercontent.com/ihatemustard/no/refs/heads/main/install.sh | sh
```
Installs to `/usr/local/bin/no`.

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
