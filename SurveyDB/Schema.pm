package SurveyDB::Schema;
use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_namespaces();

sub add_topic {
	my ($self, $topic) = @_;
	die 'not a hash ref' unless ref($topic) eq 'HASH';

	my $ret = $self->resultset('Topic')->find_or_create({
		begin_date => time(),
		%$topic
	});
	$ret;
}
1;

package main;
sub question($%) {
	my ($question, %options) = @_;
	return {
			question => $question,
			%options
	};
}

sub options {
	return ( option => [
		map{ {text =>  $_} } @_
	]);
}

1;
