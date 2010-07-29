#!/usr/bin/perl -w
use File::Basename;
use lib dirname $0;
use SurveyDB::Schema;
use utf8;
use strict;

my ($dbuser, $dbpwd) = ('test', '12345');
my $schema = SurveyDB::Schema->connect(
	'dbi:mysql:dbname=test',
	$dbuser, $dbpwd,
	{ mysql_enable_utf8 => 1}
);

#get the topic where topic=1
my $t = $schema->resultset('Topic')->find(
	{ topic => 1 }
);

#query the statof each question
my $question = $t->questions;
while(my $question = $question->next) {
	my $stat = $question->stat;
	my $total = $stat->{total};

	print $question->questions, ": ";
	if($question->type =~ /choice$/) {
		#print average and standard deviation
		printf "avg: %.2f, sdv: %.2f\n", $stat->{avg}, $stat->{sdv};
		my $options = $question->options;

		#percentage of each option chosen
		while( my $option = $options->next ) {
			my $text = $option->text;
			if($total) {
				printf "  %s(%d pt): %.2f%%\n", $text,
					$option->point, $stat->{options}->{$text}/$total*100;
			}
		}
	} else {
		print "open question, total responded: ", $total, "\n";
	}
}
