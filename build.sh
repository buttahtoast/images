#!/bin/bash
set -x
set -e
# Set envs
token=$(echo $TOKEN)
branch=$(git rev-parse --abbrev-ref HEAD)
repo_full_name=$(git config --get remote.origin.url | sed 's/.*:\/\/github.com\///;s/.git$//')
build_dir="./build"
declare -a new_release
declare -a tags
post_data()
{
  cat <<EOF
{
  "tag_name": "$version",
  "target_commitish": "$branch",
  "name": "$version",
  "body": "$text",
  "draft": false,
  "prerelease": false
}
EOF
}
find_in_array() {
  local word=$1
  shift
  for e in "$@"; do [[ "$e" == "$word" ]] && return 0; done
}
# fetch all tags
git fetch --all --tags

mkdir ${build_dir}
# searching for new releases
#
for i in */
do
  for v in `find $i -name "*.version.json"`
  do
      tags=$(git tag)
      tversion=$(cat $v | jq .version | sed -e 's/\"//g')
      version=$(echo ${i%/}-${tversion})
      if [[ " ${tags[@]} " =~ " ${version} " ]] 
      then
        echo "exists"
      else
        [ -d "${i}/cloud-init" ] && genisoimage -output ${i}/cloud-init/seed.img  -volid cidata -joliet -rock ${i}/cloud-init/user-data ${i}/cloud-init/meta-data
        new_release+=("$i-$v")
        sudo packer init ${i}${i%/}.json.pkr.hcl
        sudo PACKER_LOG=1 packer build -var-file $v ${i}${i%/}.json.pkr.hcl
        sudo gzip ./tmp/${version}.qcow2
        sudo mv ./tmp/${version}.qcow2.gz ${build_dir}
        sudo chmod 777 ${build_dir}/* 
        rm ./tmp -rf
        text="new version for ${i%/} in version ${tversion}"
        curl -v -X POST -H "Accept: application/vnd.github.v3+json" --data "$(post_data)" "https://api.github.com/repos/$repo_full_name/releases?access_token=$token"
        release_id=$(curl -X POST -H "Accept: application/vnd.github.v3+json" --data "$(post_data)" "https://api.github.com/repos/$repo_full_name/releases?access_token=$token" | jq .id)
        curl --data-binary @${build_dir}/${version}.qcow2.gz -H  "Content-Type: application/octet-stream" "https://uploads.github.com/repos/$repo_full_name/releases/$release_id/assets?name=${version}.qcow2.gz&access_token=$token"
        sudo rm -rf @${build_dir}/
      git fetch --all --tags
      fi
  done
done
echo "done."


