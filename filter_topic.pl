#!/usr/bin/perl -w
use File::Basename;
use lib dirname $0;
use SurveyDB::Schema;
use Data::Dumper;
use strict;

my $schema = SurveyDB::Schema->connect_surveydb('etc/config.yml');

=begin explain
the behavior here will be:
	only the keys supplied will be taken into account of the intersection
	between conditions.
=cut
my $topics;
$topics = $schema->get_topics(
	bot => 'bot2',
	chatroom => 'ct1',
	uid => 1,
);
print Dumper($topics);
$topics = $schema->get_topics(
	bot => 'bot1',
	uid => 1,
	event => 'event1',
);
print Dumper($topics);
