package Survey::Answer;
use utf8;
use Survey::Templates;
use parent qw(Tatsumaki::Handler);

Template::Declare->init( dispatch_to => ['Survey::Templates'] );

sub get {
	my $self = shift;
	my $query = shift;
	my $schema = SurveyDB::Schema->connect_surveydb('etc/config.yml');
	my $topic = $schema->resultset('Topic')->search(
		{
			topic => $query,
		}
	)->first;
	if($topic) {
		$self->write(Template::Declare->show('answer', $topic));
	} else {
		$self->write('問卷不存在');
	}
}

1;

package Survey::SubmitAnswer;
use parent qw/Tatsumaki::Handler/;
use JSON;
use utf8;
use SurveyDB::Schema;
use Survey::Templates;
use Time::Local;
use strict;
use warnings;
Template::Declare->init( dispatch_to => ['Survey::Templates'] );

our $schema = SurveyDB::Schema->connect_surveydb('etc/config.yml');

sub get {
	my $self = shift;
	my $topic = shift;
	my $query = shift;

	my $json = JSON->new->utf8(0);
	#FIXME: get current user id and check permission here
	my $uid = 1;
	$query = decode_json($query);
	my %answers = ();
	foreach my $ans (@{$query}) {
		$answers{$ans->{name}} = $ans->{value};
	}
	$topic = $schema->resultset('Topic')->find(
		{ topic => $topic },
	);
	eval {
		$topic->submit(
			$uid,
			encode_json(\%answers)
		);
	};
	if($@) {
		my $msg = $@ =~ s/at \S+ line \d+\.\s*$//;
		$self->write($json->encode({'error' => $msg}));
	} else {
		$self->write($json->encode({'success' => 'success'}));
	}
}

1;
