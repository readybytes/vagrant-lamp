RBSL LAMP Box
============

LAMP development stack to work without spoiling your machine.


Pre-Setup:
-------------

Install [vagrant](http://vagrantup.com/)

    Download http://10.0.0.91/intranet/downloads/vagrant/vagrant_1.2.2_x86_64.deb
    Install it via Ubuntu Software Center

Download and Install [VirtualBox](http://www.virtualbox.org/)

Download a vagrant box (name of the box is supposed to be precise64)

    $ vagrant box add precise64 http://10.0.0.91/intranet/downloads/vagrant/boxes/precise64.box


Folder setup:
---------------
    
Store vagrant boxes at 

    $ /vobs/vagrant/
    
Create shared folder for Code & Database

    $ /vobs/shared/code
    $ /vobs/shared/db
    $ /vobs/shared/cache/pear/cache   (to hold pear upate cache)

Installation:
-------------

Clone this repository in /vobs/vagrant

Go to the repository folder and launch the box

    $ cd [repo]
    $ vagrant up


What's inside:
--------------

Installed software:

* Apache
* MySQL
* php
* phpMyAdmin
* Xdebug with Webgrind
* zsh with [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)
* git, subversion
* mc, vim, screen, tmux, curl
* [MailCatcher](http://mailcatcher.me/)
* [Composer](http://getcomposer.org/)
* [Drush](http://drupal.org/project/drush)

Notes
-----

### Apache virtual hosts

You can put sourc code in /vobs/shared/code/[project-name]
This can be accessed on your machine via -
    `http://localhost:8080/[project-name]`
    
You can add alias for above by adding these lines to /etc/hosts
    `33.33.33.10     local.dev`
    
Now you can access websites as 
    `http://local.dev/[project-name]`


### phpMyAdmin

phpMyAdmin is available on every domain. For example:

    `http://localhost:8080/phpmyadmin`
    
    `User : root`
    
    `Password : root`
    
    
    
### XDebug and webgrind

Debugging:
-----------

No seperate configuration required to debug. Xdebug@guest-machine is binded to your host-machine.

XDebug is configured to connect back to your host machine on port 9000 when 
starting a debug session from a browser running on your host. A debug session is 
started by appending GET variable XDEBUG_SESSION_START to the URL (if you use an 
integrated debugger like Eclipse PDT, it will do this for you).

Profiling :
----------
XDebug is also configured to generate cachegrind profile output on demand by 
adding GET variable XDEBUG_PROFILE to your URL. For example:

    http://local.dev/index.php?XDEBUG_PROFILE

Webgrind is available on each domain. For example:

    http://local.dev/webgrind

It looks for cachegrind files in the `/tmp` directory, where xdebug leaves them.

**Note:** xdebug uses the default value for xdebug.profiler_output_name, which 
means the output filename only includes the process ID as a unique part. This 
was done to prevent a real need to clean out cachgrind files. If you wish to 
configure xdebug to always generate profiler output 
(`xdebug.profiler_enable = 1`), you *will* need to change this setting to 
something like
 
    xdebug.profiler_output_name = cachegrind.out.%t.%p
    
so your call to webgrind will not overwrite the file for the process that 
happens to serve webgrind. 

### Mailcatcher

PHP is configured to send mail via MailCatcher, so you can see the emails that 
the vagrant box generates. The Web frontend for MailCatcher is running on port 
1080 and also available on every domain:

    http://local.dev:1080

### Composer

Composer binary is installed globally (to `/usr/local/bin`), so you can simply call `composer` from any directory.
