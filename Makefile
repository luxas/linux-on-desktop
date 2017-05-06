# Get a distro's default packages: curl -sSL http://old-releases.ubuntu.com/releases/15.10/ubuntu-15.10-desktop-amd64.manifest | awk '{print $1}' > wily
# Filter those packages from the current installed ones: apt list --installed | awk '{print $1}' | cut -d/ -f1 | grep -v -x -f wily -

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

syncthing:
	mkdir -p /tmp/syncthing
	curl -sSL https://github.com/syncthing/syncthing/releases/download/v0.14.26/syncthing-linux-amd64-v0.14.26.tar.gz | tar -xz -C /tmp/syncthing --strip-components=1
	cp /tmp/syncthing/syncthing /usr/bin
	cp /tmp/syncthing/etc/linux-systemd/system/syncthing@.service /tmp/syncthing/etc/linux-systemd/system/syncthing-resume.service /etc/systemd/system/
	systemctl enable syncthing@root.service && systemctl start syncthing@root.service

nylas-mail:
	curl -sSL https://edgehill.nylas.com/download?platform=linux-deb > /tmp/nylas.deb
	dpkg -i /tmp/nylas.deb

spotify:
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886
	echo "deb http://repository.spotify.com stable non-free" | tee /etc/apt/sources.list.d/spotify.list
	apt-get update && apt-get install -y spotify-client

zoom: libxcb-xtest0
	curl -sSL https://zoom.us/client/latest/zoom_amd64.deb > /tmp/zoom.deb
	dpkg -i /tmp/zoom.deb

update:
	apt-get update

openvpn pinentry-gtk2 docker.io libxcb-xtest0 cifs-utils ntfs-3g libappindicator1 libpango1.0-0: update
	apt-get install -y $@

sublime-text:
	curl -sSL https://download.sublimetext.com/sublime-text_build-3126_amd64.deb > /tmp/sublime.deb
	dpkg -i /tmp/sublime.deb

slack: libappindicator1
	curl -sSL https://downloads.slack-edge.com/linux_releases/slack-desktop-2.5.2-amd64.deb > /tmp/slack.deb
	dpkg -i /tmp/slack.deb

chrome: libpango1.0-0
	curl -sSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb > /tmp/chrome.deb
	dpkg -i /tmp/chrome.deb

google-talkplugin:
	curl -sSL https://dl.google.com/linux/direct/google-talkplugin_current_amd64.deb > /tmp/talkplugin.deb
	dpkg -i /tmp/talkplugin.deb

kubeadm:
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
	echo "deb http://apt.kubernetes.io/ kubernetes-xenial-unstable main" > /etc/apt/sources.list.d/kubernetes.list
	apt-get update && apt-get install -y kubeadm docker.io

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

ntfs: ntfs-3g cifs-utils
printers: hl1110cupswrapper

essentials: kubeadm scaleway golang gcloud ntfs nylas-mail spotify zoom openvpn docker.io pinentry-gtk2 sublime-text slack chrome
