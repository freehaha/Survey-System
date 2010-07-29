package SurveyDB::Schema::Result::Topic;
use JSON;
use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components(qw/InflateColumn::DateTime/);
__PACKAGE__->table('topic');
__PACKAGE__->add_columns(qw/topic title description timelimit creator/);
__PACKAGE__->add_columns(
	begin_date => { data_type => 'datetime' },
	close_date => { data_type => 'datetime' }
);
__PACKAGE__->set_primary_key('topic');
__PACKAGE__->has_many('questions' => 'SurveyDB::Schema::Result::Question');
__PACKAGE__->has_many('finished' => 'SurveyDB::Schema::Result::Finished');

#condition filters
__PACKAGE__->has_many('cond_user' => 'SurveyDB::Schema::Result::Condition::User');
__PACKAGE__->has_many('cond_group' => 'SurveyDB::Schema::Result::Condition::Group');
__PACKAGE__->has_many('cond_chatroom' => 'SurveyDB::Schema::Result::Condition::Chatroom');
__PACKAGE__->has_many('cond_bot' => 'SurveyDB::Schema::Result::Condition::Bot');
__PACKAGE__->has_many('cond_query' => 'SurveyDB::Schema::Result::Condition::Query');
__PACKAGE__->has_many('cond_event' => 'SurveyDB::Schema::Result::Condition::Event');

sub get_questions {
	my ($self) = @_;
	my @result = $self->result_source->schema->resultset('Question')->search(
		{ 'topic' => $self->topic },
		{ order_by => { -asc => 'sn' }, }
	);
	return \@result;
}

sub add_question {
	my ($self, $question) = @_;
}

sub submit {
	my ($self, $user, $answers) = @_;
	my @questions = $self->search_related('questions')->all;
	$answers = decode_json($answers);

	foreach my $question (@questions) {
		$question->answer($user, $answers->{$question->sn});
	}
}

1;
