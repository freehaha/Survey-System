package SurveyDB::Schema::Result::Question;
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
		die "empty response" unless defined $response;

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
		warn "unknown type";
		return;
	}
}

sub stat {
	my $self = shift;
	my $answers = $self->answers;
	my $options = $self->options;
	my $total = $answers->count;
	my $sum = 0;
	my $ret = {
		total => $total,
	};
	if($self->type =~ /-choice$/) {
		$ret->{options} = {};
		while(my $option = $options->next) {
			my $count = $answers->search({option => $option->oid})->count;
			$ret->{options}->{$option->text} = $count;
			$sum += $count * $option->point;
		}
		$ret->{avg} =  $sum/$total;
		$ret->{sum} =  $sum;
		$sum = 0;
		$options = $self->options;
		while(my $option = $options->next) {
			my $count = $answers->search({option => $option->oid})->count;
			$ret->{options}->{$option->text} = $count;
			$sum += $count * (($option->point-$ret->{avg}) ** 2);
		}
		$ret->{sdv} = sqrt($sum/($total-1));
	}
	return $ret;
}
1;
