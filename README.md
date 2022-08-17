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

## Maketargets

Available targets
<dl>
<dt><code>all</code></dt><dd>Runs the "start" target</dd>
<dt><code>stop</code></dt><dd>Stops all services</dd>
<dt><code>build</code></dt><dd>Builds the image for all services</dd>
<dt><code>push</code></dt><dd>Pushes the images for all services to the container registry</dd>
<dt><code>pull</code></dt><dd>Pulls all the images for all servies from the registry</dd>
<dt><code>start</code></dt><dd>Starts all services and follows the logs of each service</dd>
<dt><code>logs</code></dt><dd>Shows and follows the logs of all services</dd>
<dt><code>secret-files</code></dt><dd>DUMMY: This creates placeholder passwords in ./secrets to be overwritten with<br/>
 the actual secrets.</dd>
<dt><code>remove-secrets</code></dt><dd>Removes the podman/docker secrets defined by the "secrets" target".</dd>
<dt><code>secrets</code></dt><dd>Takes the secrets defined in ./secrets and makes podman/docker secrets out of<br/>
 it.</dd>
<dt><code>load-buildbot-logs</code></dt><dd>Takes the buildbot logs and loads them into the database.</dd>
<dt><code>help</code></dt><dd>Display this help text.</dd>
<dt><code>help-html</code></dt><dd>Display this help text as an HTML definition list for better documentation generation</dd>
</dl>

