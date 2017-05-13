# Get a distro's default packages: curl -sSL http://old-releases.ubuntu.com/releases/15.10/ubuntu-15.10-desktop-amd64.manifest | awk '{print $1}' > wily
# Filter those packages from the current installed ones: apt list --installed | awk '{print $1}' | cut -d/ -f1 | grep -v -x -f wily -

essentials: hub kubeadm scaleway golang gcloud ntfs nylas-mail spotify zoom openvpn docker.io pinentry-gtk2 sublime-text slack chrome
benchmarks: hardinfo sysbench hdparm gtkperf phoronix-test-suite geekbench
ntfs: ntfs-3g cifs-utils
printers: hl1110cupswrapper

# Programs I possibly also might want to install in the future:
# apache2-utils binfmt-support debhelper filezilla htop nmap qv4l2 screen toggldesktop xrdp

update:
	apt-get update

openvpn pinentry-gtk2 docker.io libxcb-xtest0 cifs-utils ntfs-3g hardinfo sysbench hdparm gtkperf phoronix-test-suite: update
	apt-get install -y $@

en-apt:
	sed -e "s|fi.|en.|g" -i /etc/apt/sources.list
	apt-get update

nylas-mail:
	curl -sSL https://edgehill.nylas.com/download?platform=linux-deb > /tmp/nylas.deb
	dpkg -i /tmp/nylas.deb; apt-get install -f -y

spotify:
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886
	echo "deb http://repository.spotify.com stable non-free" | tee /etc/apt/sources.list.d/spotify.list
	apt-get update && apt-get install -y spotify-client

zoom:
	curl -sSL https://zoom.us/client/latest/zoom_amd64.deb > /tmp/zoom.deb
	dpkg -i /tmp/zoom.deb; apt-get install -f -y

sublime-text:
	curl -sSL https://download.sublimetext.com/sublime-text_build-3126_amd64.deb > /tmp/sublime.deb
	dpkg -i /tmp/sublime.deb; apt-get install -f -y

slack: libappindicator1
	curl -sSL https://downloads.slack-edge.com/linux_releases/slack-desktop-2.5.2-amd64.deb > /tmp/slack.deb
	dpkg -i /tmp/slack.deb; apt-get install -f -y

chrome: libpango1.0-0
	curl -sSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb > /tmp/chrome.deb
	dpkg -i /tmp/chrome.deb; apt-get install -f -y

google-talkplugin:
	curl -sSL https://dl.google.com/linux/direct/google-talkplugin_current_amd64.deb > /tmp/talkplugin.deb
	dpkg -i /tmp/talkplugin.deb; apt-get install -f -y

kubeadm:
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
	echo "deb http://apt.kubernetes.io/ kubernetes-xenial-unstable main" > /etc/apt/sources.list.d/kubernetes.list
	apt-get update && apt-get install -y kubeadm

scaleway:
	curl -sSL https://github.com/scaleway/scaleway-cli/releases/download/v1.12/scw_1.12_amd64.deb > /tmp/scaleway.deb
	dpkg -i /tmp/scaleway.deb

golang:
	curl -sSL https://storage.googleapis.com/golang/go1.8.1.linux-amd64.tar.gz | tar -xz -C /usr/local/
	echo "export GOPATH=/go\nexport PATH=\$$PATH:/usr/local/go/bin:\$$GOPATH/bin" >> /etc/profile
	mkdir -p /go

gcloud:
	echo "deb https://packages.cloud.google.com/apt cloud-sdk-xenial main" > /etc/apt/sources.list.d/google-cloud-sdk.list
	curl -sSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
	apt-get update && apt-get install -y google-cloud-sdk

flash:
	echo "deb http://archive.canonical.com/ubuntu yakkety partner" > /etc/apt/sources.list.d/flash-partner.list
	apt-get update && apt-get install -y adobe-flashplugin

hl1110cupswrapper:
	curl -sSL http://download.brother.com/welcome/dlf100421/hl1110cupswrapper-3.0.1-1.i386.deb > /tmp/hl1110.deb
	dpkg -i /tmp/hl1110.deb

geekbench:
	curl -sSL http://cdn.primatelabs.com/Geekbench-4.1.0-Linux.tar.gz | tar -xz -C /usr/local/bin --strip-components=3

# For a guide how to move gpg keys, see: https://www.phildev.net/pgp/gpg_moving_keys.html
git-config:
	git config --global user.name "Lucas Käldström"
	git config --global user.email "lucas.kaldstrom@hotmail.co.uk"
	git config --global commit.gpgsign true
	git config --global user.signingkey "<your gpg key id here>"
	cat gitconfig >> ~/.gitconfig

hub:
	curl -sSL https://github.com/github/hub/releases/download/v2.2.9/hub-linux-amd64-2.2.9.tgz | tar -xz hub-linux-amd64-2.2.9/bin/hub --strip-components=2 -C /usr/local/bin

gnome:
	apt-get update && apt-get install -y \
		gnome-shell \
		gnome-tweak-tool

# Tutorial from: http://www.omgubuntu.co.uk/2017/03/make-ubuntu-look-like-mac-5-steps
# Note the gir1.2-clutter package:
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=614780
# https://askubuntu.com/questions/98849/error-message-requiring-clutter-version-1-0-displayed-and-gnome-shell-refuses

macos: gnome
ifeq ($(HOMEDIR),)
	$(error HOMEDIR must be set)
endif

	apt-get update && apt-get install -y \
		plank \
		gir1.2-clutter

	mkdir -p $(HOMEDIR)/.themes $(HOMEDIR)/.icons /usr/share/plank/themes $(HOMEDIR)/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com

	curl -sSL https://dl.opendesktop.org/api/files/download/id/1489657686/Gnome-OSX-II-2-5-1.tar.xz | tar -xJ -C $(HOMEDIR)/.themes
	curl -sSL https://github.com/keeferrourke/la-capitaine-icon-theme/archive/v0.4.0.tar.gz | tar -xz -C $(HOMEDIR)/.icons

	curl -sSL http://orig02.deviantart.net/e6b7/f/2016/233/5/6/gnosemite___theme_for_plank_by_p0umon-daedkqv.zip > /tmp/gnosemite.zip
	unzip /tmp/gnosemite.zip -d /usr/share/plank/themes

	curl -sSL https://extensions.gnome.org/review/download/6696.shell-extension.zip > /tmp/dash-to-dock.zip
	unzip /tmp/dash-to-dock.zip -d ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/

	curl -sSL http://media.idownloadblog.com/wp-content/uploads/2016/06/macOS-Sierra-Wallpaper-Macbook-Wallpaper.jpg > /usr/share/backgrounds/sierra-wallpaper.jpg
