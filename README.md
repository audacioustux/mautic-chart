## Usage

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

    helm repo add mautic https://audacioustux.github.io/mautic-chart

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages.  You can then run `helm search repo mautic` to see the charts.

To install the mautic chart:

    helm install mautic audacioustux/mautic

To uninstall the chart:

    helm delete mautic