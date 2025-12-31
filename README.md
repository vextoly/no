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
### Install (FreeBSD)
```sh
fetch -o - https://raw.githubusercontent.com/ihatemustard/no/main/install.sh | sh
```
Installs to `/usr/local/bin/no`.
