# README

This project is supposed to aid in monitoring the LLVM snapshot build process
for fedora.

It features a postgres database for storing the logs, a grafana web-ui for
inspecting and visualizing the logs.

To run this project locally and have grafana provisioned with dashboards and
postgres prefilled with example data all you need to do is to run:

```
make pull
make start
```

This will pull the latest images that I've pushed in the docker registry.

The go to http://localhost:3000 to see the Grafana.

![Build Status Dashboard](/media/images/build-status-dashboard.png)

## TODO

* ~~Separate log data from grafana~~
* Have proper passwords and security before going live
  * Default to podman and use secrets mapped to files similar to this one: https://github.com/kwk/llvm-build-standalone/blob/main/Makefile 