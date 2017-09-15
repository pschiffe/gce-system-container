# Atomic system container for GCE agents

Provides [GCE Agents](https://github.com/GoogleCloudPlatform/compute-image-packages) as a system container for atomic host.

This image requires recent [oci-systemd-hook](https://github.com/projectatomic/oci-systemd-hook) and [oci-register-machine](https://github.com/projectatomic/oci-systemd-hook) packages.

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

You can see logs from the container directly on the host with:
```
sudo journalctl -D /var/log/journal/$(sudo runc exec -t ${NAME} cat /etc/machine-id)
```

## Getting latest Centos Atomic Host Continuous to the GCE

You need to have an account and a project in https://cloud.google.com/ and configured [Google Cloud SDK](https://cloud.google.com/sdk/) on your host. To download and configure the Google Cloud SDK on RHEL 7 or Fedora based host, you can do:

```
sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM

sudo yum install google-cloud-sdk
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

Now download CentOS Atomic Host image, modify it for GCE, upload it there and create an instance:
```
wget https://ci.centos.org/artifacts/sig-atomic/centos-continuous/images-alpha/cloud/latest/images/centos-atomic-host-7.qcow2.gz
gzip -d centos-atomic-host-7.qcow2.gz
qemu-img convert -p -S 4096 -f qcow2 -O raw centos-atomic-host-7.qcow2 disk.raw
tar -Szcvf centosah.tar.gz disk.raw
BUCKET_NAME=my-proj-centosah-bucket
gsutil mb gs://${BUCKET_NAME}
gsutil -o GSUtil:parallel_composite_upload_threshold=150M cp centosah.tar.gz gs://${BUCKET_NAME}
gcloud compute images create centosah --source-uri gs://${BUCKET_NAME}/centosah.tar.gz
gsutil -m rm -r gs://${BUCKET_NAME}
gcloud compute instances create "centosah" --machine-type "g1-small" --image "centosah" --boot-disk-size "20" --boot-disk-type "pd-ssd"
```

Once the instance is running, you can ssh to it and change the release channel to continuous:
```
gcloud compute ssh centos@centosah
sudo rpm-ostree rebase -r centos-atomic-continuous:centos-atomic-host/7/x86_64/devel/continuous
```

## Getting RHEL Atomic Host to the GCE

It's possible to use this image with RHEL Atomic Host 7.4.1 and later. Steps for getting this OS to the GCE are similar to steps above. You need to have an account and a project in https://cloud.google.com/ and configured Google Cloud SDK. Configuration of the ssh key is the same as above (if you didn't run any instance before). To download RHEL Atomic Host from Red Hat access portal (you need an account there), visit https://access.redhat.com/downloads/content/271/ver=/rhel---7/latest/x86_64/product-software and download **Red Hat Atomic Cloud Image**. Then:
```
qemu-img convert -p -S 4096 -f qcow2 -O raw rhel-atomic-cloud-7.4.1-5.x86_64.qcow2 disk.raw
tar -Szcvf rhelah.tar.gz disk.raw
BUCKET_NAME=my-proj-rhelah-bucket
gsutil mb gs://${BUCKET_NAME}
gsutil -o GSUtil:parallel_composite_upload_threshold=150M cp rhelah.tar.gz gs://${BUCKET_NAME}
gcloud compute images create rhelah --source-uri gs://${BUCKET_NAME}/rhelah.tar.gz
gsutil -m rm -r gs://${BUCKET_NAME}
gcloud compute instances create "rhelah" --machine-type "g1-small" --image "rhelah" --boot-disk-size "20" --boot-disk-type "pd-ssd"
gcloud compute ssh cloud-user@rhelah
```

## Using this image on Atomic Host

```
sudo atomic pull --storage=ostree pschiffe/gce-agents
# optionaly
# sudo atomic uninstall gce-agents
sudo atomic install --system pschiffe/gce-agents
sudo systemctl start gce-agents
```

To observe logs:
```
sudo journalctl -D /var/log/journal/$(sudo runc exec -t gce-agents cat /etc/machine-id)
```
