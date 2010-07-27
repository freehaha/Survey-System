#!/usr/bin/perl -w
use File::Basename;
use lib dirname $0;
use SurveyDB::Schema;
use Time::Local;
use Data::Dumper;
use strict;

my $path = dirname $0;
chdir $path;
my $schema = SurveyDB::Schema->connect('dbi:SQLite:survey.db');

$schema->txn_begin;
my $topic = $schema->add_topic({
	topic => 'test survey',
	description => 'a survey for test',
	creator => 1,
	begin_date => timelocal(0,0,0,21,7,2010),
	close_date => timelocal(0,0,0,22,7,2010),
	questions => [
		custom_choice(1, 'q1', custom_options qw/option1 1 option2 3/),
		likert_choice(2, 'q2', options qw/option3 option4/),
		open_question(3, 'q3'),
	],
	cond_user(1,2,3,4,5),
});
$schema->txn_commit;

print 'topic: ', $topic->topic, ' -> ', $topic->description, "\n";
my $questions = $topic->get_questions;
foreach my $question (@$questions) {
	print "\t", $question->question.'('.$question->type."):\n";
	my $options = $question->get_options;
	foreach my $option (@$options) {
		print "\t\t", $option->text, "\n";
	}
}
