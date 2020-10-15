#
# Executable version of the quickstart section in README.md
#

install :
	git submodule update --init --recursive
	mkdir ~/.bashrc.d
	ln -s $(PWD)/bashrc.d/* ~/.bashrc.d/
	cat bashrc >> ~/.bashrc
	mkdir -p ~/public/bin
	ln -s $(PWD)/bin/* ~/public/bin
	ln -s $(PWD)/gitconfig ~/.gitconfig
	ln -s $(PWD)/tmux.conf ~/.tmux.conf
	ln -s $(PWD)/vim ~/.vim
	printf 'doc/tags\n.gitignore\n' > vim/bundle/vimwiki/.gitignore

#
# Useful packages to get the best out of the toys.
#
# libsasl2-modules	Not strictly needed by the toys but mutt will
#                       not be able to authenticate with gmail unless
#                       if has access to this. Typically overlooked on
#                       "lightweight" images.
#
# wl-clipboard		Command line access to the wayland clipboard.
#

debian : install
	sudo apt update
	sudo apt install \
		apt-file libsasl2-modules tmux

fedora : install
	sudo dnf install \
		tmux wl-clipboard
