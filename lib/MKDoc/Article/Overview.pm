=head1 NAME

MKDoc::Article::Overview - Overview of MKDoc::Framework



=head1 SUMMARY

This is an article, not a module.



=head1 HISTORY

Webarchitects is a partnership in the UK. We have been doing a lot of
governmental websites. Our objectives have always been to advance and
promote standards information architecture and online learning technologies.

This research has led us to produce our own content management system over
the years through MKDoc Ltd.

MKDoc CMS is now a mature products but all the code lives in one big CVS
repository. Each time we add a feature, the codebase increases a bit more.
Separation between various system components is sometimes a bit blurry.
Although MKDoc CMS is not at the stage of "unworkable spaghetti code that
needs to be thrown away", there is quite a fair bit of cleanup / refactoring
to do.

L<MKDoc> is part of a double effort:

=over

=item Cleanup / Refactor MKDoc CMS

=item Open-source MKDoc CMS

=back



=head1 OVERVIEW 

L<MKDoc> is a mod_perl friendly system in which web applications can
be written.

Rather than re-writing L<MKDoc> from scratch, we have extracted it
from our existing content management system. Here is the process which has been
used to do so:

=over

=item Strip all functionality

=item See what is remaining

=item Refactor & make minor improvements

=item Document thoroughly 

=back


What Remains? You might ask. Well, let's see...


=head2 Install scripts

L<MKDoc> comes with L<MKDoc>, an easily subclassable module
which provides a standard installation procedure.

Most open source server-side software is simply impossible to install. Ever
tried to install RT, Slash or DMOZ? L<MKDoc> MKDoc aims at being merely a
nightmare to install - but certainly possible.


=head2 A pluggable chain of responsiblity.

L<MKDoc> offers a 'chain of responsibility' design pattern to handle
incoming HTTP requests. There is a predefined list of handlers which are called
plugins in MKDoc jargon. Each plugin can choose to process the request or not.

At the end of the plugin chain, there is always the L<MKDoc> plugin which always
processes the request when everything else has failed. It
displays a '404 Not Found' page.


=head2 A multi website system

MKDoc has been designed to run multiple sites - and L<MKDoc::FrameWork>
reflects that.

When you install L<MKDoc>, you create a master repository which contains an
empty httpd.conf file. You just need to include this file in your apache config.
Unless you have specific requirements, you should not have to mess with Apache
config files.

The way it works is that whenever you install a new site, it creates httpd.conf
files in the site directory which are included the the master directory's
httpd.conf file.  All you need to do once you install a new site is restart
apache.


=head2 A customization system

By default plugin use L<Petal> templates which are stored along with the code
somewhere in @INC/MKDoc/templates.

When you install L<MKDoc>, you have to create a master directory in which you
can define server-wide defaults for all your L<MKDoc> sites. For example you
can redefine a template in the MKDoc::Framework master directory and all your
L<MKDoc> sites will use this default.

When you install an L<MKDoc> site, you can customize further at the site level
(as opposed to server-wide level). This means that MKDoc products offer three
degrees of customization:

=over

=item "Factory defaults"

=item Server wide

=item Site wide

=back


=head2 Multi-lingual support (optional)

By default L<MKDoc::Plugin> class coupled with L<MKDoc::Language> will choose
the appropriate template based on content negotiation. Other mechanisms than
content negotiation can be used through subclassing.


=head2 Some optional libraries

=over

=item L<MKDoc::Plugin>

By default L<MKDoc::Plugin> uses L<MKDoc::Error> for easy error reporting -
which is especially useful with forms / user input validation.

It is also coupled with L<MKDoc::Language> to provide your web application with
multi-lingual capabilities.


=item L<MKDoc::HTTP::Request>

A subclass of CGI.pm coupled with a per-request singleton design pattern.
Features minor bugfixes and extra methods over CGI.pm.


=item L<MKDoc::HTTP::Response>

Counterpart of L<MKDoc::HTTP::Request>, you can use L<MKDoc::HTTP::Response> to
easily and correctly format your HTTP responses.

=back



=head1 CAVEAT

L<MKDoc> on its own does I<nothing>.

However we are in the process of un-entangling our code base,
which over time will provide the following components:



=head2 MKDoc::Authenticate

This MKDoc product will provide:

=over

=item User management facilities

=item User signup / signout with customizable email confirmation

=item Apache authentication handlers

=item Possibly remote authentication mechanisms & handlers

=back



=head2 MKDoc::Authorize

This MKDoc product will provide:

=over

=item ACL based authorization facilities

=item Apache authentication handlers

=item Possibly some kind of web interface

=back



=head2 MKDoc::Forum

This MKDoc product will provide IMAP based, threaded discussion forums.



=head2 MKDoc::CMS

This MKDoc product will provide the functionality presently offered by
MKDoc 1.6, our commercial content management system. Minus MKDoc::Forum
which will be a separate product.

See http://mkdoc.com/ for details.


=head1 AUTHOR

Copyright 2003 - MKDoc Holdings Ltd.

Author: Jean-Michel Hiver <jhiver@mkdoc.com>

This module is free software and is distributed under the same license as Perl
itself. Use it at your own risk.


=head1 SEE ALSO

  Petal: http://search.cpan.org/author/JHIVER/Petal/
  MKDoc: http://www.mkdoc.com/

Help us open-source MKDoc. Join the mkdoc-modules mailing list:

  mkdoc-modules@lists.webarch.co.uk

=cut
