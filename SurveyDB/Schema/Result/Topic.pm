package SurveyDB::Schema::Result::Topic;
use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components(qw/InflateColumn::DateTime/);
__PACKAGE__->table('topic');
__PACKAGE__->add_columns(qw/tid topic description user/);
__PACKAGE__->add_columns(
	begin_date => { data_type => 'datetime' },
	close_date => { data_type => 'datetime' }
);
__PACKAGE__->set_primary_key('tid');
__PACKAGE__->has_many('questions' => 'SurveyDB::Schema::Result::Question');

sub get_questions {
	my ($self) = @_;
	my @result = $self->result_source->schema->resultset('Question')->search(
		{ 'topic' => $self->tid },
	);
	return \@result;
}

sub add_question {
	my ($self, $question) = @_;
}

1;
