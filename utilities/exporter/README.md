# Exporter

This is a Bash script to simplify Thingworx application export. It
was tested on

- Ubuntu Linux 22.04
- Windows Server 2019 (using GitBash)

## Prerequisites

Install prerequisites: `curl`, `bash`, `twx` from this twx-cli repository.
Note that the `twx` command line tool must be configured to access your Thingworx instance.

If you are using windows, you want to run this with git bash, so git need to be installed.

## Installation/Uninstallation

This tool use a set of Thingworx entities to store export configuration and perform a part of the entities 
export, thus the extension `Vilia.Utils.Exporter` need to be installed.

### Install

To install the exporter extension, simply run the `install.sh` script:

```bash
./install.sh
```

### Uninstall

To unintall the exporter extension from your Thingworx instance, simply run the `uninstall.sh` script:

```bash
./uninstall.sh
```

## Usage

### Configuration

Configuration steps are required in Thingworx. The export configuration must be entered on the
thing **Vilia.Utils.Exporter_TG** before starting the export.

To do so, **Edit** the thing in the Thingworx Composer, and set the configuration under the
**Configuration** section of the thing.

The configuration properties are:

- **exportLocalizationTokenPrefix**: used to export localizations tokens. Will exports all tokens that matches
the configured prefix.

- **projectExportList**: list of the TWX project that will be exported. Used to only export relevant projects.

- **configurationTablesToClean**: used to clean configuration table for export. This table contains a list of
things, and for each a list of configuration table names. For configured thing/configuration tables, the 
tables will be exported empty, so specific environment configurations can be omitted in the export.

- **groupsToClean**: list of groups that will be cleaned during the export. Used to not export environment
specific users.

### Export

Once configuration has been made in Thingworx, the export can be performed using the script `export.sh`.
The best way to do it is to copy the whole `utilities/exporter` folder in your project folder where you want the 
sources to be exported, then launch the script as follow:

```bash
./utilities/exporter/export.sh
```

This will create a folder twx-src as follow (with Project_1, etc replaced by your exported TWX projects):

```
+-- twx-src
|   +-- Project1
|   |   +-- Things
|   |   |   +-- Thing1.xml   
|   |   |   +-- Thing2.xml 
|   |   +-- ThingShapes
|   |   |   +-- ThingShape1.xml 
....
|   +-- Project2
|   |   +-- Things
|   |   |   +-- Thing4.xml   
|   |   |   +-- Thing5.xml 
|   |   +-- ThingShapes
```