# +-------------------------------------------------------------------------
# | Copyright (C) 2018 Yunify, Inc.
# +-------------------------------------------------------------------------
# | Licensed under the Apache License, Version 2.0 (the "License");
# | you may not use this work except in compliance with the License.
# | You may obtain a copy of the License in the LICENSE file, or at:
# |
# | http://www.apache.org/licenses/LICENSE-2.0
# |
# | Unless required by applicable law or agreed to in writing, software
# | distributed under the License is distributed on an "AS IS" BASIS,
# | WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# | See the License for the specific language governing permissions and
# | limitations under the License.
# +-------------------------------------------------------------------------

.PHONY: all disk

DISK_IMAGE_NAME=dockerhub.qingcloud.com/csiplugin/csi-qingcloud
DISK_IMAGE_TAG=canary
ROOT_PATH=$(pwd)
PACKAGE_LIST=./cmd/... ./pkg/...

disk:
	docker build -t ${DISK_IMAGE_NAME}-builder:${DISK_IMAGE_TAG} -f deploy/disk/docker/Dockerfile . --target builder

disk-container:
	docker build -t ${DISK_IMAGE_NAME}:${DISK_IMAGE_TAG} -f deploy/disk/docker/Dockerfile  .

install-dev:
	cp /root/.qingcloud/config.yaml deploy/disk/kubernetes/base/config.yaml
	kustomize build  deploy/disk/kubernetes/overlays/dev|kubectl apply -f -

uninstall-dev:
	kustomize build  deploy/disk/kubernetes/overlays/dev|kubectl delete -f -

gen-dev:
	cp /root/.qingcloud/config.yaml deploy/disk/kubernetes/base/config.yaml
	kustomize build deploy/disk/kubernetes/overlays/dev

install-prod:
	kustomize build  deploy/disk/kubernetes/overlays/prod|kubectl apply -f -

uninstall-prod:
	kustomize build  deploy/disk/kubernetes/overlays/prod|kubectl delete -f -

gen-prod:
	kustomize build deploy/disk/kubernetes/overlays/dev

fmt:
	go fmt ${PACKAGE_LIST}

fmt-deep: fmt
	gofmt -s -w -l ./pkg/cloudprovider/ ./pkg/common/ ./pkg/disk/driver ./pkg/disk/rpcserver

sanity-test:
	${ROOT_PATH}/csi-sanity --csi.endpoint /var/lib/kubelet/plugins/disk.csi.qingcloud.com/csi.sock --csi.testvolumesize 107374182400

clean:
	go clean -r -x