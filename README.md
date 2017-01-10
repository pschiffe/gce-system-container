# Atomic system container for GCE agents

Provides [GCE Agents](https://github.com/GoogleCloudPlatform/compute-image-packages) as a system container for atomic host.

This image requires latest [oci-systemd-hook](https://github.com/projectatomic/oci-systemd-hook) and [oci-register-machine](https://github.com/projectatomic/oci-systemd-hook) built from master branch.

Automated build can be found at [Docker Hub](https://hub.docker.com/r/pschiffe/gce-agents/).

## Building and using this image on non-atomic host

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

### Logs on the host

You can see logs from the container directly on the host with something like:
```
sudo journalctl -D /var/log/journal/c58cd6f76c8a489aaf19419597d22fbe
```

## Getting latest Centos Atomic Host Continuous in the GCE

You need to create account and project in https://cloud.google.com/ and configure [Google SDK](https://cloud.google.com/sdk/) on your host. To download and configure the Google SDK, you can do:
```
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
gcloud init
```

Because the agents won't be running on the instance from the beginning, you need to prepare the ssh key manually in advance (if you haven't had any instance running in the GCE before):
```
ssh-keygen -t rsa -f ~/.ssh/google_compute_engine -C cloud-user -N ''
pub_key=$(cut -d ' ' -f 2 < ~/.ssh/google_compute_engine.pub)
key_tmp_file='/tmp/ocp-gce-keys'
echo -n 'cloud-user:' > "$key_tmp_file"
cat ~/.ssh/google_compute_engine.pub >> "$key_tmp_file"
gcloud compute project-info add-metadata --metadata-from-file "sshKeys=${key_tmp_file}"
rm -f "$key_tmp_file"
```

Now download CentOS Atomic Host image, modify it for GCE, upload it there and create instance:
```
wget https://ci.centos.org/artifacts/sig-atomic/centos-continuous/images-alpha/cloud/latest/images/centos-atomic-host-7.qcow2.gz
gzip -d centos-atomic-host-7.qcow2.gz
qemu-img convert -p -S 4096 -f qcow2 -O raw centos-atomic-host-7.qcow2 disk.raw
tar -Szcvf centosah.tar.gz disk.raw
BUCKET_NAME=my-proj-centosah-bucket
gsutil mb gs://${BUCKET_NAME}
gsutil cp centosah.tar.gz gs://${BUCKET_NAME}
gcloud compute images create centosah --source-uri gs://${BUCKET_NAME}/centosah.tar.gz
gsutil -m rm -r gs://${BUCKET_NAME}
gcloud compute instances create "centosah" --machine-type "g1-small" --image "centosah" --boot-disk-size "20" --boot-disk-type "pd-ssd"
```

Once the instance is running, you can ssh to it and change the release channel to continuous:
```
gcloud compute ssh centos@centosah
sudo rpm-ostree rebase -r centos-atomic-continuous:centos-atomic-host/7/x86_64/devel/continuous
```

## Using this image on Atomic Host

```
sudo atomic pull --storage=ostree pschiffe/gce-agents
# optionaly
# sudo atomic uninstall gce-agents
sudo atomic install --system pschiffe/gce-agents
sudo systemctl start gce-agents
```
