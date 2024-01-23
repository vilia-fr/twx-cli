# Unofficial ThingWorx CLI

This is a Bash script to simplify your daily ThingWorx DevOps hurdles. It
was tested on

- Ubuntu Linux 20.04
- Ubuntu Linux 22.04
- Alpine Linux 3.14
- Git Bash on Windows 10

**IMPORTANT** This tool is developed by an independent open source community led by Vilia <vilia.fr>, 
and is not supported, verified or endorsed by PTC Inc. in any way. Use it on your own risk and refer
to its source code in case of doubts or questions.

ThingWorx is a registered trademark of PTC Inc.

## Install and configure

Install prerequisites: `curl`, `bash`, `zip`, `unzip` and `jq`.

On Windows, this tool has been tested and validated using Git Bash.

Create a file `~/.thingworx.conf` (on Windows `~/` is the user's home directory), or
`.thingworx.conf` file in your local folder. If no local config is found, then the global 
one in the user HOME (`~`) will be used. The file should contain:

```bash
# ThingWorx base URL without trailing slash /
TWX_URL="http://localhost:8080/Thingworx"

# A ThingWorx appkey, for example from SECRET_CX_APP_KEY
TWX_APPKEY="1234-5678-9012-3456-7890"
```

Put `twx` script on the system's `PATH` and make it executable by running `chmod +x twx`, 
if needed. Complete installation sequence for CI/CD pipelines:

```bash
wget https://github.com/vilia-fr/twx-cli/raw/main/twx
chmod +x ./twx
sudo ln -f -s "$(pwd)/twx" /usr/local/bin/twx
```

## Usage

All commands return 0 exit code in case of success, and non-zero in case
of failure. In the latter case the command outputs the error message,
otherwise it spits out a single "Success" string.

### Getting current configuration

Displays the current configuration from local directory configuration file if any, or global user configuration.

```bash
twx config
```

**WARNING** This includes the appkey in clear text.

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

If the `import` parameter is a directory, then
all XML files in that directory will be zipped, the ZIP file will be uploaded
to `SystemRepository/tmp-<UUID>`, unzipped, and the entities will be
then imported as Source Control. The temporary directory will be cleaned
up regardless of the import result.

```bash
twx import repo/twx-src
```

### Importing extensions

ZIP files are imported as extensions. This command ignores (returns 0 code)
"_Extension is already installed_" warnings, but it will fail on other errors,
such as "_A more recent version of this extension is already installed_".
If the ZIP file contains multiple extensions, this command will fail if
at least one of the sub-extensions fails to import.

```bash
twx import CustomWidget-1.9.1.zip
```

Importing all extensions in a given directory in the alphabetical order:

```bash
for EXT in *.zip; do twx import $EXT; done
```

### Calling services

The `call` command uses an intuitive syntax for calling services. It supports
any ThingWorx entities, such as Things, Resources, Mashups, Users, etc.

We can provide parameters to this command via `-pname=value` syntax. All
parameters are considered strings. ThingWorx will coalesce parameter types
for us, so it shouldn't be an issue.

```bash
# A simple no-parameters service call on a Thing
twx call Things/MyThing/Initialize

# Calling a service on a Resource to create a Thing remotely
twx call Resources/EntityServices/CreateThing -pname=MyThing -pthingTemplateName=GenericThing
```

### Executing ThingWorx code

In `eval` mode, we need to provide a JavaScript filename as a parameter.
Twx will wrap such a file in a `Run` service on a `Temp-<UUID>` GenericThing. 
This Thing is imported, the service is executed, and the Thing is then deleted, regardless 
of the service execution status.

Like in the `call` mode, we can provide parameters to this command via `-pname=value` 
syntax. If we do, then the `Run` service will also accept parameters. All parameters are
of type `STRING`.

The `Run` service has `INTEGER` return type, which is passed as the command
return code. This allows us to fail like that:  `var result = 1;` If you
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

# A better / safer version of the line above
echo "Things['Initializer'].Initialize({ version: ver })" | twx eval -pver=$VERSION

# A more straightforward version for simple scenarios
twx call Things/Initializer/Initialize -pversion=$VERSION
```

`twx eval` ignores the first line of the script, if it begins with `#!` shebang. It allows making
ThingWorx JavaScript files executable and use familiar `#!` syntax to run them as
native Linux commands. Consider a file called `purge`:

```javascript
#!/usr/local/bin/twx eval

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

### Building extension

Create a ThingWorx extension, as a zip file with proper `metadata.xml`.

In `build` mode the folder containing the entities to put in the extension is the first 
parameter, and the extensin name is the second. 
filename is the second:
A third optional parameter can be used to specify extension version. If omitted, default
version will be `1.0.0`.

```bash
twx build ./twx-src MyExtension
twx build ./twx-src MyExtension 1.1.9
```

The extension will be created in a dedicated `build` folder.

**IMPORTANT** If an extension with the same name already exists in the `build` folder, it will
be overwritten silently.

### Uploading individual files

In `upload` mode the File Repository[/path] is the first parameter, and the source 
filename is the second:

```bash
twx upload SystemRepository/docs README.md
twx upload SystemRepository root-data.txt
```

If `path` does not exist -- it gets created recursively. 

**IMPORTANT** Existing remote files are overwritten silently.

### Downloading individual files

As the name suggests, the `download` mode is the opposite of `upload`. The target 
directory is optional. If omitted, `.` is used. Examples:

```bash
twx download ImportDataRepository/data/history.csv
less history.csv

twx download SystemRepository/README.md ~/Downloads
```

**IMPORTANT** Existing local files are overwritten silently.

## Known bugs and improvements

This serves as a TODO / wishlist for the new features. Feel free to open a Pull Request
if you'd like to contribute.

### Importing data

CSV files are imported as DataTable rows. This assumes that the DT exists and
has compatible DataShape. The filename corresponds to the DT entity name.

```bash
twx import MyDataTable.csv
```

### Uploading multiple files

Directories are uploaded similarly to entity directories -- files are zipped,
uploaded, unzipped. The rest of the semantics is the same as with the previous
command.

```bash
twx upload ImportDataRepository/data ~/CSVs
```

### Downloading directories

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

## Changelogs

### 1.0.1
1. Added `build` feature
2. Added `version` feature

## Contributing

If you found a bug or would like to share a new feature, you can

1. Create a GitHub issue,
2. Fork this repo and open a Pull Request.

There are no specific building / contributing instructions, apart from testing
changes on two mainstream platforms -- recent Ubuntu and Windows (Git Bash).

## Credits

```
TWX CLI - Unofficial ThingWorx command line utilities
Copyright (c) 2023 Geoffrey Espagne, Vilia.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
```
