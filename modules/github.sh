#!/bin/bash
# github.sh -- a github checking module for miyoko's shellbot

github_repo_info () {
	checkfor_branch () {
		if [ -z $2 ] ; then
			branch="master"
		else
			branch=$2
		fi
	}
	string=$(echo $1 | sed -e 's/\// /;s/://')
	user=$(echo $string | awk '{print $1}')
	repo=$(echo $string | awk '{print $2}')
	base="http://github.com/api/v2/yaml/"
	repo_info="repos/show/$user/$repo"
	commits_info="commits/list/$user/$repo/$branch"
	repo_api_ret=$(curl -s $base$repo_info)
	#commits_api_ret=$(curl -s $base$commits_info)
	repo_name=$(echo "$repo_api_ret" | grep -Eo ":name:(.*)" | sed -e 's/:.*://')
	repo_owner=$(echo "$repo_api_ret" | grep -Eo ":owner:(.*)" | sed -e 's/:.*://')
	repo_description=$(echo "$repo_api_ret" | grep -Eo ":description:(.*)" | sed -e 's/:.*://')
	repo_url=$(echo "$repo_api_ret" | grep -Eo ":url:(.*)" | sed -e 's/:.*://')
	#commit_url=$(echo "$commits_api_ret" | grep -Eo "url:" | sed -e 's/.*://')
	#commit_sender=$(echo "$commits_api_ret" | grep -Eo -A1 "committer:" | grep -Eo "name:.*" | sed -e 's/.*://g')
	struct_repo="Repo Name: $repo_name || Repo Owner: $repo_owner || Repo Description: $repo_description || Repo URL: http:$repo_url"
	#struct_commit="Latest commit by: $commit_sender || http://github.com/$commit_url"
	msg $dest $struct_repo
	#msg $dest $struct_commit
}