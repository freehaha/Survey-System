package SurveyDB::Schema::Result::Question;
use Carp;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('question');
__PACKAGE__->add_columns(qw/qid type topic question sn/);
__PACKAGE__->set_primary_key('qid');
__PACKAGE__->belongs_to('topic' => 'SurveyDB::Schema::Result::Topic');
__PACKAGE__->has_many('options' => 'SurveyDB::Schema::Result::Option');
__PACKAGE__->has_many('answers' => 'SurveyDB::Schema::Result::Answer');

sub get_options {
	my ($self) = @_;
	my @options = $self->search_related('options');
	return \@options;
}

sub get_user_answered {
	my ($self, $user) = @_;
	return undef unless defined $user;

	my $rs = $self->result_source->schema->resultset('Answer')->search(
		{
			user => $user,
			question => $self->qid,
		},
		{ order_by => { -desc => 'aid' }, }
	);
	my $ret = $rs->next;
	#delete those duplicated answers, if exist
	while(my $row = $rs->next) {
		$row->delete;
	}
	return $ret;
}
sub answer {
	my ($self, $user) = @_;
	if($self->type eq 'custom-choice' or $self->type eq 'likert-choice') {
		my $option = $_[2];
		if($user) { #if already answered, update it
			my $ans = $self->get_user_answered($user);
			if($ans) {
				$ans->update({ option => $option });
				return $ans;
			}
		}

		$self->result_source->schema->resultset('Answer')->create({
				option => $option,
				user => $user,
				question => $self->qid,
			});
	} elsif($self->type eq 'open-question') {
		my $response = $_[2];
		croak "empty response" unless defined $response;

		if($user) { #if already answered, update it
			my $ans = $self->get_user_answered($user);
			if (defined $ans) {
				$ans->update({ response => $response });
				return $ans;
			}
		}
		$self->result_source->schema->resultset('Answer')->create({
				response => $response,
				user => $user,
				question => $self->qid,
			});
	} else {
		croak "unknown type";
		return;
	}
}

1;
