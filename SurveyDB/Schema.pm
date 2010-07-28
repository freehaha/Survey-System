package SurveyDB::Schema;
use base qw/DBIx::Class::Schema/;
use Set::Scalar;

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
=begin get_topics
conditions can be supplied with:

	time(default now), [uid], [gid], bot, query, chatroom, event

in which uid, gid are mutually exclusive, that is, if both are assigned,
only uid will be considered
=cut
sub get_topics {
	my ($self, %cond) = @_;

	my $first = 1;
	my $topics = Set::Scalar->new;

	if(exists $cond{query}) {
		my $cond_query = $self->resultset('Condition::Query');
		my @rs= $cond_query->search(
			{ query => $cond{query} },
			{ group_by => 'topic' }
		);
		if(@rs) {
			$topics->insert(map { $_->topic->tid } @rs);
			$first = 0;
		}
	}

	if(exists $cond{chatroom}) {
		my $cond_query = $self->resultset('Condition::Chatroom');
		my @chatrooms = $cond_query->search(
			{ chatroom => $cond{chatroom} },
			{ group_by => 'topic' }
		);
		if($first and @rs) {
			$topics->insert(map { $_->topic->tid } @rs);
			$first = 0;
		} elsif(@rs) {
			my $set = Set::Scalar->new(map { $_->topic->tid } @rs);
			$topics = $topics->intersection($set);
			undef $set;
		}
	}
	if(exists $cond{bot}) {
		my $cond_query = $self->resultset('Condition::Bot');
		my @chatrooms = $cond_query->search(
			{ bot => $cond{bot} },
			{ group_by => 'topic' }
		);
		if($first and @rs) {
			$topics->insert(map { $_->topic->tid } @rs);
			$first = 0;
		} elsif(@rs) {
			my $set = Set::Scalar->new(map { $_->topic->tid } @rs);
			$topics = $topics->intersection($set);
			undef $set;
		}
	}
	if(exists $cond{event}) {
		my $cond_query = $self->resultset('Condition::Event');
		my @chatrooms = $cond_query->search(
			{ event => $cond{event} },
			{ group_by => 'topic' }
		);
		if($first and @rs) {
			$topics->insert(map { $_->topic->tid } @rs);
			$first = 0;
		} elsif(@rs) {
			my $set = Set::Scalar->new(map { $_->topic->tid } @rs);
			$topics = $topics->intersection($set);
			undef $set;
		}
	}

	if(exists $cond{uid}) {
		my $cond_user = $self->resultset('Condition::User');
		my @rs = $cond_user->search(
			{ uid => {-in => $cond{uid}}},
			{ group_by => 'topic' }
		);
		if($first and @rs) {
			$topics->insert(map { $_->topic->tid } @rs);
			$first = 0;
		} elsif(@rs) {
			my $set = Set::Scalar->new(map { $_->topic->tid } @rs);
			$topics = $topics->intersection($set);
			undef $set;
		}
	} elsif(exists $cond{gid}) {
		my $cond_user = $self->resultset('Condition::Group');
		my @rs = $cond_user->search(
			{ gid => {-in => $cond{gid}}},
			{ group_by => 'topic' }
		);
		if($first and @rs) {
			$topics->insert(map { $_->topic->tid } @rs);
			$first = 0;
		} elsif(@rs) {
			my $set = Set::Scalar->new(map { $_->topic->tid } @rs);
			$topics = $topics->intersection($set);
			undef $set;
		}
	}
	$topics;
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
	my $pt = 0;
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

sub cond_user(@) {
	return cond_user => [
		map { {uid => $_} } @_
	];
}
sub cond_group(@) {
	return cond_group => [
		map { {gid => $_} } @_
	];
}
sub cond_event(@) {
	return cond_event => [
		map { {event => $_} } @_
	];
}
sub cond_query(@) {
	return cond_query => [
		map { {query => $_} } @_
	];
}
sub cond_bot(@) {
	return cond_bot => [
		map { {bot => $_} } @_
	];
}
sub cond_chatroom(@) {
	return cond_chatroom => [
		map { {chatroom => $_} } @_
	];
}
1;
