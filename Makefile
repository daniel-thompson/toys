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

