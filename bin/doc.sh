#!/use/bin/env bash

set -eo pipefail
set -x

forge doc -b
git_url=https://github.com/darwinia-network/ORMP.git
current_dir=$PWD
deploy_dir=${current_dir}/docs/book
tmp_dir=$(mktemp -d)
work_dic=$tmp_dir/$(basename $deploy_dir)
cp -rf ${deploy_dir} ${tmp_dir}
cd $work_dic
git init
git checkout -B gh-pages
git add .
git commit -m "Update"
git push --force --quiet $git_url gh-pages
cd -
