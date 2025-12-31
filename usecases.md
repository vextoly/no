# Use Cases for `no`

## 1. Automating Negative Responses

Use `no` to automatically respond to prompts in scripts, installers, or command-line programs that require confirmation.

```sh
# Simulate always saying no
no | head -n 5
n
n
n
n
n
```

```sh
# Say 'no' with a delay between each response
no --interval 0.5 --times 3
n
(wait 0.5s)
n
(wait 0.5s)
n
```

---

## 2. Custom Text Repetition

You can print custom negative responses instead of the default `n`.

```sh
no i hate mustard --times 3
# Output:
i hate mustard
i hate mustard
i hate mustard
```

---

## 3. Counting Outputs

Prepend a counter to each output to track repetitions.

```sh
no --count --times 5
# Output:
1: n
2: n
3: n
4: n
5: n
```

---

## 4. Writing to Files

Redirect output directly to a file without using shell redirection.

```sh
no example --output log.txt --times 3
# Writes the following to log.txt:
example
example
example
```

---

## 5. Random Responses

Repeat random strings from a list to simulate variability.

```sh
no --random "no,nah,nop,never" --times 4
# Possible output:
no
nop
nah
never
```

---

## 6. Script Testing

Use `no` to test scripts or programs that expect repeated negative input. Combined with `--interval` and `--times`, it can simulate realistic user input.

```sh
no --interval 1 --random "no,nah,nop" --times 5
```

---

## 7. Quick Demo or Fun

Use `no` for fun, rhetorical responses, or demonstrations.

```sh
no absolutely-not --times 10
```

---

## Notes

* Combine any of the flags for flexible behavior.
* The `--help` flag shows all options and examples directly in the terminal:

```sh
no --help
```
