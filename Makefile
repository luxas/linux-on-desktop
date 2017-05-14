# Get a distro's default packages: curl -sSL http://old-releases.ubuntu.com/releases/15.10/ubuntu-15.10-desktop-amd64.manifest | awk '{print $1}' > wily
# Filter those packages from the current installed ones: apt list --installed | awk '{print $1}' | cut -d/ -f1 | grep -v -x -f wily -

essentials: hub kubeadm scaleway golang gcloud ntfs nylas-mail spotify zoom openvpn docker.io pinentry-gtk2 sublime-text slack chrome
benchmarks: hardinfo sysbench hdparm gtkperf phoronix-test-suite geekbench
ntfs: ntfs-3g cifs-utils
printers: brother-hl-1110

# Programs I possibly also might want to install in the future:
# apache2-utils binfmt-support debhelper filezilla htop nmap qv4l2 screen toggldesktop xrdp vlc

update:
	apt-get update

openvpn pinentry-gtk2 docker.io libxcb-xtest0 cifs-utils ntfs-3g hardinfo sysbench hdparm gtkperf phoronix-test-suite steam: update
	apt-get install -y $@

en-apt:
	sed -e "s|fi.|en.|g" -i /etc/apt/sources.list
	apt-get update

install-deb:
	curl -sSL $(DEB_URL) > /tmp/$(shell basename $(DEB_URL))
	dpkg -i /tmp/$(shell basename $(DEB_URL)); apt-get install -f -y

nylas-mail:
	$(MAKE) install-deb DEB_URL="https://edgehill.nylas.com/download?platform=linux-deb"

zoom:
	$(MAKE) install-deb DEB_URL="https://zoom.us/client/latest/zoom_amd64.deb"

sublime-text:
	$(MAKE) install-deb DEB_URL="https://download.sublimetext.com/sublime-text_build-3126_amd64.deb"

slack:
	$(MAKE) install-deb DEB_URL="https://downloads.slack-edge.com/linux_releases/slack-desktop-2.5.2-amd64.deb"

chrome:
	$(MAKE) install-deb DEB_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

google-talkplugin:
	$(MAKE) install-deb DEB_URL="https://dl.google.com/linux/direct/google-talkplugin_current_amd64.deb"

scaleway:
	$(MAKE) install-deb DEB_URL="https://github.com/scaleway/scaleway-cli/releases/download/v1.12/scw_1.12_amd64.deb"

steam:
	$(MAKE) install-deb DEB_URL="https://github.com/scaleway/scaleway-cli/releases/download/v1.12/scw_1.12_amd64.deb"

spotify:
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886
	echo "deb http://repository.spotify.com stable non-free" | tee /etc/apt/sources.list.d/spotify.list
	apt-get update && apt-get install -y spotify-client

kubeadm:
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
	echo "deb http://apt.kubernetes.io/ kubernetes-xenial-unstable main" > /etc/apt/sources.list.d/kubernetes.list
	apt-get update && apt-get install -y kubeadm


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

# May not even be required, seems like the HL-1110 works out of the box on 17.04
brother-hl-1110:
	curl -sSL http://download.brother.com/welcome/dlf006893/linux-brprinter-installer-2.1.1-1.gz > /tmp/brother-hl-1110.gz
	cd /tmp
	gunzip /tmp/brother-hl-1110.gz
	chmod +x ./brother
	./brother

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
