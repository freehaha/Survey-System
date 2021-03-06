#!/usr/bin/perl -w
use File::Basename;
use lib dirname $0;
use SurveyDB::Schema;
use Time::Local;
use Data::Dumper;
use strict;

my $path = dirname $0;
chdir $path;
my $schema = SurveyDB::Schema->connect_surveydb('etc/config.yml');

$schema->txn_begin;
$schema->add_topic({
	title => 'test survey',
	description => 'a survey for test',
	creator => 1,
	begin_date => DateTime->new(year => 2010, month => 8, day => 28, hour => 15),
	close_date => DateTime->new(year => 2010, month => 9, day => 30, hour => 10),
	questions => [
		custom_choice(1, 'q1', custom_options qw/option1 1 option2 3/),
		likert_choice(2, 'q2', options 2),
		open_question(3, 'q3'),
	],
	cond_user(0),
	cond_group(0),
	cond_bot('bot2','bot3'),
	cond_chatroom('all'),
});

$schema->add_topic({
	title => 'test survey 2',
	description => 'something',
	creator => 2,
	begin_date => DateTime->new(year => 2010, month => 9, day => 28),
	close_date => DateTime->new(year => 2010, month => 10, day => 30),
	questions => [
		likert_choice(1, 'q2', options 2),
		likert_choice(2, 'q2', options 2),
		likert_choice(3, 'q3', options 2),
		likert_choice(4, 'q4', options 2),
		likert_choice(5, 'q5', options 2),
		open_question(6, 'q6'),
		open_question(7, 'q7'),
		open_question(8, 'q8'),
		open_question(9, 'q9'),
	],
	cond_user(1,2),
	cond_bot('bot1','bot2','bot3'),
	cond_chatroom('all'),
	cond_group(3),
	cond_event('event1'),
});
$schema->txn_commit;

