#!/bin/bash
#
# This is a temporary tool which I am using to look into Git cloning of addons.
# The list lives in this script for the time being, and this is not ready for production!

# Root directory where addons live. Create it if missing.
addons_root=~/serverfiles/garrysmod/addons
if [ ! -e $addons_root ]
then
	mkdir -p $addons_root
fi

# Git protocol to use for fetching repos, options are "ssh" and "https"
git_protocol="ssh"

# List of addons to manage, an array of comma-delimted strings. Format is user,repo,branch,method
addons_list=(
	"nrlulz,ACF,master,zip",
	"wiremod,advdupe2,master,tarball",
	"wiremod,wire,master,clone"
)

# Program flow

for addon_data in ${addons_list[@]}
do
	# Split addon data into separate fields
	IFS=, read githubuser githubrepo githubbranch gitmethod <<< "${addon_data}"
	echo "Managing ${githubuser}/${githubrepo}..."

	# Get current release
	current_release_url="https://api.github.com/repos/${githubuser}/${githubrepo}/git/refs/heads/${githubbranch}"
	current_release=$(curl -s -L $current_release_url | grep '"sha"' | cut -d'"' -f4)

	# Addon path has the repo name in lower-case for gmod linux weirdness
	addon_lcase=$(echo $githubrepo | tr '[:upper:]' '[:lower:]')
	addon_path="${addons_root}/${addon_lcase}"

	# Archive type to download
	# Do the update/install
	case "${gitmethod}" in
		# Allow archive download/deployment as one method of installation
		tar|tarball|archive|download|zip|zipfile|zipball)
			if [ "${gitmethod}" == "zip" ] || [ "${gitmethod}" == "zipfile" ] || [ "${gitmethod}" == "zipball" ]
			then
				archive_format="zipball"
			else
				archive_format="tarball"
			fi

			echo "Using archive (${archive_format})"
			# Download archive if it's not present. This will require we leave the archives in place, so we need to think about that
			archive_url="https://github.com/${githubuser}/${githubrepo}/${archive_format}/${githubbranch}"

			# Get filename of latest archive, this includes the commit hash
			archive_file="${addons_root}/$(curl -sLI $archive_url | grep -o -E '^Content-Disp.*filename=.*$' | sed -e 's/.*filename=//' -e 's/[\x01-\x1F\x7F]//g')"
			archive_unpack=$(echo $archive_file | sed -e 's/\.\(tar\.gz\|tar\|zip\)$//g')
			archive_linktarget=$(basename $archive_unpack)
			# If the unpacked directory isn't there, download and deploy
			# FIXME: There needs to be a better way of tracking installs that doesn't require leaving archives lying around. Cleanup would be good.
			if [ ! -e $archive_unpack ]
			then
				# TODO: Should we uninstall or delete the old addon? Any configs or other data that need to be retained?
				# TODO: Checksum the downloaded files and remove/retry if corrupt
				echo "Fetching ${githubrepo} ($(basename $archive_file))..."
				curl -s -L -o $archive_file $archive_url
				if [ "${archive_format}" == "zipfile" ]
				then
					# Unzip file
					unzip $archive_file -d $addons_path
				else
					# Untar. FIXME: Assuming gzip, should probably have a little logic here.
					# This descends one directory so we get rid of the directory with the same name as the archive
					tar xzvpf $archive_file -C $addons_path
				fi
			fi

			# Update symlink. This will BLOW AWAY a real directory, may want to adjust that behavior.
			if [ "$(basename $(readlink -f $addon_path))" != "${archive_linktarget}" ]
			then
				echo "Pointing ${addon_lcase} to ${archive_linktarget}"
				ln -nsf $archive_linktarget "${addon_path}"
			fi
			;;
		# Otherwise, use Git natively
		*)
			echo "Using Native Git"
			# Get repo URL based upon our protocol
			if [ "${git_protocol}" == "ssh" ]
			then
				repo_url="git@github.com:${githubuser}/${githubrepo}.git"
			else
				repo_url="https://github.com/${githubuser}/${githubrepo}.git"
			fi

			# Clone repo if it does not exist
			if [ ! -e $addon_path ]
			then
				cd $addons_root && git clone $repo_url $addon_lcase
			fi

			# Init repo if directory has no .git subdirectory
			if [ ! -e $addon_path ]
			then
				cd $addons_root && git init
			fi

			# Check to make sure we have the right remote
			repo_remote=$(cd $addon_path && git remote -v | grep '^origin' | grep '\(fetch\)' | awk '{print $2}')
			if [ "${repo_remote}" != "${repo_url}" ]
			then
				# TODO: Possibly delete incorrect remotes?
				cd $addon_path && git remote add -f -t $githubbranch -m $githubbranch origin $repo_url
			fi

			# Check to make sure we are on the latest commit
			repo_commit=$(cd $addon_path && git show | head -n1 | awk '{print $2}')
			if [ "${repo_commit}" != "${current_release}" ]
			then
				cd $addon_path && git pull origin $githubbranch
			fi
			;;
	esac
	echo "Up to date"
done
