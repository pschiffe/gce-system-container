# Atomic system container for GCE agents

Provides [CGE Agents](https://github.com/GoogleCloudPlatform/compute-image-packages) as a system container for atomic host.

This image requires latest [oci-systemd-hook](https://github.com/projectatomic/oci-systemd-hook) and [oci-register-machine](https://github.com/projectatomic/oci-systemd-hook) built from master branch.

Automated build can be found at [Docker Hub](https://hub.docker.com/r/pschiffe/gce-agents/).

## Usage

```
NAME='gce-agents'
git clone https://github.com/pschiffe/gce-system-container.git
cd gce-system-container/image
sudo docker build -t ${NAME} .
sudo atomic pull --storage ostree docker:${NAME}
# optionaly
# sudo atomic uninstall ${NAME}
sudo atomic install --system ${NAME}
sudo systemctl start ${NAME}
```
