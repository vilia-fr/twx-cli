# ThingWorx CLI

This is a Bash script to simplify your daily ThingWorx DevOps hurdles. It
was tested on

- Ubuntu Linux 22.04
- Alpine Linux 3.14
- GitBash on Windows 10

## Configure

Install prerequisites: `curl`, `bash`, ...

Create a file `~/.thingworx.conf`:

```bash
# ThingWorx base URL without trailing slash /
TWX_URL="http://localhost:8080/Thingworx"

# Use one of the two -- either appkey or admin credentials
TWX_APPKEY="1234-5678-9012-3456-7890"
TWX_ADMIN_USER="Administrator"
TWX_ADMIN_PASSWORD="secret"
```

Put `twx` script on the system `PATH`.

## Usage

All commands return 0 exit code in case of success, and non-zero in case
of failure. In the latter case the command outputs the error message,
otherwise it spits out a single "Success" string.

### Importing individual entities

```bash
twx import MyThing.xml
```

The same, with custom error handling:

```bash
err=$(twx import MyThing.xml)
test $? -eq 0 || echo "Couldn't import MyThing.xml: $err"
```

### Importing multiple entities

If the `import` parameter is a directory,
all XML files in that directory will be zipped, the ZIP will be uploaded
to `SystemRepository/tmp-<UUID>`, unzipped, and the entities will be
then imported as Source Control. The temporary directory will be cleaned
up regardless of the import result.

```bash
twx import repo/twx-src
```

### Importing extensions

ZIP files are imported as extensions. This command ignores (returns 0 code)
"Extension is already installed" warnings, but it will fail on other errors,
such as "A more recent version of this extension is already installed".
If the ZIP file contains multiple extensions, this command will fail if
at least one of the sub-extensions fails.

```bash
twx import CustomWidget-1.9.1.zip
```

Importing all extensions in a given directory in the alphabetical order:

```bash
for EXT in *.zip; do twx import $EXT; done
```

### Calling services

The `call` command uses an intuitive syntax for calling services. It supports
Things and Resources. In the latter case you need to add `-r` parameter.

We can provide parameters to this command via `-pname=value` syntax. All
parameters are considered strings. ThingWorx will coalesce parameter types
for us, so it shouldn't be an issue.

```bash
# A simple no-parameters service call on a Thing
twx call MyThing/Initialize

# Calling a service on a Resource - creating a Thing remotely
twx call EntityServices/CreateThing -r -pname=MyThing -pthingTemplateName=GenericThing
```

### Executing ThingWorx code

In `eval` mode, we need to provide a JavaScript file as a `twx` parameter.
Those JavaScript files are wrapped in a `Run` service on a `Temp-<UUID>`
GenericThing. This Thing is imported, the service is executed, and the
Thing is then deleted, regardless of the service execution status.

We can provide parameters to this command via `-pname=value` syntax. If we
do, then the `Run` service will also accept parameters. All parameters are
of type STRING.

The `Run` service has `INTEGER` return type, which is passed as the command
return code. This allows you to fail like that:  `var result = 1;` If you
don't specify any `result` value, it will be zero, i.e. success by default.

If the code throws an exception, the command returns `99` error code. The
exception message is output to `stderr`.

If no filename is provided, the script body is taken from `stdin`.

```bash
# A basic example. If init.js throws an exception or returns
# a non-zero result, then this command will fail.
twx eval init.js

# Passing parameters
twx eval init.js -pusername=Administrator -ppassword=$SECRET

# Conditional logic based on result
twx eval check-health.js
RET=$?
case $RET in
  10)
    echo "Healthy"
    ;;

  20)
    echo "Degraded"
    ;;

  30)
    echo "Failing"
    ;;
esac

# A oneliner remote execution
echo "Things['Initializer'].Initialize({ version: '$VERSION' })" | twx eval

# A better / safer version of the same thing
echo "Things['Initializer'].Initialize({ version: ver })" | twx eval -pver=$VERSION
```

If you run `twx` command without any parameters, it acts as `eval` by default,
ignoring the first line of the script, if it begins with `#` sign. It allows making
ThingWorx JavaScript files executable and use familias `#!` syntax to run them as
native Linux commands. Consider a file called `purge`:

```javascript
#!/bin/twx

// This is JavaScript!
if (!name) {
    throw "Which DataTable should I purge?";
}

if (Things[name]) {
    let t = Things[name];
    if (t.IsDerivedFromTemplate({ thingTemplateName: "DataTable" })) {
        t.PurgeDataTableEntries();
        logger.warn("Purged DataTable " + name);
    } else {
        throw name + " is not a DataTable";
    }
} else {
    throw "I couldn't find a Thing called " + name;
}
```

Make it executable, and then you can run it just like any other Linux command,
using `-pname=value` syntax for inputs:

```bash
chmod +x purge
./purge -pname=MyDataTable
```

This provides a simple and convenient way of building a sophisticated DevOps toolbox
for your Linux shell.

## TODO: Future / lower priority features

### Importing data

CSV files are imported as DataTable rows. This assumes that the DT exists and
has compatible DataShape. The filename corresponds to the DT entity name.

```bash
twx import MyDataTable.csv
```

### Uploading individual files

Repository[/path] is the first parameter, the file is the second:

```bash
twx upload SystemRepository/docs README.md
twx upload SystemRepository root-data.txt
```

If `path` does not exist -- it is created recursively. Existing files are
overwritten silently.

### Uploading multiple files

Directories are uploaded similarly to entity directories -- files are zipped,
uploaded, unzipped. The rest of the semantics is the same as with the previous
command.

```bash
twx upload ImportDataRepository/data ~/CSVs
```

### Downloading files

The opposite of uploading, works for both individual files and directories
(the files are zipped, downloaded and unzipped in the latter case). The target
directory is optional. If omitted, `.` is used. Examples:

```bash
twx download ImportDataRepository/data/history.csv
less history.csv

twx download ImportDataRepository/data ~/Downloads
cd ~/Downloads/data
ls -al
```
