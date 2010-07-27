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
sub custom_choice($$%) {
	my ($sn, $question, %options) = @_;
	return {
			sn => $sn,
			question => $question,
			type => 'custom-choice',
			%options
	};
}

sub likert_choice($$%) {
	my ($sn, $question, %options) = @_;
	return {
			sn => $sn,
			question => $question,
			type => 'likert-choice',
			%options
	};
}

sub open_question($$) {
	my ($sn, $question) = @_;
	return {
			sn => $sn,
			question => $question,
			type => 'open-question',
	};
}

sub options {
	#TODO: apply Likert styles
	$pt = 0;
	return ( options => [
		map{ $pt++; {text =>  $_, point=>$pt} } @_
	]);
}

sub custom_options(%) {
	my %options = @_;
	return ( options => [
		map{ {text =>  $_, point => $options{$_}} } keys %options
	]);
}

1;
