#!/bin/bash
# github.sh -- a github checking module for miyoko's shellbot

github_repo_info () {
	checkfor_branch () {
		if [ -z $1 ] ; then
			branch="master"
		else
			branch=$1
		fi
	}
	string=$(echo $1 | sed -e 's/\// /;s/://')
	user=$(echo $string | awk '{print $1}')
	repo=$(echo $string | awk '{print $2}')
	base="http://github.com/api/v2/yaml"
	checkfor_branch $2
	repo_info="repos/show/$user/$repo"
	commit_info="commits/list/$user/$repo/$branch"
	repo_api_ret=$(curl -s $base/$repo_info)
	commit_api_ret=$(curl -s $base/$commit_info)
	repo_name=$(echo "$repo_api_ret" | grep -Eo ":name:(.*)" | sed -e 's/:.*://')
	repo_owner=$(echo "$repo_api_ret" | grep -Eo ":owner:(.*)" | sed -e 's/:.*://')
	repo_description=$(echo "$repo_api_ret" | grep -Eo ":description:(.*)" | sed -e 's/:.*://')
	repo_url=$(echo "$repo_api_ret" | grep -Eo ":url:(.*)" | sed -e 's/:.*://')
	commit_url=$(echo "$commit_api_ret" | grep -Eo -C1 -m1 "  url:(.*)" | sed -e 's/  url: //')
	commit_sender=$(echo "$commit_api_ret" | grep -E -A1 -m1 "committer:(.*)" | sed -e 's/.*://g' | tr -d [:space:])
	struct_repo="Repo Name: $repo_name || Repo Owner: $repo_owner || Repo Description: $repo_description || Repo URL: http:$repo_url"
	struct_commit="Latest commit by: $commit_sender || http://github.com/$commit_url"
	msg $dest $struct_repo
	msg $dest $struct_commit
}