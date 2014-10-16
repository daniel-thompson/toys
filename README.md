Daniel's Toys
=============

toys is a small collection of environmental utilities. Basically its a library
of files I use to become "comfortable" in front of a Unix or Linux machine.
Each utility shares the characteristic that it is too small to be interesting
on its own.

It is neither organised nor intended to be consumed verbatim.

Instead you should either ignore it and go and read something more interesting
or you should use it as inspiration. Treat it as a collection of ideas to be
plundered rather than as a functional work.

Quickstart
----------

    git clone git@github.com:daniel-thompson/toys.git

    # Fetch all the submodules
    git submodule update --init --recursive

    # Configure bash
    mkdir ~/.bashrc.d
    ln -s $PWD/bashrc.d/* ~/.bashrc.d/
    cat bashrc >> ~/.bashrc

    # Put some scripts on the path
    mkdir -p ~/public/bin
    ln -s $PWD/bin/* ~/public/bin

    # Configure tmux and vim
    ln -s $PWD/tmux.conf ~/.tmux.conf
    ln -s $PWD/vim ~/.vim

    # Hide some temporary files from git
    printf 'doc/tags\n.gitignore\n' > vim/bundle/vimwiki/.gitignore

Organisation
------------

* Files in the top-level directory mirror similarly named files located in a
  typical Unix-like home directory.

* bashrc.d/ contains fragments to be included from a .bashrc file.

* bin/ contains executable scripts.

* clang-format/ contains clang format descriptions of some common coding
  styles.

* vim/ is a configured .vim directory (and has its own README file).

* tmux.conf makes a couple of very basic "comfort" changes for tmux.

