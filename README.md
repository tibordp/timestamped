# timestamped

`timestamped` is an utility that can be used to capture timestamped standard output and error of a command and replay it later.

## Example

```
> timestamped record -o recording.dat -- bash -c "echo foo; sleep 1; echo bar;"
> timestamped replay recording.dat
foo
<one second later>
bar
```

## Building from source

Requires a working [Alumina compiler](https://www.alumina-lang.net)

```
make
```
