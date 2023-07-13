# packaging-demo

This repository illustrates the use of [Carvel](https://carvel.dev) for software packaging and distribution.
It presents and model for organizing and grouping configuration and installation files for a number of related applications so that they can be easily delivered to and consumed in Kubernetes clusters.

More specifically, it covers the actions listed below.
> Note that in some cases the command resource mentioned below will be called created directly, and sometimes it will be called created automatically by kctrl, a CLI that orchestrates the execution of some of the other CLIs in the Carvel suite.
- Use of **kbld** to orchestrate application image build and registry push, and to record resulting image reference in a YAML file
- Use of **ytt** to facilitate sophisticated manipulation of YAML using templating, overlays, and programming logic
- Use of **Package CRD** to define application configuration as a package that is easy to represent and discover on Kubernetes
- Use of **vendir** to vendor in 3rd-party configuration as a Package
- Use of **PackageInstall CRD** and values Secret to facilitate installation and configuration
- Grouping of PackageInstalls and ancillary configuration into a "**metapackage**" to facilitate installation of multiple Packages simultaneously
- Use of **imgpkg** to release Packages (and metadata of resolved image SHAs) as  OCI bundles so that they can be easily distributed
- Release of a collection of versioned Packages as a **PackageRepository** that can be managed and viewed in Kubernetes
- Installation of PackageRepository into Kubernetes
- Installation of Packages in Kubernetes
- Update to configuration of installed Packages
- Use of imgpkg to relocate images across repositories (e.g. for air-gapped environments)
- Creation of a subset metapackage (e.g. to limit images copied across repositories for resource-strapped environments, such as edge devices)
- Use of **kctrl** to wrap and simplify the Package authoring and installation workflow described above
- Use of **kapp-controller** to manage Package consumption and maintenance in Kubernetes

> Note: An additional Carvel tool, **kapp**, is not mentioned explicitly above, but is also employed within the workflows orchestrated by kctrl to better manage application of resources to Kubernetes and identify configuration changes between updates.

## Demo

To execute the workflow as a demo:

### Part I: Package Authoring

Open the file [scripts/demo1-create-packages.sh] and follow the instructions at the top.
```shell
# Pre-requisites:
#   Run: ./scripts/00-build-apps.sh && ./scripts/00-start-state.sh
#   Update value of MY_REG below, as appropriate, and log in to your registry using `docker login`
# Execute demo:
#   Run: ./scripts/demorunner.sh scripts/demo1-create-packages.sh
```

When the demo begins, hit ENTER to execute the first instruction.
When each new prompt appears, hit Enter to show the next instruction, and ENTER again to execute it.
As you proceed, take note of the new files created and the new OCI images published by the instructions.

### Part II: Package Consumption (and authoring of a sub-package)

Open the file [scripts/demo2-consume-packages.sh] and follow the instructions at the top.

```shell
# Pre-requisites:
#   Run: ./scripts/00-create-cluster.sh  
#   Note: After the demo, you can delete the cluster using `kind delete cluster --name pkg-demo`
#   Update value of MY_REG below, as appropriate, and log in to your registry using `docker login`
# Execute demo:
#   Run: ./scripts/demorunner.sh scripts/demo2-consume-packages.sh
```

When the demo begins, hit ENTER to execute the first instruction.
When each new prompt appears, hit Enter to show the next instruction, and ENTER again to execute it.
As you proceed, take note of the new Kubernetes resources created by the instructions.

---
## TO-DO:
- Move namespace config to child of app name key
- Create shared namespace key that overrides app-specific setting
- Update auto-generation of namespace resource condition to use namespace name rather than owner key
