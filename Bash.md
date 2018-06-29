# Bash

https://dev.to/rpalo/bash-brackets-quick-reference-4eh6

## Conditionals

Did a command exit successfully?

```bash
[[ $( grep -q PATTERN FILE )$? ]]
```

## Subshells

Run a command in a subshell with parenthesis:

```bash
$ (foo=bar; echo $foo)
bar
```

Insert the result of the command by adding a $:

```bash
$ echo $(foo=bar; echo $foo)
bar
```

Without a $, there would be an error:

```bash
$ echo (foo=bar; echo $foo)
bash: syntax error near unexpected token `foo=bar'
```

## Arithmetics

Use double parenthesis:

```bash
$ i=5
$ ((i += 2))
$ echo $i
7
```

- If the arithmetics result is 0, `$?` will be 1.
- You can't use this construct within an expression
- To glean the results, you have to use variables as we did above.

Or you can use arithmetic interpolation with `$((op))`.

## Globs

```bash
ls file[1-5]
ls file*
ls file??
```

Obvious reminder: when wrapped in quotes, globs do not expand.

## Variables

```bash
$ readonly MYVAR=1
$ MYVAR=2
bash: MYVAR: readonly variable
$ VAR2="interpolate $MYVAR"
$ VAR3='does not interpolate $MYVAR'
$ $VAR3
bash: does: command not found
$ unset VAR3
```

- If not wrapped in single quotes, variables will be replaced by their contents.
- The final replacement is what will be run.

## Exporting variables

```bash
$ MYSTRING=astring
$ export MYSTRING
$ bash
$ echo $MYSTRING
astring
$ exit
$ unset MYSTRING
$ bash
$ echo $MYSTRING

$ exit
```

## Arrays

```bash
$ echo $BASH_VERSINFO
$ echo $BASH_VERSINFO[0]
$ echo ${BASH_VERSINFO[0]}
$ echo ${BASH_VERSINFO[1]}
```

- The first line outputs the element at index 0
- The second line outputs the element at index 0 + the string `[0]`
- The third line outputs the element at index 0
- The fourth line outputs the element at index 1

Needs `${}` to work correctly!

Different ways to declare arrays:

```bash
$ A[0]=1
$ A[1]=2
$ echo ${A[0]}
1
$ echo ${A[1]}
2
$ declare MYAA=([0]=1 [1]=2)
$ echo ${MYAA[1]}
2
```

Non-array variables can be treated as arrays with one element:

```bash
$ A=1
$ echo ${A[0]}
1
$ echo ${A[1]}

```

Associative arrays are only available in Bash v4:

```bash
$ declare -A MYAA=([one]=1 [two]=2 [three]=3)
```

Creating an array from a command's output:

```bash
VAR=($(command))
```

## Process substitution

### The <() operator

Return the results of the command through a file descriptor.

```bash
$ diff <(ls dira) <(ls dirb)
```

### The >() operator

Given the following command:

```bash
$ tar cvf out.tar /tmp
```

We can substitute `out.tar` by a command that generates `out.tar`.
`tar` will redirect its output to the command instead of directly into `out.tar`:

```bash
# Without a file, cat listens to stdin
# tar pipes right into cat, which then creates out.tar
$ tar cvf >(cat > out.tar) /tmp
```

A more useful example:

```bash
# Tar pipes into gzip, which pipes into out.tar.gz
$ tar cvf >(gzip > out.tar.gz) /tmp
```

Let's do the same thing with `|` pipes. I know `tar` can generate a `gzip` file,
but how to combine `tar` + `gzip` in a pipeline fashion? How to make `gzip`
accept input from stdin?

```bash
$ tar -c -f - my_dir
```

This line outputs the `tar` of my_dir to stdout. This command will not work as
expected:

```
$ tar -c -f - dir | gzip
gzip: standard output is a terminal -- ignoring
```

But this one will:

```bash
$ tar -c -f - dir | gzip > foo.tar.gz
```

Lesson learned: read the gzip man page! `standard output is a terminal` means we
are not directing the binary output (resulting from gzip) anywhere!

Suppose "a" is a directory that contains files named "1" and "2":

```bash
cat <(ls a) > >(grep 2 > f)
```

- `<(ls a)` substitutes the output of `ls a` by a temp file.
- The output is piped into an stdin substitution.
- This will create an "f" file with contents == "2".

What does the following sort command do?

```bash
sort -nr -k 5 <( ls -l /bin ) <( ls -l /usr/bin ) <( ls -l /sbin )
```

## Builtin commands

```bash
$ builtin cd /tmp
$ builtin grep foo
bash: builtin: grep: not a shell builtin
$ function cd { echo "I took over cd!" }
$ cd /tmp
I took over cd!
$ builtin cd /tmp
$ pwd
/tmp
$ cd -
$ unset -f cd
$ cd /tmp
```

## Functions

List defined functions:

```bash
$ declare -F
```

List defined functions with source code:

```bash
$ declare -f
```

## Pipes and redirection

We want stderr to follow stdout wherever it goes (that is, to `outfile`):

```bash
$ command_does_not_exist 2>&1 1> outfile
bash: command_does_not_exist: command not found
$ cat outfile

```

It will not happen. Here's the right approach:

```bash
$ command_does_not_exist 1> outfile 2>&1
$ cat outfile
bash: command_does_not_exist: command not found
```

**The order of redirections matter**. First, you must point stdout to a file,
and then point stderr to stdout to capture both.  If you point stderr to stdout
and then point stdout to a file, stdout will still be pointing at the terminal
at the time the first redirection happens.

Let's take a look at other examples. Redirect both stdout and stderr to `file`:

```bash
$ ruby -e '$stdout.puts "non-error"; $stderr.puts "error"' 1> file 2>&1
```

Redirect only stdout to the file. stderr will still go to terminal:

```bash
# Of course, by removing `2>&1` the command will still work the same.
$ ruby -e '$stdout.puts "non-error"; $stderr.puts "error"' 2>&1 1> file
error
$ cat file
non-error
```

General recap:

- A pipe sends stdout of one command into stdin of another
- A `>` redirect sends an output channel (stdin, stdout or stderr - 0, 1, 2) to a file
- A `<` redirect sends the contents of a file to the stdin of a command

Example of `<` (the `0` means stdin and is implicit)

```bash
$ grep -c file 0< file1
```

Same as:

```bash
cat file1 | grep -c file
```
