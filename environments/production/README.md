# Production Environment

Directory to store Puppet manifests and modules to be run by deployed Puppet master,
rather than Vagrant's provisioning Puppet.

This directory should likely contain a directory structure similar to that below.

```
.
|-- manifests
|   `-- nodes.pp
`-- modules
    `-- mymodule

```
