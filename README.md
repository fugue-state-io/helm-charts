# fugue-state/helm-charts
Update the relevant module

run `./package_tag_push.sh fugue-state 0.2.7`
```
#/bin/bash
export THIS_FILE_PATH=$(realpath "$0")
export REPOSITORY_PATH=$(dirname $THIS_FILE_PATH)

cd $REPOSITORY_PATH
# TODO: iterate through charts whos last edited time is greater than what is described in index.yaml
# TODO: yq chart.yaml to bump
helm package $1 --version $2
helm repo index ./
git tag $1-$2
git add index.yaml
git add ./$1/
git add $1-$2.tgz
git commit -m "released $1-$2"
git push
git push origin $1-$2
cd -
```
