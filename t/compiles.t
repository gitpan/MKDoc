use lib qw (../lib lib);
use warnings;
use strict;
use Test::More 'no_plan';

eval "use MKDoc::HTTP::Request";
ok (not $@);

eval "use MKDoc::HTTP::Response";
ok (not $@);

eval "use MKDoc::HTTP::Date";
ok (not $@);

eval "use MKDoc";
ok (not $@);

eval "use MKDoc::Init::Petal";
ok (not $@);

eval "use MKDoc::Plugin";
ok (not $@);

eval "use MKDoc::Error";
ok (not $@);

eval "use MKDoc::Language";
ok (not $@);

eval "use MKDoc::Init";
ok (not $@);

eval "use MKDoc::Plugin::Not_Found";
ok (not $@);

eval "use MKDoc::Plugin::It_Worked";
ok (not $@);

eval "use MKDoc::Setup";
ok (not $@);

eval "use MKDoc::Setup::MKDoc";
ok (not $@);

eval "use MKDoc::Setup::Site";
ok (not $@);


1;


__END__
