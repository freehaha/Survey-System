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

sub get_user_answered {
	my ($self, $user) = @_;
	return undef unless defined $user;

	my $options = $self->get_options;
	my @ops = map { $_->{oid} } @$options;

	my $rs = $self->result_source->schema->resultset('Answer')->search(
		{ 
			option => \@ops,
			user => $user
		},
		{
			order_by => { -desc => 'aid' },
		}
	);
	my $ret = $rs->next;
	#delete those duplicated answers, if exist
	while(my $row = $rs->next) {
		$row->delete;
	}
	return $ret?$ret->aid:undef;
}
sub answer($$) {
	my ($self, $user, $option) = @_;
	my $options = $self->get_options;
	if($user) { #if already answered, delete it first
		my $ans = $self->get_user_answered($user);
		$ans->delete if $ans;
	}

	$self->result_source->schema->resultset('Answer')->create(
		{ 
			option => $option,
			user => $user
		}
	);
}

1;
