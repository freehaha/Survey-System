package SurveyDB::Schema::Result::Question;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('question');
__PACKAGE__->add_columns(qw/qid topic question/);
__PACKAGE__->set_primary_key('qid');
__PACKAGE__->belongs_to('topic' => 'SurveyDB::Schema::Result::Topic');
__PACKAGE__->has_many('option' => 'SurveyDB::Schema::Result::Option');

sub get_options {
	my ($self) = @_;
	my @options = $self->result_source->schema->resultset('Option')->search(
		{ 'question' => $self->qid },
	);
	@options = map { {oid=>$_->oid, text=>$_->text } } @options;
	return \@options;
}

sub get_answered {
	my ($self, $user) = @_;
	return undef unless defined $user;

	my $options = $self->get_options;
	my @ops = map { $_->{oid} } @$options;

	my $result = $self->result_source->schema->resultset('Answer')->search(
		{ 
			option => \@ops,
			user => $user
		}
	)->single;
	return $result->aid;
}
sub delete_answer {
}
sub answer($$) {
	my ($self, $user, $option) = @_;
	my $options = $self->get_options;
	if($user) {
		$self->result_source->schema->resultset('Answer')->find_or_create(
			{ 
				option => $option,
				user => $user
			}
		);
	} else {
		$self->result_source->schema->resultset('Answer')->create(
			{ 
				option => $option,
				user => $user
			}
		);
	}
}

1;
