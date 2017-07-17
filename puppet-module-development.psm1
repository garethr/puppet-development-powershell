function Get-PuppetModule {
  <#
  .SYNOPSIS
  Checkout the source code for a module published to the Puppet forge

  .DESCRIPTION
  Takes a namespace and module name, queries the Puppet Forge API to work
  out the source code location based on the module metadata and then uses
  git to checkout the module.

  .PARAMETER namespace
  The module namespace on the Forge, for instance puppetlabs or voxpupuli

  .PARAMETER module
  The name of the module on the Forge, for instance apache or dsc

  .EXAMPLE
  Get-PuppetModule -namespace puppet -module apache
  #>
  Param(
    [Parameter(Mandatory=$True)][string]$namespace,
    [Parameter(Mandatory=$True)][string]$module
  )
  $resource = "https://forgeapi.puppetlabs.com/v3/modules/" + $namespace + "-" + $module
  $response = Invoke-RestMethod -Method Get -Uri $resource
  if (Get-Command "git" -ErrorAction SilentlyContinue) {
    git clone $response.current_release.metadata.source
  } else {
    Write-Error "Get-PuppetModule requires Git to be installed."
  }
}

function Test-PuppetModule {
  <#
  .SYNOPSIS
  Run tests for a Puppet module using the garethr/puppet-module Docker image

  .DESCRIPTION
  By default runs the release_checks rake command in the context of a Docker
  image containing Puppet 5. The parameters allow for running against
  multiple versions of Puppet and running alternative commands.

  .PARAMETER namespace
  The module namespace on the Forge, for instance puppetlabs or voxpupuli. Required
  only if the module is in a child directory.

  .PARAMETER module
  The name of the module on the Forge, for instance apache or dsc. Required only if
  the module is in a child directory.

  .PARAMETER versions
  An array of Puppet versions to test against. Defaults to 5. Current valid values are
  4 and 5 based on published Docker images.

  .EXAMPLE
  Test-PuppetModule -namespace puppetlabs -module apache

  Change directory into the puppetlabs-apache folder and run the tests against the
  default version of Puppet.

  .EXAMPLE
  Test-PuppetModule -version 4,5

  Run tests against the module in the current directory, running tests against
  Puppet 4 and 5 in sequence.

  .EXAMPLE
  Test-PuppetModule -command validate

  Run tests against the module in the current directory, but only run the validate command
  rather than the full set of release_checks

  #>
  Param(
    [string]$namespace,
    [string]$module,
    [int[]]$versions = @(5),
    [string]$command = "release_checks"
  )
  if ($namespace -and $module) {
    cd "$namespace-$module"
  }
  if (Get-Command "docker" -ErrorAction SilentlyContinue) {
    Foreach ($version in $versions) {
      $docker = "docker run -v ${pwd}:/module -it garethr/puppet-module:${version} ${command}"
      Invoke-Expression $docker
    }
  } else {
    Write-Error "Test-PuppetModule requires Docker to be installed."
  }
}
