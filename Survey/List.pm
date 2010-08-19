package Survey::List;
use utf8;
use Survey::Templates;
use parent qw(Tatsumaki::Handler);
use strict;
use warnings;

Template::Declare->init( dispatch_to => ['Survey::Templates'] );

sub get {
	my $self = shift;
	my $query = shift;
	my $schema = SurveyDB::Schema->connect_surveydb('etc/config.yml');
	my $topics = $schema->resultset('Topic');
	if($topics) {
		$self->write(Template::Declare->show('list', $topics));
	} else {
		$self->write('沒有任何問卷');
	}
}

1;
