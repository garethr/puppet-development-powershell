# Puppet Module Development - PowerShell Helpers

I'm using Windows a lot at the moment and the combination of that and
the fact I've not been working on Puppet modules for a while has me
playing with new workflows. As I want something portable I've oddly
settled on `PowerShell` and Docker.

This is definitely an experiment. It might turn into something useful or
it might just end up with a few PowerShell functions used only by me.
Time will undoutedly tell.


## Requirements

These modules require only `git`, `docker` and `powershell` to be
installed. No language runtimes, nothing too esoteric or requiring
tricky installation. My main priotity is Windows, but this works fine on
macOS with PowerShell Core too.

## Usage

There are a few optional parameters but the basic workflow looks like:

```
PS> Import-Module ./puppet-module-development.psm1
PS> Get-PuppetModule puppetlabs apache
PS> Test-PuppetModule puppetlabs apache
```

This should checkout the source code for the `puppetlabs/apache` module
based on metadata for the [Forge](https://forge.puppet.com) and then
runs the `release_checks` set of tests in Docker, using the
[garethr/puppet-module](https://hub.docker.com/r/garethr/puppet-module)
image.


## Documentation

You can use the excellent `Get-Help` command to get details about the
functions, parameters and a few examples. I've included the summaries
below for reference.


```
$ powershell -command "import-module ./puppet-module-development.psm1; Get-Help Get-PuppetModule
NAME
    Get-PuppetModule

SYNOPSIS
    Checkout the source code for a module published to the Puppet forge


SYNTAX
    Get-PuppetModule [-namespace] <String> [-module] <String>
    [<CommonParameters>]


DESCRIPTION
    Takes a namespace and module name, queries the Puppet Forge API to work
    out the source code location based on the module metadata and then uses
    git to checkout the module.


RELATED LINKS

REMARKS
    To see the examples, type: "get-help Get-PuppetModule -examples".
    For more information, type: "get-help Get-PuppetModule -detailed".
    For technical information, type: "get-help Get-PuppetModule -full".
```


```
$ powershell -command "import-module ./puppet-module-development.psm1; Get-Help Test-PuppetModule
NAME
    Test-PuppetModule

SYNOPSIS
    Run tests for a Puppet module using the garethr/puppet-module Docker image


SYNTAX
    Test-PuppetModule [[-namespace] <String>] [[-module] <String>]
    [[-versions] <Int32[]>] [[-command] <String>] [<CommonParameters>]


DESCRIPTION
    By default runs the release_checks rake command in the context of a Docker
    image containing Puppet 5. The parameters allow for running against
    multiple versions of Puppet and running alternative commands.


RELATED LINKS

REMARKS
    To see the examples, type: "get-help Test-PuppetModule -examples".
    For more information, type: "get-help Test-PuppetModule -detailed".
    For technical information, type: "get-help Test-PuppetModule -full".
```


## Why...

### Docker

Using the `garethr/puppet-module` image makes this portable between
environments, and removes the need to have a local Ruby runtime. This
also removes the need to mutate that local environment, say to upgrade a
specific gem. It even eliminates the need for end users to ever run `bundler`
or to need to know what `nokogiri` is.

More importantly, this means we can run tests against different versions
of Puppet with different versions of Ruby. And we can do this all
locally and in parallel if needs be.

### PowerShell

Mainly to provide a native, Windows-first, user experience. But also
PowerShell is great for rapid iteration on command line tooling due to
excellent support for things like multiple ways of passing parameters
and nice built-in documentation.
