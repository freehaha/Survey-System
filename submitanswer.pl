#!/usr/bin/perl -w
use File::Basename;
use lib dirname $0;
use SurveyDB::Schema;
use Time::Local;
use Data::Dumper;
use JSON;
use strict;

my ($dbuser, $dbpwd) = ('test', '12345');
my $schema = SurveyDB::Schema->connect(
	'dbi:mysql:dbname=test',
	$dbuser, $dbpwd,
	{ mysql_enable_utf8 => 1}
);
my $t = $schema->resultset('Topic')->find(
	{ topic => 1 }
);

#user 1, 2, 3
$t->submit(
	1, 
	encode_json({
			1 => 2,
			2 => 3,
			3 => 'u1 response text'
		})
);

$t->submit(
	2, #user 2
	encode_json({
			1 => 1,
			2 => 4,
			3 => 'u2 response text'
		})
);

$t->submit(
	3, #user 3
	encode_json({
			1 => 2,
			2 => 3,
			3 => 'u3 response text'
		})
);
